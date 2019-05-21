//
//  SnapshotKitProtocol.h
//  ZSSnapshotKit_master
//
//  Created by safiri on 2019/5/21.
//  Copyright © 2019 safiri. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef SnapshotKitProtocol_h
#define SnapshotKitProtocol_h

@protocol SnapshotKitProtocol <NSObject>

@optional

/**
 同步获取视图可见内容的快照
 
 @return UIImage
 */
- (UIImage * _Nullable)takeSnapshotOfVisibleContent;

/**
 同步获取视图全部内容的快照
 重要提示:当视图的全部内容的大小很小时，使用此方法进行快照
 @return UIImage
 */
- (UIImage * _Nullable)takeSnapshotOfFullContent;

/**
 异步获取视图全部内容的快照
 重要提示:当视图的全部内容很大时，使用此方法进行快照
 @param completion 异步结果回调
 */
- (void)asyncTakeSnapshotOfFullContent:(void(^_Nullable)(UIImage *_Nullable image))completion;

@end

#endif /* SnapshotKitProtocol_h */
