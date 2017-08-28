//
//  TableViewController.m
//  DSHPageViewController
//
//  Created by shihao on 2017/8/24.
//  Copyright © 2017年 shihao. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController ()

@end

@implementation TableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuseIdentifier"];
}

//- (void)viewWillAppear:(BOOL)animated
//{
//	[super viewWillAppear:animated];
//
//	NSLog(@"%@ %@", self.title, @(__FUNCTION__));
//}
//
//- (void)viewDidAppear:(BOOL)animated
//{
//	[super viewDidAppear:animated];
//
//	NSLog(@"%@ %@", self.title, @(__FUNCTION__));
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//	[super viewWillDisappear:animated];
//
//	NSLog(@"%@ %@", self.title, @(__FUNCTION__));
//}
//
//- (void)viewDidDisappear:(BOOL)animated
//{
//	[super viewDidDisappear:animated];
//
//	NSLog(@"%@ %@", self.title, @(__FUNCTION__));
//}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %ld", self.title, (long)indexPath.row];
    return cell;
}

@end
