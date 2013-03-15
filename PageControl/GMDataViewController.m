//
//  GMDataViewController.m
//  PageControl
//
//  Created by Jooyoung Lee on 14/03/13.
//  Copyright (c) 2013 Jooyoung Lee. All rights reserved.
//


#import "GMDataViewController.h"

#define DEGUB_GMDataViewController 0

#if DEGUB_GMDataViewController
#define StringForMode(x) x == GMLoadingModeNone ? @"None" : x == GMLoadingModeLoading ? @"Loading" : @"Loaded"
#endif

@interface GMDataViewController ()
{
    BOOL _waitingForDataLoading;
    BOOL _waitingForContentsLoading;
}


@end




@implementation GMDataViewController

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
    
    [self initializeContents];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if( self.contentsLoadingMode == GMLoadingModeNone) {
        if( self.dataLoadingMode == GMLoadingModeLoaded ) {
            self.contentsLoadingMode = GMLoadingModeLoading;
            [self loadContents];
        } else {
            // if data is still loading, wait for it!
            _waitingForDataLoading = YES;
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if ( self.contentsLoadingMode == GMLoadingModeLoaded ) {
        self.contentsLoadingMode = GMLoadingModeNone;
        [self unloadContents];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -

- (void)requestLoadingData
{
    //NSLog(@"requestLoadingData : (%d,%d) %@", self.indexPath.section, self.indexPath.row, StringForMode(self.mode));
          
    if( self.dataLoadingMode == GMLoadingModeNone ) {
        self.dataLoadingMode = GMLoadingModeLoading;
        
        [[GMDataLoadingManager sharedInstance] addWorkingWithIndexPath:self.indexPath
                                                              delegate:self
                                                       sideIndexPathes:@[self.nextIndexPath, self.prevIndexPath]];
    }
}

- (void)requestUnloadingData
{
    //NSLog(@"requestUnloadingData : (%d,%d) %@", self.indexPath.section, self.indexPath.row, StringForMode(self.mode));
    
    if( self.contentsLoadingMode == GMLoadingModeLoading ) {
        _waitingForContentsLoading = YES;
    }
    else {
        if( self.dataLoadingMode == GMLoadingModeLoaded ) {
            self.dataLoadingMode = GMLoadingModeNone;
            [self unloadData];
        }
    }
}

#pragma mark -

- (void)initializeContents
{
    // override me
}
- (void)loadContents
{
    // override me
#if DEGUB_GMDataViewController
    NSLog(@"    LOAD CONTENTS (%d,%d)", self.indexPath.section, self.indexPath.row);
#endif
}
- (void)unloadContents
{
    // override me
#if DEGUB_GMDataViewController
    NSLog(@"    UNLOAD CONTENTS (%d,%d)", self.indexPath.section, self.indexPath.row);
#endif
}
- (void)loadDataInBackground
{
    // override me
#if DEGUB_GMDataViewController
    NSLog(@"    LOAD DATA (%d,%d)", self.indexPath.section, self.indexPath.row);
#endif
}
- (void)unloadData
{
    // override me
    NSLog(@"    UNLOAD DATA (%d,%d)", self.indexPath.section, self.indexPath.row);
}

- (void)finishLoadingContents
{
    if( self.contentsLoadingMode == GMLoadingModeLoading )
        self.contentsLoadingMode = GMLoadingModeLoaded;
    
    if( _waitingForContentsLoading ) {
        _waitingForContentsLoading = NO;
        
        self.dataLoadingMode = GMLoadingModeNone;
        [self unloadData];
    }
}

- (void)finishLoadingData
{
    [self performSelectorOnMainThread:@selector(finishLoadingDataAction) withObject:nil waitUntilDone:YES];
}
- (void)finishLoadingDataAction
{
#if DEGUB_GMDataViewController
    NSLog(@"    FINISH DATA (%d,%d)", self.indexPath.section, self.indexPath.row);
#endif
    
    if( self.dataLoadingMode == GMLoadingModeLoading )
        self.dataLoadingMode = GMLoadingModeLoaded;
    
    [[GMDataLoadingManager sharedInstance] removeWorkingWithIndexPath:self.indexPath];
    
    if( _waitingForDataLoading ) {
        _waitingForDataLoading = NO;
        
        self.contentsLoadingMode = GMLoadingModeLoading;
        [self loadContents];
    }
}

#pragma mark - <GMDataLoadingDelegate>

- (void)dataLoadingShouldStart
{
    [self performSelectorInBackground:@selector(loadDataInBackground) withObject:nil];
}

- (void)dataLoadingDidCancel
{
#if DEGUB_GMDataViewController
    NSLog(@"        CANCEL : (%d,%d) %@", self.indexPath.section, self.indexPath.row, StringForMode(self.dataLoadingMode));
#endif
    if( self.dataLoadingMode == GMLoadingModeLoading ) {
        self.dataLoadingMode = GMLoadingModeNone;
    } else {
        NSLog(@"ERROR!!!!!!");
    }
}

@end
