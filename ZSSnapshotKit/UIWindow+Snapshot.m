//
//  UIWindow+Snapshot.m
//  ZSSnapshotKit_master
//
//  Created by safiri on 2019/5/22.
//  Copyright © 2019 safiri. All rights reserved.
//

#import "UIWindow+Snapshot.h"

@implementation UIWindow (Snapshot)

- (UIImage *)takeSnapshotOfVisibleContent {
    return [self takeSnapshotOfFullContent];
}

- (UIImage *)takeSnapshotOfFullContent {
    UIColor *backgroundColor = self.backgroundColor;
    if (backgroundColor == nil) backgroundColor = UIColor.whiteColor;
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == nil) return nil;
    
    CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
    CGContextSetStrokeColorWithColor(context, backgroundColor.CGColor);
    // 使用 layer.render(in: context)的方式生成截图时，在iOS 8.0下，UIWindow展示的是WKWebView时，WKWebView区域的内容是一片空白
    // 使用 drawHierarchy 则无此问题
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)asyncTakeSnapshotOfFullContent:(void (^)(UIImage * _Nullable))completion {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIImage *image = [self takeSnapshotOfFullContent];
        if (completion) {
            completion(image);
        }
    });
}
@end
