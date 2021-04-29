//
//  HHViewController.m
//  HHOptionView
//
//  Created by 1325049637@qq.com on 04/29/2021.
//  Copyright (c) 2021 1325049637@qq.com. All rights reserved.
//

#import "HHViewController.h"
#import <HHOptionView/HHOptionView.h>

@interface HHViewController ()

@end

@implementation HHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSArray *arr = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10"];
    HHOptionView *view = [[HHOptionView alloc] initWithFrame:CGRectMake(100, 100, 200, 44) dataSource:arr];
    view.title = @"1";
    view.selectedIndex = 0;
    view.selectedBlock = ^(HHOptionView * _Nonnull optionView, NSInteger selectedIndex) {
        NSLog(@"%ld", selectedIndex);
    };
    [self.view addSubview:view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
