#import <AppKit/AppKit.h>
#import <math.h>

static NSBezierPath *SquirclePath(CGFloat inset) {
    const NSInteger segments = 256;
    const CGFloat exponent = 5.0;
    const CGFloat center = 512.0;
    const CGFloat radius = 512.0 - inset;
    NSBezierPath *path = [NSBezierPath bezierPath];
    for (NSInteger index = 0; index <= segments; index++) {
        CGFloat angle = 2.0 * M_PI * index / segments;
        CGFloat cosine = cos(angle);
        CGFloat sine = sin(angle);
        CGFloat x = center + radius * copysign(pow(fabs(cosine), 2.0 / exponent), cosine);
        CGFloat y = center + radius * copysign(pow(fabs(sine), 2.0 / exponent), sine);
        if (index == 0) [path moveToPoint:NSMakePoint(x, y)];
        else [path lineToPoint:NSMakePoint(x, y)];
    }
    [path closePath];
    return path;
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        if (argc != 3) return 1;
        CGFloat s = MAX(16, atoi(argv[2]));
        NSBitmapImageRep *rep = [[NSBitmapImageRep alloc]
            initWithBitmapDataPlanes:NULL pixelsWide:s pixelsHigh:s bitsPerSample:8
            samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace
            bytesPerRow:0 bitsPerPixel:0];
        [NSGraphicsContext saveGraphicsState];
        NSGraphicsContext.currentContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:rep];
        NSAffineTransform *scale = [NSAffineTransform transform];
        [scale scaleBy:s / 1024.0]; [scale concat];
        [NSColor.clearColor setFill]; NSRectFill(NSMakeRect(0, 0, 1024, 1024));

        [NSColor.blackColor setFill];
        [SquirclePath(62.0) fill];

        NSColor *green = [NSColor colorWithSRGBRed:0.10 green:0.72 blue:0.32 alpha:1];
        NSBezierPath *body = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(178, 351, 610, 322) xRadius:88 yRadius:88];
        [green setFill]; [body fill];
        NSBezierPath *cap = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(814, 431, 64, 162) xRadius:25 yRadius:25];
        [green setFill]; [cap fill];
        NSBezierPath *bolt = [NSBezierPath bezierPath];
        [bolt moveToPoint:NSMakePoint(531, 397)]; [bolt lineToPoint:NSMakePoint(425, 527)];
        [bolt lineToPoint:NSMakePoint(500, 527)]; [bolt lineToPoint:NSMakePoint(465, 627)];
        [bolt lineToPoint:NSMakePoint(604, 474)]; [bolt lineToPoint:NSMakePoint(522, 474)];
        [bolt closePath]; [NSColor.whiteColor setFill]; [bolt fill];

        [NSGraphicsContext restoreGraphicsState];
        NSData *png = [rep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
        return [png writeToFile:[NSString stringWithUTF8String:argv[1]] atomically:YES] ? 0 : 2;
    }
}
