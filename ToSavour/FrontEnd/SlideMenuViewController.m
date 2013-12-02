//
//  SlideMenuViewController.m
//  ToSavour
//
//  Created by Jason Wan on 21/11/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "SlideMenuViewController.h"
#import "MasterViewController.h"
#import "AppDelegate.h"

@interface SlideMenuViewController ()

@end

@implementation SlideMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SASlideMenuDataSource

-(void) prepareForSwitchToContentViewController:(UINavigationController *)content{
//    MasterViewController* controller = [content.viewControllers objectAtIndex:0];  XXXX
//    controller.managedObjectContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;  XXXX
}

- (void)configureMenuButton:(UIButton *)menuButton {
    menuButton.frame = CGRectMake(0, 0, 40, 29);
    [menuButton setImage:[UIImage imageNamed:@"MenuIcon"] forState:UIControlStateNormal];
}

- (NSIndexPath *)selectedIndexPath {
    return [NSIndexPath indexPathForRow:0 inSection:0];
}

- (NSString *)segueIdForIndexPath:(NSIndexPath *)indexPath {
    return @"default";
}

- (Boolean)hasRightMenuForIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (Boolean)disablePanGestureForIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - SASlideMenuDelegate

-(void) slideMenuWillSlideIn:(UINavigationController *)selectedContent{
}
-(void) slideMenuDidSlideIn:(UINavigationController *)selectedContent{
}
-(void) slideMenuWillSlideToSide:(UINavigationController *)selectedContent{
}
-(void) slideMenuDidSlideToSide:(UINavigationController *)selectedContent{
}
-(void) slideMenuWillSlideOut:(UINavigationController *)selectedContent{
}
-(void) slideMenuDidSlideOut:(UINavigationController *)selectedContent{
}
-(void) slideMenuWillSlideToLeft:(UINavigationController *)selectedContent{
}
-(void) slideMenuDidSlideToLeft:(UINavigationController *)selectedContent{
}

#pragma mark - UITableView related

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"item"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"item"];
    }
    return cell;
}


@end
