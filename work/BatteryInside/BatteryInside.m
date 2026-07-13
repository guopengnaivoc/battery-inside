#import <AppKit/AppKit.h>
#import <IOKit/ps/IOPowerSources.h>
#import <IOKit/ps/IOPSKeys.h>
#import <ServiceManagement/ServiceManagement.h>
#import <UserNotifications/UserNotifications.h>

static void *BatteryInsideAppearanceContext = &BatteryInsideAppearanceContext;
static NSString * const LowBatteryNotificationsEnabledKey = @"LowBatteryNotificationsEnabled";
static NSString * const LowBattery20NotifiedKey = @"LowBattery20Notified";
static NSString * const LowBattery10NotifiedKey = @"LowBattery10Notified";
static NSString * const LowBattery20NotificationID = @"local.codex.BatteryInside.low.20";
static NSString * const LowBattery10NotificationID = @"local.codex.BatteryInside.low.10";

@interface AppDelegate : NSObject <NSApplicationDelegate, UNUserNotificationCenterDelegate> {
    CFRunLoopSourceRef _powerSourceRunLoopSource;
    BOOL _observingStatusItemAppearance;
}
@property (strong) NSStatusItem *statusItem;
@property (strong) NSTimer *timer;
@property (strong) NSWindow *settingsWindow;
@property (strong) NSButton *loginCheckbox;
@property (strong) NSButton *lowBatteryCheckbox;
- (void)updateBattery;
@end

static void PowerSourceChanged(void *context) {
    AppDelegate *delegate = (__bridge AppDelegate *)context;
    dispatch_async(dispatch_get_main_queue(), ^{ [delegate updateBattery]; });
}

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [NSUserDefaults.standardUserDefaults registerDefaults:@{
        LowBatteryNotificationsEnabledKey: @NO,
        LowBattery20NotifiedKey: @NO,
        LowBattery10NotifiedKey: @NO
    }];
    UNUserNotificationCenter.currentNotificationCenter.delegate = self;

    self.statusItem = [NSStatusBar.systemStatusBar statusItemWithLength:28];
    self.statusItem.button.toolTip = @"电池电量";
    self.statusItem.button.target = nil;
    self.statusItem.button.action = nil;
    self.statusItem.menu = nil;
    [self.statusItem.button addObserver:self forKeyPath:@"effectiveAppearance"
        options:NSKeyValueObservingOptionNew context:BatteryInsideAppearanceContext];
    _observingStatusItemAppearance = YES;

    [NSWorkspace.sharedWorkspace.notificationCenter addObserver:self selector:@selector(systemDidWake:)
        name:NSWorkspaceDidWakeNotification object:nil];

    [self initializeLoginItemIfNeeded];
    [self updateBattery];
    _powerSourceRunLoopSource = IOPSNotificationCreateRunLoopSource(PowerSourceChanged, (__bridge void *)self);
    if (_powerSourceRunLoopSource) {
        CFRunLoopAddSource(CFRunLoopGetMain(), _powerSourceRunLoopSource, kCFRunLoopCommonModes);
    }
    [self resetRefreshTimer];
}

- (void)systemDidWake:(NSNotification *)notification {
    [self updateBattery];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateBattery];
        [self resetRefreshTimer];
    });
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
    change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == BatteryInsideAppearanceContext) {
        [self updateBattery];
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    [self showSettingsWindow];
    return YES;
}

- (void)initializeLoginItemIfNeeded {
    if (@available(macOS 13.0, *)) {
        NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
        if (![defaults boolForKey:@"HasInitializedLoginItem"]) {
            if (SMAppService.mainAppService.status == SMAppServiceStatusNotRegistered) {
                [SMAppService.mainAppService registerAndReturnError:nil];
            }
            [defaults setBool:YES forKey:@"HasInitializedLoginItem"];
        }
    }
}

- (void)resetRefreshTimer {
    [self.timer invalidate];
    self.timer = [NSTimer timerWithTimeInterval:300 target:self selector:@selector(updateBattery) userInfo:nil repeats:YES];
    [NSRunLoop.mainRunLoop addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)showSettingsWindow {
    if (!self.settingsWindow) [self buildSettingsWindow];
    if (@available(macOS 13.0, *)) {
        self.loginCheckbox.state = SMAppService.mainAppService.status == SMAppServiceStatusEnabled ? NSControlStateValueOn : NSControlStateValueOff;
    }
    self.lowBatteryCheckbox.state = [NSUserDefaults.standardUserDefaults boolForKey:LowBatteryNotificationsEnabledKey]
        ? NSControlStateValueOn : NSControlStateValueOff;
    [NSApp activateIgnoringOtherApps:YES];
    [self.settingsWindow center];
    [self.settingsWindow makeKeyAndOrderFront:nil];
}

- (NSTextField *)label:(NSString *)text frame:(NSRect)frame font:(NSFont *)font color:(NSColor *)color {
    NSTextField *label = [[NSTextField alloc] initWithFrame:frame];
    label.stringValue = text; label.editable = NO; label.bezeled = NO; label.drawsBackground = NO;
    label.font = font; label.textColor = color;
    return label;
}

- (void)buildSettingsWindow {
    self.settingsWindow = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 460, 360)
        styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable backing:NSBackingStoreBuffered defer:NO];
    self.settingsWindow.title = @"电池内显设置";
    self.settingsWindow.releasedWhenClosed = NO;
    NSView *view = self.settingsWindow.contentView;
    [view addSubview:[self label:@"电池内显" frame:NSMakeRect(28, 310, 200, 30) font:[NSFont systemFontOfSize:22 weight:NSFontWeightSemibold] color:NSColor.labelColor]];
    [view addSubview:[self label:@"轻量级 macOS 菜单栏电池指示器" frame:NSMakeRect(28, 284, 390, 20) font:[NSFont systemFontOfSize:13] color:NSColor.secondaryLabelColor]];
    NSString *version = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: @"";
    [view addSubview:[self label:[NSString stringWithFormat:@"版本 %@  ·  作者：郭鹏", version]
        frame:NSMakeRect(28, 262, 390, 20) font:[NSFont systemFontOfSize:12] color:NSColor.tertiaryLabelColor]];
    NSTextField *privacy = [self label:@"隐私：仅在本机读取电池状态；不联网，也不收集或上传数据。"
        frame:NSMakeRect(28, 227, 404, 32) font:[NSFont systemFontOfSize:12] color:NSColor.secondaryLabelColor];
    privacy.usesSingleLineMode = NO;
    privacy.lineBreakMode = NSLineBreakByWordWrapping;
    [view addSubview:privacy];

    NSBox *topLine = [[NSBox alloc] initWithFrame:NSMakeRect(28, 209, 404, 1)];
    topLine.boxType = NSBoxSeparator;
    [view addSubview:topLine];

    self.loginCheckbox = [[NSButton alloc] initWithFrame:NSMakeRect(28, 166, 250, 28)];
    self.loginCheckbox.buttonType = NSButtonTypeSwitch; self.loginCheckbox.title = @"登录时自动启动";
    self.loginCheckbox.target = self; self.loginCheckbox.action = @selector(toggleLoginItem:);
    [view addSubview:self.loginCheckbox];

    self.lowBatteryCheckbox = [[NSButton alloc] initWithFrame:NSMakeRect(28, 132, 250, 28)];
    self.lowBatteryCheckbox.buttonType = NSButtonTypeSwitch;
    self.lowBatteryCheckbox.title = @"低电量通知";
    self.lowBatteryCheckbox.target = self;
    self.lowBatteryCheckbox.action = @selector(toggleLowBatteryNotifications:);
    [view addSubview:self.lowBatteryCheckbox];
    [view addSubview:[self label:@"使用电池且电量降至 20% 和 10% 时各提醒一次。"
        frame:NSMakeRect(50, 111, 370, 18) font:[NSFont systemFontOfSize:11] color:NSColor.secondaryLabelColor]];

    NSBox *line = [[NSBox alloc] initWithFrame:NSMakeRect(28, 91, 404, 1)]; line.boxType = NSBoxSeparator; [view addSubview:line];
    NSButton *quit = [[NSButton alloc] initWithFrame:NSMakeRect(28, 34, 145, 34)];
    quit.title = @"退出电池内显"; quit.bezelStyle = NSBezelStyleRounded;
    quit.target = self; quit.action = @selector(quitApp:); [view addSubview:quit];

    NSButton *uninstall = [[NSButton alloc] initWithFrame:NSMakeRect(287, 34, 145, 34)];
    uninstall.title = @"卸载电池内显…";
    uninstall.bezelStyle = NSBezelStyleRounded;
    uninstall.hasDestructiveAction = YES;
    uninstall.target = self;
    uninstall.action = @selector(uninstallApp:);
    [view addSubview:uninstall];
}

- (void)toggleLoginItem:(NSButton *)sender {
    if (@available(macOS 13.0, *)) {
        NSError *error = nil; BOOL success;
        if (sender.state == NSControlStateValueOn) success = [SMAppService.mainAppService registerAndReturnError:&error];
        else success = [SMAppService.mainAppService unregisterAndReturnError:&error];
        if (!success) {
            sender.state = sender.state == NSControlStateValueOn ? NSControlStateValueOff : NSControlStateValueOn;
            NSAlert *alert = [NSAlert new]; alert.messageText = @"无法更改开机启动设置";
            alert.informativeText = error.localizedDescription ?: @"未知错误"; [alert runModal];
        }
    }
}

- (void)toggleLowBatteryNotifications:(NSButton *)sender {
    if (sender.state != NSControlStateValueOn) {
        [self setLowBatteryNotificationsEnabled:NO];
        return;
    }

    sender.enabled = NO;
    UNUserNotificationCenter *center = UNUserNotificationCenter.currentNotificationCenter;
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
        if (settings.authorizationStatus == UNAuthorizationStatusAuthorized ||
            settings.authorizationStatus == UNAuthorizationStatusProvisional) {
            dispatch_async(dispatch_get_main_queue(), ^{ [self setLowBatteryNotificationsEnabled:YES]; });
        } else if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined) {
            [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound)
                completionHandler:^(BOOL granted, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setLowBatteryNotificationsEnabled:granted];
                    if (!granted) [self showNotificationPermissionError:error];
                });
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setLowBatteryNotificationsEnabled:NO];
                [self showNotificationPermissionError:nil];
            });
        }
    }];
}

- (void)setLowBatteryNotificationsEnabled:(BOOL)enabled {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    [defaults setBool:enabled forKey:LowBatteryNotificationsEnabledKey];
    self.lowBatteryCheckbox.state = enabled ? NSControlStateValueOn : NSControlStateValueOff;
    self.lowBatteryCheckbox.enabled = YES;
    if (enabled) {
        [self updateBattery];
    } else {
        [self resetLowBatteryNotificationState];
        [self removeLowBatteryNotifications];
    }
}

- (void)showNotificationPermissionError:(NSError *)error {
    NSAlert *alert = [NSAlert new];
    alert.messageText = @"无法开启低电量通知";
    alert.informativeText = error.localizedDescription ?:
        @"通知权限未开启。请前往“系统设置 > 通知 > 电池内显”允许通知。";
    [alert runModal];
}

- (void)resetLowBatteryNotificationState {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    [defaults setBool:NO forKey:LowBattery20NotifiedKey];
    [defaults setBool:NO forKey:LowBattery10NotifiedKey];
}

- (void)removeLowBatteryNotifications {
    NSArray<NSString *> *identifiers = @[LowBattery20NotificationID, LowBattery10NotificationID];
    UNUserNotificationCenter *center = UNUserNotificationCenter.currentNotificationCenter;
    [center removePendingNotificationRequestsWithIdentifiers:identifiers];
    [center removeDeliveredNotificationsWithIdentifiers:identifiers];
}

- (void)handleLowBatteryNotificationsForPercent:(int)percent usingBattery:(BOOL)usingBattery {
    if (![NSUserDefaults.standardUserDefaults boolForKey:LowBatteryNotificationsEnabledKey]) return;

    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    if (!usingBattery) {
        [self resetLowBatteryNotificationState];
        return;
    }

    if (percent > 25) [defaults setBool:NO forKey:LowBattery20NotifiedKey];
    if (percent > 15) [defaults setBool:NO forKey:LowBattery10NotifiedKey];

    if (percent <= 10 && ![defaults boolForKey:LowBattery10NotifiedKey]) {
        [defaults setBool:YES forKey:LowBattery10NotifiedKey];
        [defaults setBool:YES forKey:LowBattery20NotifiedKey];
        [self sendLowBatteryNotificationWithIdentifier:LowBattery10NotificationID
            title:@"电池电量严重不足" percent:percent];
    } else if (percent <= 20 && ![defaults boolForKey:LowBattery20NotifiedKey]) {
        [defaults setBool:YES forKey:LowBattery20NotifiedKey];
        [self sendLowBatteryNotificationWithIdentifier:LowBattery20NotificationID
            title:@"电池电量较低" percent:percent];
    }
}

- (void)sendLowBatteryNotificationWithIdentifier:(NSString *)identifier title:(NSString *)title percent:(int)percent {
    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.title = title;
    content.body = [NSString stringWithFormat:@"当前电量 %d%%，请及时连接电源。", percent];
    content.sound = UNNotificationSound.defaultSound;
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:nil];
    UNUserNotificationCenter *center = UNUserNotificationCenter.currentNotificationCenter;
    [center removePendingNotificationRequestsWithIdentifiers:@[identifier]];
    [center removeDeliveredNotificationsWithIdentifiers:@[identifier]];
    [center addNotificationRequest:request withCompletionHandler:nil];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
    willPresentNotification:(UNNotification *)notification
    withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    completionHandler(UNNotificationPresentationOptionBanner | UNNotificationPresentationOptionSound);
}

- (void)uninstallApp:(id)sender {
    NSURL *appURL = NSBundle.mainBundle.bundleURL.URLByResolvingSymlinksInPath;
    BOOL validBundle = appURL.isFileURL &&
        [appURL.pathExtension caseInsensitiveCompare:@"app"] == NSOrderedSame &&
        [NSBundle.mainBundle.bundleIdentifier isEqualToString:@"local.codex.BatteryInside"];
    if (!validBundle) {
        [self showErrorWithTitle:@"无法卸载" message:@"无法确认当前应用程序的位置。应用未作任何更改。"];
        return;
    }

    NSAlert *confirmation = [NSAlert new];
    confirmation.messageText = @"卸载电池内显？";
    confirmation.informativeText = @"应用会关闭登录时自动启动、清除自身设置和通知，然后移到废纸篓。其他文件不会受到影响。";
    [confirmation addButtonWithTitle:@"移到废纸篓"];
    [confirmation addButtonWithTitle:@"取消"];
    confirmation.buttons.firstObject.hasDestructiveAction = YES;
    if ([confirmation runModal] != NSAlertFirstButtonReturn) return;

    BOOL hadLoginRegistration = NO;
    if (@available(macOS 13.0, *)) {
        SMAppServiceStatus status = SMAppService.mainAppService.status;
        hadLoginRegistration = status != SMAppServiceStatusNotRegistered && status != SMAppServiceStatusNotFound;
        if (hadLoginRegistration) {
            NSError *loginError = nil;
            if (![SMAppService.mainAppService unregisterAndReturnError:&loginError]) {
                [self showErrorWithTitle:@"无法卸载"
                    message:loginError.localizedDescription ?: @"无法关闭登录时自动启动，应用未作任何更改。"];
                return;
            }
        }
    }

    [NSWorkspace.sharedWorkspace recycleURLs:@[appURL]
        completionHandler:^(NSDictionary<NSURL *,NSURL *> *newURLs, NSError *error) {
        if (!newURLs[appURL]) {
            if (hadLoginRegistration) [SMAppService.mainAppService registerAndReturnError:nil];
            [self showErrorWithTitle:@"无法卸载"
                message:error.localizedDescription ?: @"系统未能将应用移到废纸篓，应用文件仍保留在原处。"];
            return;
        }

        UNUserNotificationCenter *center = UNUserNotificationCenter.currentNotificationCenter;
        [center removeAllPendingNotificationRequests];
        [center removeAllDeliveredNotifications];
        NSString *bundleIdentifier = NSBundle.mainBundle.bundleIdentifier;
        if (bundleIdentifier.length > 0) {
            [NSUserDefaults.standardUserDefaults removePersistentDomainForName:bundleIdentifier];
            [NSUserDefaults.standardUserDefaults synchronize];
        }
        [NSApp terminate:nil];
    }];
}

- (void)showErrorWithTitle:(NSString *)title message:(NSString *)message {
    NSAlert *alert = [NSAlert new];
    alert.messageText = title;
    alert.informativeText = message;
    [alert runModal];
}

- (void)quitApp:(id)sender { [NSApp terminate:nil]; }

- (void)updateBattery {
    int percent = -1;
    BOOL charging = NO;
    BOOL onAC = NO;
    BOOL fullyCharged = NO;
    BOOL powerStateKnown = NO;
    BOOL powerSourcesReadable = NO;
    BOOL foundInternalBattery = NO;
    NSDictionary *battery = nil;

    CFTypeRef info = IOPSCopyPowerSourcesInfo();
    CFArrayRef list = info ? IOPSCopyPowerSourcesList(info) : NULL;
    if (info && list) {
        powerSourcesReadable = YES;
        CFIndex count = CFArrayGetCount(list);
        for (CFIndex index = 0; index < count; index++) {
            CFDictionaryRef description = IOPSGetPowerSourceDescription(info, CFArrayGetValueAtIndex(list, index));
            if (!description) continue;
            NSDictionary *candidate = (__bridge NSDictionary *)description;
            NSString *type = candidate[@kIOPSTypeKey];
            if ([type isKindOfClass:NSString.class] && [type isEqualToString:@kIOPSInternalBatteryType]) {
                battery = [candidate copy];
                foundInternalBattery = YES;
                break;
            }
        }
    }

    if (list) CFRelease(list);
    if (info) CFRelease(info);

    if (battery) {
        NSNumber *current = battery[@kIOPSCurrentCapacityKey];
        NSNumber *maximum = battery[@kIOPSMaxCapacityKey];
        if ([current isKindOfClass:NSNumber.class] && [maximum isKindOfClass:NSNumber.class] &&
            current.doubleValue >= 0.0 && maximum.doubleValue > 0.0) {
            percent = (int)lround(current.doubleValue / maximum.doubleValue * 100.0);
            percent = MIN(100, MAX(0, percent));
        }

        NSNumber *isCharging = battery[@kIOPSIsChargingKey];
        NSNumber *isCharged = battery[@kIOPSIsChargedKey];
        NSString *state = battery[@kIOPSPowerSourceStateKey];
        if ([state isKindOfClass:NSString.class] && [state isEqualToString:@kIOPSACPowerValue]) {
            powerStateKnown = YES;
            onAC = YES;
        } else if ([state isKindOfClass:NSString.class] && [state isEqualToString:@kIOPSBatteryPowerValue]) {
            powerStateKnown = YES;
            onAC = NO;
        }
        charging = powerStateKnown && onAC && [isCharging isKindOfClass:NSNumber.class] && isCharging.boolValue;
        fullyCharged = powerStateKnown && onAC && [isCharged isKindOfClass:NSNumber.class] && isCharged.boolValue;
    }

    if (percent < 0) {
        self.statusItem.button.image = [self batteryImage:-1 charging:NO onAC:NO];
        NSString *unavailableText = powerSourcesReadable && !foundInternalBattery
            ? @"未检测到内置电池" : @"暂时无法读取电池信息";
        self.statusItem.button.toolTip = unavailableText;
        self.statusItem.button.accessibilityLabel = unavailableText;
        return;
    }

    self.statusItem.button.image = [self batteryImage:percent charging:charging onAC:onAC];
    NSString *stateText;
    if (!powerStateKnown) stateText = @"供电状态未知";
    else if (charging) stateText = @"正在充电";
    else if (onAC) stateText = fullyCharged ? @"已充满" : @"已接通电源 · 暂停充电";
    else stateText = @"使用电池";
    self.statusItem.button.toolTip = [NSString stringWithFormat:@"电池 %d%% · %@", percent, stateText];
    self.statusItem.button.accessibilityLabel = [NSString stringWithFormat:@"电池电量 %d%%，%@", percent, stateText];
    if (powerStateKnown) {
        [self handleLowBatteryNotificationsForPercent:percent usingBattery:!onAC];
    }
}

- (NSImage *)batteryImage:(int)percent charging:(BOOL)charging onAC:(BOOL)onAC {
    NSImage *image = [NSImage imageWithSize:NSMakeSize(28, 18) flipped:NO drawingHandler:^BOOL(NSRect rect) {
        [NSGraphicsContext saveGraphicsState];
        NSAffineTransform *horizontalCrop = [NSAffineTransform transform];
        [horizontalCrop translateXBy:-0.65 yBy:0.0];
        [horizontalCrop concat];
        NSBezierPath *body = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(1.5, 3.25, 24, 11.5) xRadius:2.4 yRadius:2.4];
        NSColor *background;
        if (percent < 0) {
            background = NSColor.whiteColor;
        } else if (percent < 10) {
            background = [NSColor colorWithSRGBRed:0.95 green:0.18 blue:0.14 alpha:1.0];
        } else if (percent < 30) {
            background = [NSColor colorWithSRGBRed:1.0 green:0.58 blue:0.10 alpha:1.0];
        } else {
            background = NSColor.whiteColor;
        }
        NSBezierPath *fill = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(3.1, 4.85, 20.8, 8.3) xRadius:1.2 yRadius:1.2];
        [background setFill]; [fill fill];
        [NSColor.labelColor setStroke];
        body.lineWidth = 1.3; [body stroke];
        NSBezierPath *cap = [NSBezierPath bezierPath];
        [cap moveToPoint:NSMakePoint(26.2, 7)]; [cap lineToPoint:NSMakePoint(27.8, 7)];
        [cap lineToPoint:NSMakePoint(27.8, 11)]; [cap lineToPoint:NSMakePoint(26.2, 11)];
        cap.lineWidth = 1.3; [cap stroke];
        BOOL showPowerState = percent >= 0 && (charging || onAC);
        NSString *text = percent < 0 ? @"--" : [NSString stringWithFormat:@"%d", percent];
        CGFloat fontSize = showPowerState ? (percent == 100 ? 6.6 : 7.7) : (percent == 100 ? 7.3 : 8.3);
        NSMutableParagraphStyle *style = [NSMutableParagraphStyle new]; style.alignment = NSTextAlignmentCenter;
        NSRect textRect = showPowerState ? NSMakeRect(2.2, 4.1, 14.8, 10) : NSMakeRect(2.2, 4.1, 22.7, 10);
        NSFont *font = [NSFont monospacedDigitSystemFontOfSize:fontSize weight:NSFontWeightSemibold];
        NSDictionary *attributes = @{NSFontAttributeName:font, NSForegroundColorAttributeName:NSColor.blackColor, NSParagraphStyleAttributeName:style};
        NSSize textSize = [text sizeWithAttributes:attributes];
        CGFloat textX = NSMidX(textRect) - textSize.width / 2.0;
        CGFloat textY = 9.0 - textSize.height / 2.0;
        [text drawAtPoint:NSMakePoint(round(textX * 2.0) / 2.0, round(textY * 2.0) / 2.0) withAttributes:attributes];
        [NSColor.blackColor setFill]; [NSColor.blackColor setStroke];
        if (charging) {
            NSBezierPath *bolt = [NSBezierPath bezierPath];
            [bolt moveToPoint:NSMakePoint(21.2, 12.9)];
            [bolt lineToPoint:NSMakePoint(17.7, 8.8)];
            [bolt lineToPoint:NSMakePoint(20.2, 8.8)];
            [bolt lineToPoint:NSMakePoint(18.9, 5.0)];
            [bolt lineToPoint:NSMakePoint(23.4, 9.8)];
            [bolt lineToPoint:NSMakePoint(20.8, 9.8)];
            [bolt closePath]; [bolt fill];
        } else if (onAC) {
            NSBezierPath *plug = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(18.8, 7.2, 4.3, 3.5) xRadius:0.8 yRadius:0.8];
            [plug fill];
            NSBezierPath *lines = [NSBezierPath bezierPath];
            [lines moveToPoint:NSMakePoint(19.7, 10.2)]; [lines lineToPoint:NSMakePoint(19.7, 12.3)];
            [lines moveToPoint:NSMakePoint(22.1, 10.2)]; [lines lineToPoint:NSMakePoint(22.1, 12.3)];
            [lines moveToPoint:NSMakePoint(21.0, 7.3)]; [lines lineToPoint:NSMakePoint(21.0, 5.4)];
            lines.lineWidth = 1.0; [lines stroke];
        }
        [NSGraphicsContext restoreGraphicsState];
        return YES;
    }];
    image.template = NO;
    return image;
}

- (void)dealloc {
    [self.timer invalidate];
    [NSWorkspace.sharedWorkspace.notificationCenter removeObserver:self];
    if (_observingStatusItemAppearance) {
        [self.statusItem.button removeObserver:self forKeyPath:@"effectiveAppearance" context:BatteryInsideAppearanceContext];
    }
    if (_powerSourceRunLoopSource) {
        CFRunLoopRemoveSource(CFRunLoopGetMain(), _powerSourceRunLoopSource, kCFRunLoopCommonModes);
        CFRelease(_powerSourceRunLoopSource);
    }
}

@end

int main(void) {
    @autoreleasepool {
        NSApplication *app = NSApplication.sharedApplication;
        AppDelegate *delegate = [AppDelegate new];
        app.delegate = delegate;
        [app setActivationPolicy:NSApplicationActivationPolicyAccessory];
        [app run];
    }
    return 0;
}
