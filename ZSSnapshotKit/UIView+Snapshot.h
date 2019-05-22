//
//  UIView+Snapshot.h
//  ZSSnapshotKit_master
//
//  Created by safiri on 2019/5/22.
//  Copyright © 2019 safiri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnapshotKitProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Snapshot)<SnapshotKitProtocol>

/**
 对指定区域截图

 @param croppingRect 指定裁剪Rect
 @return 图片
 */
- (UIImage *)takeSnapshotOfFullContentForCroppingRect:(CGRect)croppingRect;

@end

NS_ASSUME_NONNULL_END
