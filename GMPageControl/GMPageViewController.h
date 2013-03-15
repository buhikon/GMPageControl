//
//  GMPageViewController.h
//  PageControl
//
//  Created by Jooyoung Lee on 14/03/13.
//  Copyright (c) 2013 Jooyoung Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GMPageViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (strong, nonatomic) NSMutableArray *dataViewControllers;  // ARRAY(section) of ARRAY(row) of GMDataViewController
@property (strong, nonatomic) NSIndexPath *indexPath;

@end
