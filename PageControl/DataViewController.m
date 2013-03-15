//
//  DataViewController.m
//  PageControl
//
//  Created by Jooyoung Lee on 14/03/13.
//  Copyright (c) 2013 Jooyoung Lee. All rights reserved.
//

#import "DataViewController.h"
#import "UIImageView+Transition.h"

@interface DataViewController ()

@property (strong, nonatomic) UIImage *img;

@end

@implementation DataViewController


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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload {
    [self setImageView:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - override from GMDataViewController

- (void)initializeContents
{
    [super initializeContents];
    self.label.text = [NSString stringWithFormat:@"%d, %d", self.indexPath.section, self.indexPath.row];
}

- (void)loadContents
{
    [super loadContents];

    self.imageView.image = self.img;
    //[self.imageView setNewImage:self.img duration:2.0 options:UIViewAnimationOptionTransitionFlipFromLeft];

    
    [self finishLoadingContents];
}

- (void)unloadContents
{
    [super unloadContents];
    
    self.imageView.image = nil;
}

- (void)loadDataInBackground
{
    @autoreleasepool {
        self.img = [UIImage imageNamed:@"img"];
        sleep(2);
        [self finishLoadingData];
    }
}

- (void)unloadData
{
    self.img = nil;
}


@end
