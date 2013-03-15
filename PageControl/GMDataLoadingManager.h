//
//  GMDataLoadingManager.h
//  PageControl
//
//  Created by Jooyoung Lee on 14/03/13.
//  Copyright (c) 2013 Jooyoung Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GMDataLoadingDelegate

- (void)dataLoadingShouldStart;
- (void)dataLoadingDidCancel;

@end

@interface GMDataLoadingManager : NSObject

+ (GMDataLoadingManager *)sharedInstance;

- (void)addWorkingWithIndexPath:(NSIndexPath *)indexPath
                       delegate:(id<GMDataLoadingDelegate>)delegate
                sideIndexPathes:(NSArray *)sideIndexPathes;

- (void)removeWorkingWithIndexPath:(NSIndexPath *)indexPath;

@end
