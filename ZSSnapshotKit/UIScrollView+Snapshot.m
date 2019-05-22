//
//  UIScrollView+Snapshot.m
//  ZSSnapshotKit_master
//
//  Created by safiri on 2019/5/22.
//  Copyright © 2019 safiri. All rights reserved.
//

#import "UIScrollView+Snapshot.h"
#import "UIView+Snapshot.h"

@implementation UIScrollView (Snapshot)

- (UIImage *)takeSnapshotOfVisibleContent {
    CGRect visibleRect = self.bounds;
    visibleRect.origin = self.contentOffset;
    return [self takeSnapshotOfFullContentForCroppingRect:visibleRect];
}

- (UIImage *)takeSnapshotOfFullContent {
    CGRect originalFrame = self.frame;
    CGPoint originalOffset = self.contentOffset;
    
    self.frame = CGRectMake(originalFrame.origin.x, originalFrame.origin.y, self.contentSize.width, self.contentSize.height);
    self.contentOffset = CGPointZero;
    
    UIColor *backgroundColor = self.backgroundColor;
    if (backgroundColor == nil) backgroundColor = UIColor.whiteColor;
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == nil) return nil;
    CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
    CGContextSetStrokeColorWithColor(context, backgroundColor.CGColor);
    
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.frame = originalFrame;
    self.contentOffset = originalOffset;
    
    return image;
}

- (void)asyncTakeSnapshotOfFullContent:(void (^)(UIImage * _Nullable))completion {
    
    //在截图之前先将用户看到的当前页面截取下来，作为一张图片挡住接下来所执行的截取操作，
    //并且在执行完截图操作后，将截取的遮盖图片销毁。
    UIImageView *coverImageView = [[UIImageView alloc] initWithFrame:self.frame];
    coverImageView.image = [self takeSnapshotOfVisibleContent];
    coverImageView.backgroundColor = [UIColor redColor];
    [self.superview addSubview:coverImageView];
    [self.superview bringSubviewToFront:coverImageView];
    
    //分页绘制内容到ImageContext
    CGPoint originalOffset = self.contentOffset;
    
    // 当contentSize.height<bounds.height时，保证至少有1页的内容绘制
    NSInteger pageNum = 1;
    if (self.contentSize.height > self.bounds.size.height) {
        pageNum = (NSInteger)floorf(self.contentSize.height / self.bounds.size.height);
    }
    
    UIColor *backgroundColor = self.backgroundColor;
    if (backgroundColor == nil) backgroundColor = UIColor.whiteColor;
    
    UIGraphicsBeginImageContextWithOptions(self.contentSize, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == nil) {
        [coverImageView removeFromSuperview];
        completion(nil);
        return;
    }
    
    CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
    CGContextSetStrokeColorWithColor(context, backgroundColor.CGColor);
    
    [self drawScreenshotOfPageContent:0 maxIndex:pageNum completion:^{
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.contentOffset = originalOffset;
        [coverImageView removeFromSuperview];
        if (completion) {
            completion(image);
        }
    }];
}

- (void)drawScreenshotOfPageContent:(NSInteger)index maxIndex:(NSInteger)maxIndex completion:(void(^)(void))completion {
    
    [self setContentOffset:CGPointMake(0, index * self.frame.size.height)];
    CGRect pageFrame = CGRectMake(0, index * self.frame.size.height, self.bounds.size.width, self.bounds.size.height);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self drawViewHierarchyInRect:pageFrame afterScreenUpdates:YES];
        if (index < maxIndex) {
            [self drawScreenshotOfPageContent:index+1 maxIndex:maxIndex completion:completion];
        }else {
            if (completion) {
                completion();
            }
        }
    });
    
}

@end
