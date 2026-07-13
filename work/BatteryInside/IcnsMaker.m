#import <Foundation/Foundation.h>

static void appendUInt32(NSMutableData *data, uint32_t value) {
    uint32_t big = CFSwapInt32HostToBig(value);
    [data appendBytes:&big length:4];
}

static void appendChunk(NSMutableData *output, const char type[4], NSString *path) {
    NSData *png = [NSData dataWithContentsOfFile:path];
    if (!png) return;
    [output appendBytes:type length:4];
    appendUInt32(output, (uint32_t)png.length + 8);
    [output appendData:png];
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        if (argc != 3) return 1;
        NSString *set = [NSString stringWithUTF8String:argv[1]];
        NSString *destination = [NSString stringWithUTF8String:argv[2]];
        NSMutableData *body = [NSMutableData data];
        appendChunk(body, "icp4", [set stringByAppendingPathComponent:@"icon_16x16.png"]);
        appendChunk(body, "icp5", [set stringByAppendingPathComponent:@"icon_32x32.png"]);
        appendChunk(body, "icp6", [set stringByAppendingPathComponent:@"icon_32x32@2x.png"]);
        appendChunk(body, "ic07", [set stringByAppendingPathComponent:@"icon_128x128.png"]);
        appendChunk(body, "ic08", [set stringByAppendingPathComponent:@"icon_256x256.png"]);
        appendChunk(body, "ic09", [set stringByAppendingPathComponent:@"icon_512x512.png"]);
        appendChunk(body, "ic10", [set stringByAppendingPathComponent:@"icon_512x512@2x.png"]);
        appendChunk(body, "ic11", [set stringByAppendingPathComponent:@"icon_16x16@2x.png"]);
        appendChunk(body, "ic12", [set stringByAppendingPathComponent:@"icon_32x32@2x.png"]);
        appendChunk(body, "ic13", [set stringByAppendingPathComponent:@"icon_128x128@2x.png"]);
        appendChunk(body, "ic14", [set stringByAppendingPathComponent:@"icon_256x256@2x.png"]);
        NSMutableData *icns = [NSMutableData data];
        [icns appendBytes:"icns" length:4];
        appendUInt32(icns, (uint32_t)body.length + 8);
        [icns appendData:body];
        return [icns writeToFile:destination atomically:YES] ? 0 : 2;
    }
}
