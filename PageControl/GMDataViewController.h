//
//  GMDataViewController.h
//  PageControl
//
//  Created by Jooyoung Lee on 14/03/13.
//  Copyright (c) 2013 Jooyoung Lee. All rights reserved.
//
//
// 1. override below methods:
//    - (void)initializeContents;
//    - (void)loadContents;
//    - (void)unloadContents;
//    - (void)loadDataInBackground;
//    - (void)unloadData;
//
// 2. when `loadContents` finish, call `finishLoadingContents`
//    when `loadDataInBackground` finish, call `finishLoadingData`
//
// 3. Be Careful `loadDataInBackground` is working in BACKGROUND

#import <UIKit/UIKit.h>
#import "GMDataLoadingManager.h"

typedef enum
{
    GMLoadingModeNone,
    GMLoadingModeLoading,
    GMLoadingModeLoaded
} GMLoadingMode;


@interface GMDataViewController : UIViewController <GMDataLoadingDelegate>

@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) NSIndexPath *prevIndexPath;
@property (strong, nonatomic) NSIndexPath *nextIndexPath;

@property (assign, nonatomic) GMLoadingMode dataLoadingMode;
@property (assign, nonatomic) GMLoadingMode contentsLoadingMode;



// public method
- (void)requestLoadingData;
- (void)requestUnloadingData;

// methods which should be overridden
- (void)initializeContents;
- (void)loadContents;
- (void)unloadContents;
- (void)loadDataInBackground;
- (void)unloadData;

- (void)finishLoadingContents;
- (void)finishLoadingData;

@end
