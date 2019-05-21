//
//  WKWebView+Snapshot.m
//  ZSSnapshotKit_master
//
//  Created by safiri on 2019/5/21.
//  Copyright © 2019 safiri. All rights reserved.
//

#import "WKWebView+Snapshot.h"
#import "WebViewPrintPageRenderer.h"

@implementation WKWebView (Snapshot)

- (UIImage *)takeSnapshotOfVisibleContent {
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0);
    
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)takeSnapshotOfFullContent {
    WebViewPrintPageRenderer *render = [[WebViewPrintPageRenderer alloc] initFormatter:self.viewPrintFormatter contentSize:self.scrollView.contentSize];
    UIImage *image = [render printContentToImage];
    return image;
}

- (void)asyncTakeSnapshotOfFullContent:(void (^)(UIImage * _Nullable))completion {
    CGPoint originalOffset = self.scrollView.contentOffset;
    
    // 当contentSize.height<bounds.height时，保证至少有1页的内容绘制
    NSInteger pageNum = 1;
    if (self.scrollView.contentSize.height > self.scrollView.bounds.size.height) {
        pageNum = (NSInteger)floorf(self.scrollView.contentSize.height/self.scrollView.bounds.size.height);
    }
    
    [self loadPageContentIndex:0 maxIndex:pageNum completion:^{
        [self.scrollView setContentOffset:CGPointZero];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            WebViewPrintPageRenderer *render = [[WebViewPrintPageRenderer alloc] initFormatter:self.viewPrintFormatter contentSize:self.scrollView.contentSize];
            UIImage *image = [render printContentToImage];
            self.scrollView.contentOffset = originalOffset;
            if (completion) completion(image);
        });
    }];
}

- (void)loadPageContentIndex:(NSInteger)index maxIndex:(NSInteger)maxIndex completion:(void(^)(void))completion {
    
    [self.scrollView setContentOffset:CGPointMake(0, index * self.scrollView.frame.size.height)];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (index < maxIndex) {
            [self loadPageContentIndex:index + 1 maxIndex:maxIndex completion:completion];
        }else {
            if (completion) completion();
        }
    });
}
@end
