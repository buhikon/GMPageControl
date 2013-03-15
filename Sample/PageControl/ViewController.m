//
//  ViewController.m
//  PageControl
//
//  Created by Jooyoung Lee on 14/03/13.
//  Copyright (c) 2013 Jooyoung Lee. All rights reserved.
//

#import "ViewController.h"
#import "GMPageViewController.h"
#import "DataViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (IBAction)buttonTapped:(id)sender {
    
    GMPageViewController *content = [[GMPageViewController alloc] initWithNibName:@"GMPageViewController" bundle:nil];
    {
        content.dataViewControllers = (NSMutableArray *)
  @[ @[[self createDataViewController],[self createDataViewController],[self createDataViewController]],
     @[[self createDataViewController], [self createDataViewController], [self createDataViewController],[self createDataViewController],[self createDataViewController]],
     @[[self createDataViewController]],
     @[[self createDataViewController],[self createDataViewController]],
     @[[self createDataViewController],[self createDataViewController],[self createDataViewController],[self createDataViewController],[self createDataViewController],[self createDataViewController],[self createDataViewController],[self createDataViewController],[self createDataViewController],[self createDataViewController]]];
    }

    [self presentModalViewController:content animated:YES];
    
}

#pragma mark -

- (DataViewController *)createDataViewController
{
    return [[DataViewController alloc] initWithNibName:@"DataViewController" bundle:nil];
}

@end
