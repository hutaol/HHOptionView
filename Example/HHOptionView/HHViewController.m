//
//  HHViewController.m
//  HHOptionView
//
//  Created by 1325049637@qq.com on 04/29/2021.
//  Copyright (c) 2021 1325049637@qq.com. All rights reserved.
//

#import "HHViewController.h"
#import <HHOptionView/HHOptionView.h>
#import <HHOptionView/HHMultipleOptionView.h>

@interface HHViewController ()

@end

@implementation HHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGFloat w = self.view.frame.size.width/2 - 60;
    CGFloat margin = 40;
    
    NSArray *arr = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24"];
    HHOptionView *view = [[HHOptionView alloc] initWithFrame:CGRectMake(margin, 100, w, 44) dataSource:arr];
    view.showSearchBar = YES;
    view.title = arr[1];
    view.selectedIndex = 1;
    view.selectedBlock = ^(HHOptionView * _Nonnull optionView, NSInteger selectedIndex) {
        NSLog(@"%ld", selectedIndex);
    };
    [self.view addSubview:view];
    
    HHOptionView *view2 =[[HHOptionView alloc] initWithFrame:CGRectMake(margin, self.view.frame.size.height/2, w, 44) dataSource:arr];
    [self.view addSubview:view2];
    
    HHOptionView *view3 =[[HHOptionView alloc] initWithFrame:CGRectMake(margin, self.view.frame.size.height - 100, w, 44) dataSource:arr];
    view3.showSearchBar = YES;
    [self.view addSubview:view3];
    
    NSMutableArray *mArr = [NSMutableArray array];
    for (NSString *str in arr) {
        HHMultipleOptionItem *item = [[HHMultipleOptionItem alloc] initWithTitle:str type:@"" selected:NO];
        [mArr addObject:item];
    }
    
    HHMultipleOptionView *mView =[[HHMultipleOptionView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-w-margin, 100, w, 44) dataSource:mArr];
    mView.showSearchBar = YES;
    mView.showSelectAllButton = YES;
    [self.view addSubview:mView];
    
    HHMultipleOptionView *mView2 =[[HHMultipleOptionView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-w-margin, self.view.frame.size.height/2, w, 44) dataSource:mArr];
    [self.view addSubview:mView2];
    
    HHMultipleOptionView *mView3 =[[HHMultipleOptionView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-w-margin, self.view.frame.size.height - 100, w, 44) dataSource:mArr];
    mView3.showSearchBar = YES;
    [self.view addSubview:mView3];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
