//
//  ZLSegmentedPageHeader.m
//  ZLSegmentedPageController
//
//  Created by hitao on 16/6/6.
//  Copyright © 2016年 hitao. All rights reserved.
//

#import "ZLSegmentedPageHeader.h"

@interface ZLSegmentedPageHeader ()


@property(nonatomic, strong) UIImageView *imageView;

@end

@implementation ZLSegmentedPageHeader
-(instancetype)init{
    self = [super init];
    if(self){
        self.imageView = [[UIImageView alloc] init];
        self.imageView.image = [UIImage imageNamed:@"listdownload.jpg"];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        [self addSubview:self.imageView];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self.imageView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

- (UIView *)segmentedPageHeaderView {
    return _imageView;
}
@end
