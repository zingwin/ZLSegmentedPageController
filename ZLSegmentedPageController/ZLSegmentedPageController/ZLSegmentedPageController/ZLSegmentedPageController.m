//
//  ZLSegmentedPageController.m
//  ZLSegmentedPageController
//
//  Created by hitao on 16/6/6.
//  Copyright © 2016年 hitao. All rights reserved.
//

#import "ZLSegmentedPageController.h"
#import "ZLSegmentedView.h"

const void *_ARSEGMENTPAGE_CURRNTPAGE_SCROLLVIEWOFFSET =
&_ARSEGMENTPAGE_CURRNTPAGE_SCROLLVIEWOFFSET;
const void *_ARSEGMENTPAGE_CURRNTPAGE_SCROLLVIEWINSET =
&_ARSEGMENTPAGE_CURRNTPAGE_SCROLLVIEWINSET;

@interface ZLSegmentedPageController()
@property(nonatomic, strong)
UIView<ZLSegmentedPageControllerHeaderProtocol> *headerView;
@property(nonatomic, strong) ZLSegmentedView *segmentView;
@property(nonatomic, strong) NSMutableArray *controllers;
@property(nonatomic, assign) CGFloat segmentTopInset;
@property(nonatomic, weak)
UIViewController<ZLSegmentedControllerDelegate> *currentDisplayController;
@property(nonatomic, assign) CGFloat dynamicHeaderHeight;
@property(nonatomic, strong) NSHashTable *hasShownControllers;
@property(nonatomic, assign) BOOL ignoreOffsetChanged; //是否忽略offset的改变
@property(nonatomic, assign) CGFloat originalTopInset;
@end


@implementation ZLSegmentedPageController
-(instancetype)initWithControllers:(UIViewController<ZLSegmentedControllerDelegate> *)controller, ...{
    self = [super init];
    if (self) {
        NSAssert(controller != nil, @"the first controller must not be nil!");
        [self setup];
        UIViewController<ZLSegmentedControllerDelegate>* eachController;
        va_list argumentList;
        if (controller) {
            [self.controllers addObject:controller];
            va_start(argumentList, controller);
            while ((eachController = va_arg(argumentList, id))) {
                [self.controllers addObject:eachController];
            }
            va_end(argumentList);
        }
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self baseConfigs];
    [self baseLayout];
}
#pragma mark - public methods
-(void)setViewControllers:(NSArray *)viewControllers{
    [self.controllers removeAllObjects];
    [self.controllers addObjectsFromArray:viewControllers];
}

#pragma makr - overide methods
-(UIView<ZLSegmentedPageControllerHeaderProtocol>*)segmentedPageHeaderView{
    return [[ZLSegmentedPageHeader alloc] init];
}

#pragma mark - private methods
-(void)setup{
    self.ignoreOffsetChanged = NO;
    self.headerHeight = 200;
    self.segmentedHeight = 44;
    self.segmentTopInset = 200;
    self.segmentMiniTopInset = 0;
    self.controllers= [NSMutableArray array];
    self.hasShownControllers = [NSHashTable weakObjectsHashTable];
}

-(void)baseConfigs{
    self.automaticallyAdjustsScrollViewInsets = NO;
    if ([self.view respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        self.view.preservesSuperviewLayoutMargins = YES;
    }
    self.extendedLayoutIncludesOpaqueBars = NO;
    
    {
        self.headerView = [self segmentedPageHeaderView];
        self.headerView.clipsToBounds = YES;
        [self.view addSubview:self.headerView];
    }
    
    
    {
        self.segmentView = [[ZLSegmentedView alloc] init];
        __weak typeof(self) weakSelf = self;
        self.segmentView.segmentControlDidChangedValue = ^(NSInteger index){
            [weakSelf segmentControlDidChangedValue:index];
        };
        [self.view addSubview:self.segmentView];
        NSMutableArray *st = [NSMutableArray array];
        for(UIViewController<ZLSegmentedControllerDelegate> *controller in self.controllers){
            NSString *title = [controller segmentTitle];
            [st addObject:title];
        }
        self.segmentView.segmentTitles = st;
        self.segmentView.defaultIndex = 0;
    }
    
    {
        UIViewController<ZLSegmentedControllerDelegate> *controller = self.controllers[0];
        [controller willMoveToParentViewController:self];
        [self.view insertSubview:controller.view atIndex:0];
        [self addChildViewController:controller];
        [controller didMoveToParentViewController:self];
        
        [self layoutControllerWithController:controller];
        [self addObserverForPageController:controller];
        
        self.currentDisplayController = self.controllers[0];
    }
}

-(void)baseLayout{
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    [self.headerView setFrame:CGRectMake(0, 0, screenBounds.size.width, self.headerHeight)];
    
    [self.segmentView setFrame:CGRectMake(0, CGRectGetMaxY(self.headerView.frame), screenBounds.size.width, self.segmentedHeight)];
    
    self.dynamicHeaderHeight = self.headerHeight;
}

- (void)layoutControllerWithController:
(UIViewController<ZLSegmentedControllerDelegate> *)pageController{
    UIView *pageView = pageController.view;
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    [pageView setFrame:CGRectMake(0, 0, screenBounds.size.width, screenBounds.size.height)];
    
    UIScrollView *scrollView = [self scrollViewInPageController:pageController];
    if (scrollView) {
        scrollView.alwaysBounceVertical = YES;
        _originalTopInset = self.headerHeight + self.segmentedHeight;
        
        CGFloat bottomInset = 0;
        if (self.tabBarController.tabBar.hidden == NO) {
            bottomInset = CGRectGetHeight(self.tabBarController.tabBar.bounds);
        }
        
        //     fixed first time don't show header view
//        if (![self.hasShownControllers containsObject:pageController]) {
//            [self.hasShownControllers addObject:pageController];
//            [scrollView setContentOffset:CGPointMake(0, -self.headerHeight -
//                                                     self.segmentedHeight)];
//        }
        
        [scrollView setContentInset:UIEdgeInsetsMake(_originalTopInset, 0, bottomInset, 0)];
    }else{
        [pageView setFrame:CGRectMake(0, CGRectGetMaxY(self.segmentView.frame), screenBounds.size.width, screenBounds.size.height-CGRectGetMaxY(self.segmentView.frame))];
    }
}

- (UIScrollView *)scrollViewInPageController:
(UIViewController<ZLSegmentedControllerDelegate> *)controller {
    if ([controller respondsToSelector:@selector(streachScrollView)]) {
        return [controller streachScrollView];
    } else if ([controller.view isKindOfClass:[UIScrollView class]]) {
        return (UIScrollView *)controller.view;
    } else {
        return nil;
    }
}

- (void)segmentControlDidChangedValue:(NSInteger)index{
    // remove obsever
    [self removeObseverForPageController:self.currentDisplayController];
    
    UIViewController<ZLSegmentedControllerDelegate> *controller =
    self.controllers[index];
    
    [self.currentDisplayController willMoveToParentViewController:self];
    [self.currentDisplayController.view removeFromSuperview];
    [self.currentDisplayController removeFromParentViewController];
    [self.currentDisplayController didMoveToParentViewController:self];
    
    [controller willMoveToParentViewController:self];
    [self.view insertSubview:controller.view atIndex:0];
    [self addChildViewController:controller];
    [controller didMoveToParentViewController:self];
    
    self.currentDisplayController = controller;
    [self layoutControllerWithController:controller];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    // trigger to fixed header
    UIScrollView *scrollView = [self scrollViewInPageController:controller];
    if (self.dynamicHeaderHeight != self.headerHeight) {
        if (scrollView.contentOffset.y >=
            -(self.segmentedHeight + self.headerHeight) &&
            scrollView.contentOffset.y <= -self.segmentedHeight) {
            [scrollView
             setContentOffset:CGPointMake(
                                          0, -self.segmentedHeight -
                                          self.dynamicHeaderHeight)];
        }
    }
    
    // add obsever
    [self addObserverForPageController:self.currentDisplayController];
    [scrollView setContentOffset:scrollView.contentOffset];
}
#pragma mark - add / remove obsever for page scrollView

- (void)addObserverForPageController:
(UIViewController<ZLSegmentedControllerDelegate> *)controller{
    UIScrollView *scrollView = [self scrollViewInPageController:controller];
    if (scrollView != nil) {
        [scrollView
         addObserver:self
         forKeyPath:NSStringFromSelector(@selector(contentOffset))
         options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
         context:&_ARSEGMENTPAGE_CURRNTPAGE_SCROLLVIEWOFFSET];
        [scrollView
         addObserver:self
         forKeyPath:NSStringFromSelector(@selector(contentInset))
         options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
         context:&_ARSEGMENTPAGE_CURRNTPAGE_SCROLLVIEWINSET];
    }
}

- (void)removeObseverForPageController:
(UIViewController<ZLSegmentedControllerDelegate> *)controller{
    UIScrollView *scrollView = [self scrollViewInPageController:controller];
    if (scrollView != nil) {
        @try {
            [scrollView
             removeObserver:self
             forKeyPath:NSStringFromSelector(@selector(contentOffset))];
            [scrollView removeObserver:self
                            forKeyPath:NSStringFromSelector(@selector(contentInset))];
        } @catch (NSException *exception) {
            NSLog(@"exception is %@", exception);
        } @finally {
        }
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (context == _ARSEGMENTPAGE_CURRNTPAGE_SCROLLVIEWOFFSET && !_ignoreOffsetChanged) {
        CGPoint offset = [change[NSKeyValueChangeNewKey] CGPointValue];
        CGFloat offsetY = offset.y;
        CGPoint oldOffset = [change[NSKeyValueChangeOldKey] CGPointValue];
        CGFloat oldOffsetY = oldOffset.y;
        CGFloat deltaOfOffsetY = offset.y - oldOffsetY;
        CGFloat offsetYWithSegment = offset.y + self.segmentedHeight;
        //NSLog(@"offsetYWithSegment:%f  deltaOfOffsetY:%f offsetY:%f",offsetYWithSegment,deltaOfOffsetY,offset.y);
        if (deltaOfOffsetY>0 && offsetY >= -(self.headerHeight + self.segmentedHeight)) {
            // 当滑动时向上滑动时且不是回弹
            // 跟随移动的偏移量进行变化
            //NOTE:直接相减有可能constant会变成负数，进而被系统强行移除，导致header悬停的位置错乱或者crash
            if(self.dynamicHeaderHeight - deltaOfOffsetY <= 0){
                self.dynamicHeaderHeight = self.segmentMiniTopInset;
            }else{
                self.dynamicHeaderHeight -= deltaOfOffsetY;
            }
            // 如果到达顶部固定区域，那么不继续滑动
            if(self.dynamicHeaderHeight <= self.segmentMiniTopInset){
                self.dynamicHeaderHeight = self.segmentMiniTopInset;
            }
            
            [self.headerView setFrame:CGRectMake(0, 0, self.headerView.frame.size.width, self.dynamicHeaderHeight)];
            [self.segmentView setFrame:CGRectMake(0, CGRectGetMaxY(self.headerView.frame), self.segmentView.frame.size.width, self.segmentView.frame.size.height)];
        
        }else{
            //当向下滑动
            //如果列表已经滚到屏幕上方
            //那么保存顶部栏在顶部
            if(offsetY > 0){
                if (self.dynamicHeaderHeight <= self.segmentMiniTopInset) {
                    self.dynamicHeaderHeight = self.segmentMiniTopInset;
                }
            }else{
                //如果列表顶部已经进入屏幕
                //如果顶部栏已经到达底部
                if (self.dynamicHeaderHeight >= self.headerHeight) {
                    // 如果当前列表滚到了顶部栏的底部
                    // 那么顶部栏继续跟随变大，否这保持不变
                    if (-offsetYWithSegment > self.headerHeight &&
                        !_freezenHeaderWhenReachMaxHeaderHeight) {
                        self.dynamicHeaderHeight = -offsetYWithSegment;
                    } else {
                        self.dynamicHeaderHeight = self.headerHeight;
                    }
                }else{
                    // 在顶部拦未到达底部的情况下
                    // 如果列表还没滚动到顶部栏底部，那么什么都不做
                    // 如果已经到达顶部栏底部，那么顶部栏跟随滚动
                    if(self.dynamicHeaderHeight <= -offsetYWithSegment){
                        self.dynamicHeaderHeight -= deltaOfOffsetY;
                    }
                }
            }
            
            [self.headerView setFrame:CGRectMake(0, 0, self.headerView.frame.size.width, self.dynamicHeaderHeight)];
            [self.segmentView setFrame:CGRectMake(0, CGRectGetMaxY(self.headerView.frame), self.segmentView.frame.size.width, self.segmentView.frame.size.height)];
        }
        // 更新'segmentToInset'变量，让外部的 kvo 知道顶部栏位置的变化
        self.segmentTopInset = self.dynamicHeaderHeight;
    }else if(context== _ARSEGMENTPAGE_CURRNTPAGE_SCROLLVIEWINSET){
        UIEdgeInsets insets = [object contentInset];
        if (fabs(insets.top - _originalTopInset) < 2) {
            self.ignoreOffsetChanged = NO;
        } else {
            self.ignoreOffsetChanged = YES;
        }
    }
}

- (void)dealloc {
    [self removeObseverForPageController:self.currentDisplayController];
}
@end
