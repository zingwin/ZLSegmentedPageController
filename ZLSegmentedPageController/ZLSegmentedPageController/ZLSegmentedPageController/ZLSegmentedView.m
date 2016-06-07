//
//  ZLSegmentedView.m
//  ZLSegmentedPageController
//
//  Created by hitao on 16/6/6.
//  Copyright © 2016年 hitao. All rights reserved.
//

#import "ZLSegmentedView.h"
@interface ZLSegmentedView()
@property (nonatomic, strong) UISegmentedControl *segmentControl;
@end

@implementation ZLSegmentedView
-(instancetype)init{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        _segmentControl = [[UISegmentedControl alloc] init];
        _segmentControl.selectedSegmentIndex = _defaultIndex;
        [_segmentControl addTarget:self action:@selector(segmentDidChangedValue:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.segmentControl];
    }
    return self;
}

-(void)setSegmentTitles:(NSArray *)segmentTitles{
    _segmentTitles = segmentTitles;
    
    for(int i = 0 ;i < [_segmentTitles count]; i++){
        [_segmentControl insertSegmentWithTitle:_segmentTitles[0] atIndex:i animated:NO];
    }
}

-(void)setDefaultIndex:(NSInteger)defaultIndex{
    _defaultIndex = defaultIndex;
    
    [_segmentControl setSelectedSegmentIndex:defaultIndex];
}

-(void)segmentDidChangedValue:(UISegmentedControl*)sender{
    if(_segmentControlDidChangedValue){
        _segmentControlDidChangedValue(sender.selectedSegmentIndex);
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    [self.segmentControl setFrame:CGRectMake(10, 5, self.frame.size.width-20, self.frame.size.height-10)];
}
@end
