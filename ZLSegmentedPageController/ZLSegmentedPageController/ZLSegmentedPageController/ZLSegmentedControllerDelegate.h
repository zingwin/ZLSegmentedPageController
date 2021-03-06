//
//  ZLSegmentedControllerDelegate.h
//  ZLSegmentedPageController
//
//  Created by hitao on 16/6/6.
//  Copyright © 2016年 hitao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ZLSegmentedControllerDelegate <NSObject>
- (NSString *)segmentTitle;

@optional
- (UIScrollView *)streachScrollView;
@end
