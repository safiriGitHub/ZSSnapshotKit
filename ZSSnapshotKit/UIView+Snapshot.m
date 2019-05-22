//
//  UIView+Snapshot.m
//  ZSSnapshotKit_master
//
//  Created by safiri on 2019/5/22.
//  Copyright © 2019 safiri. All rights reserved.
//

#import "UIView+Snapshot.h"

@implementation UIView (Snapshot)

- (UIImage *)takeSnapshotOfVisibleContent {
    return [self takeSnapshotOfFullContentForCroppingRect:self.bounds];
}

- (UIImage *)takeSnapshotOfFullContent {
    return [self takeSnapshotOfFullContentForCroppingRect:self.bounds];
}

- (void)asyncTakeSnapshotOfFullContent:(void (^)(UIImage * _Nullable))completion {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIImage *image = [self takeSnapshotOfFullContent];
        if (completion) {
            completion(image);
        }
    });
}
- (UIImage *)takeSnapshotOfFullContentForCroppingRect:(CGRect)croppingRect {
    // floor(x): 如果参数是小数，则求最大的整数但不大于本身，如floor(3.001)=3.0
    // 由于 croppingView（要裁剪的子视图）的实际size，可能比获取到的size小
    //（double精度问题导致这种差异），所以使用floor对获取到的size进行一次处理，
    // 使获取到的size不大于实际的size，以避免生成的图片底部会出现1px左右的黑线
    UIColor *backgroundColor = self.backgroundColor;
    if (backgroundColor == nil) backgroundColor = UIColor.whiteColor;
    // 若View为非透明且无圆角，则创建非透明的画布
    // 非透明的画布渲染速度比透明的画布要快
    BOOL opaqueCanvas = self.isOpaque && self.layer.cornerRadius == 0;
    // 对于透明的画布，使用白色作为底色
    if (opaqueCanvas == NO) backgroundColor = UIColor.whiteColor;
    
    CGSize contentSize = CGSizeMake(floor(croppingRect.size.width), floor(croppingRect.size.height));
    UIGraphicsBeginImageContextWithOptions(contentSize, opaqueCanvas, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == nil) return nil;
    CGContextSaveGState(context);
    CGContextClearRect(context, croppingRect);
    CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
    CGContextFillRect(context, croppingRect);
    CGContextTranslateCTM(context, -croppingRect.origin.x, -croppingRect.origin.y);
    [self.layer renderInContext:context];
    CGContextRestoreGState(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
