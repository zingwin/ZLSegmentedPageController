//
//  ZLSegmentedView.h
//  ZLSegmentedPageController
//
//  Created by hitao on 16/6/6.
//  Copyright © 2016年 hitao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZLSegmentedView : UIView
@property(nonatomic,strong) NSArray *segmentTitles;
@property(nonatomic,assign) NSInteger defaultIndex;
@property(nonatomic,copy) void(^segmentControlDidChangedValue)(NSInteger index);
@end
