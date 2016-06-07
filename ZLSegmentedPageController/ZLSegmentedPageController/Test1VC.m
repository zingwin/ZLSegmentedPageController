//
//  Test1VC.m
//  ZLSegmentedPageController
//
//  Created by hitao on 16/6/6.
//  Copyright © 2016年 hitao. All rights reserved.
//

#import "Test1VC.h"
#import "TableViewController.h"
#import "CollectionViewController.h"

@implementation Test1VC
-(id)init{
    TableViewController *table = [[TableViewController alloc] initWithNibName:@"TableViewController" bundle:nil];
    CollectionViewController *collectionView = [[CollectionViewController alloc] initWithNibName:@"CollectionViewController" bundle:nil];
    
    
    self = [super initWithControllers:table,collectionView, nil];
    if (self) {
        // your code
        self.segmentMiniTopInset = 64;
        self.headerHeight = 200;
    }
    
    return self;
}
@end
