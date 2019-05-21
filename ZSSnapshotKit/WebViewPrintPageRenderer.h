//
//  WebViewPrintPageRenderer.h
//  ZSSnapshotKit_master
//
//  Created by safiri on 2019/5/21.
//  Copyright © 2019 safiri. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WebViewPrintPageRenderer : UIPrintPageRenderer

- (instancetype)initFormatter:(UIPrintFormatter *)formatter contentSize:(CGSize)contentSize;

- (UIImage * _Nullable)printContentToImage;

@end

NS_ASSUME_NONNULL_END
