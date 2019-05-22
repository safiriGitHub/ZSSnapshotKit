//
//  UITableView+Snapshot.m
//  ZSSnapshotKit_master
//
//  Created by safiri on 2019/5/22.
//  Copyright © 2019 safiri. All rights reserved.
//

#import "UITableView+Snapshot.h"
#import "UIView+Snapshot.h"

@implementation UITableView (Snapshot)

- (UIImage *)takeSnapshotOfTableHeaderView {
    CGRect rect = self.tableHeaderView.frame;
    if (rect.size.width > 0 & rect.size.height > 0) {
        [self scrollRectToVisible:rect animated:NO];
        UIImage *image = [self takeSnapshotOfFullContentForCroppingRect:rect];
        return image;
    }
    return nil;
}

- (UIImage *)takeSnapshotOfTableFooterView {
    CGRect rect = self.tableFooterView.frame;
    if (rect.size.width > 0 & rect.size.height > 0) {
        [self scrollRectToVisible:rect animated:NO];
        UIImage *image = [self takeSnapshotOfFullContentForCroppingRect:rect];
        return image;
    }
    return nil;
}

- (UIImage *)takeSnapshotOfSectionHeaderView:(NSInteger)section {
    CGRect rect = [self rectForHeaderInSection:section];
    if (rect.size.width > 0 && rect.size.height > 0) {
        [self scrollRectToVisible:rect animated:NO];
        UIImage *image = [self takeSnapshotOfFullContentForCroppingRect:rect];
        return image;
    }
    return nil;
}

- (UIImage *)takeSnapshotOfSectionFooterView:(NSInteger)section {
    CGRect rect = [self rectForFooterInSection:section];
    if (rect.size.width > 0 && rect.size.height > 0) {
        [self scrollRectToVisible:rect animated:NO];
        UIImage *image = [self takeSnapshotOfFullContentForCroppingRect:rect];
        return image;
    }
    return nil;
}

- (UIImage *)takeSnapshotOfCell:(NSIndexPath *)indexPath {
    if ([self.indexPathsForVisibleRows containsObject:indexPath] == NO) {
        [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    UIImage *image = [[self cellForRowAtIndexPath:indexPath] takeSnapshotOfFullContent];
    return image;
}

- (UIImage *)internalTakeSnapshotOfFullContent {
    NSMutableArray *shotImages = [NSMutableArray array];
    
    UIImage *imageh = [self takeSnapshotOfTableHeaderView];
    if (imageh) {
        [shotImages addObject:imageh];
    }
    
    for (NSInteger section = 0; section < self.numberOfSections; section++) {
        UIImage *imageh = [self takeSnapshotOfSectionHeaderView:section];
        if (imageh) {
            [shotImages addObject:imageh];
        }
        
        NSInteger rows = [self numberOfRowsInSection:section];
        for (NSInteger row = 0; row < rows; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            UIImage *imagec = [self takeSnapshotOfCell:indexPath];
            if (imagec) {
                [shotImages addObject:imagec];
            }
        }
        
        UIImage *imagef = [self takeSnapshotOfSectionFooterView:section];
        if (imagef) {
            [shotImages addObject:imagef];
        }
    }
    
    UIImage *imagef = [self takeSnapshotOfTableFooterView];
    if (imagef) {
        [shotImages addObject:imagef];
    }
    
    if (shotImages.count == 0) {
        return nil;
    }
    
    // 合成图片：计算总大小，然后拼接图片
    CGSize totalSize = CGSizeMake(self.bounds.size.width, 0);
    for (UIImage *image in shotImages) {
        totalSize.height += image.size.height;
    }
    
    UIColor *backgroundColor = self.backgroundColor;
    if (backgroundColor == nil) backgroundColor = UIColor.whiteColor;
    UIImage *resultImage = nil;
    
    UIGraphicsBeginImageContextWithOptions(totalSize, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == nil) return nil;
    
    CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
    CGContextSetStrokeColorWithColor(context, backgroundColor.CGColor);
    CGFloat imageOffsetFactor = 0;
    for (UIImage *image in shotImages) {
        [image drawAtPoint:CGPointMake(0, imageOffsetFactor)];
        imageOffsetFactor += image.size.height;
    }
    resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

- (UIImage *)takeSnapshotOfVisibleContent {
    CGRect visibleRect = self.bounds;
    visibleRect.origin = self.contentOffset;
    
    return [self takeSnapshotOfFullContentForCroppingRect:visibleRect];
}

- (UIImage *)takeSnapshotOfFullContent {
    CGPoint originalOffset = self.contentOffset;
    UIImage *image = [self internalTakeSnapshotOfFullContent];
    [self setContentOffset:originalOffset animated:NO];
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
