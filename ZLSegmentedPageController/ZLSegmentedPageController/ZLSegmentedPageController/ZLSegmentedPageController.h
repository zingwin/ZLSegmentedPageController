//
//  ZLSegmentedPageController.h
//  ZLSegmentedPageController
//
//  Created by hitao on 16/6/6.
//  Copyright © 2016年 hitao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLSegmentedControllerDelegate.h"
#import "ZLSegmentedPageControllerHeaderProtocol.h"
#import "ZLSegmentedPageHeader.h"

@interface ZLSegmentedPageController : UIViewController
@property(nonatomic,assign) CGFloat segmentedHeight;
@property(nonatomic,assign) CGFloat headerHeight;

@property(nonatomic, assign) CGFloat segmentMiniTopInset; // should be equal or greater than 0
@property(nonatomic, assign, readonly) CGFloat segmentTopInset;
@property(nonatomic, assign) BOOL freezenHeaderWhenReachMaxHeaderHeight;

@property(nonatomic, weak, readonly) UIViewController<ZLSegmentedControllerDelegate> *currentDisplayController;

@property(nonatomic, strong, readonly) UIView<ZLSegmentedPageControllerHeaderProtocol> *headerView;

- (instancetype)initWithControllers: (UIViewController<ZLSegmentedControllerDelegate> *)controller,... NS_REQUIRES_NIL_TERMINATION;

- (void)setViewControllers:(NSArray *)viewControllers;

// override this method to custom your own header view
-(UIView<ZLSegmentedPageControllerHeaderProtocol>*)segmentedPageHeaderView;
@end
