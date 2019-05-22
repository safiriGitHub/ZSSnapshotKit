//
//  UITableView+Snapshot.h
//  ZSSnapshotKit_master
//
//  Created by safiri on 2019/5/22.
//  Copyright © 2019 safiri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnapshotKitProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface UITableView (Snapshot)<SnapshotKitProtocol>

- (UIImage * _Nullable)takeSnapshotOfTableHeaderView;

- (UIImage * _Nullable)takeSnapshotOfTableFooterView;

- (UIImage * _Nullable)takeSnapshotOfSectionHeaderView:(NSInteger)section;

- (UIImage * _Nullable)takeSnapshotOfSectionFooterView:(NSInteger)section;

- (UIImage * _Nullable)takeSnapshotOfCell:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
