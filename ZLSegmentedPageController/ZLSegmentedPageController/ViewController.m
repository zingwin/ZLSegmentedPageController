//
//  ViewController.m
//  ZLSegmentedPageController
//
//  Created by hitao on 16/6/6.
//  Copyright © 2016年 hitao. All rights reserved.
//

#import "ViewController.h"
#import "Test1VC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (IBAction)ddddd:(id)sender {
    Test1VC *vc = [[Test1VC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
