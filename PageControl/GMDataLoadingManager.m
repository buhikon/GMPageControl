//
//  GMDataLoadingManager.m
//  PageControl
//
//  Created by Jooyoung Lee on 14/03/13.
//  Copyright (c) 2013 Jooyoung Lee. All rights reserved.
//

#import "GMDataLoadingManager.h"

@interface GMDataLoadingManager ()
{
    BOOL _loop;
}

@property (strong, nonatomic) NSMutableArray *waitingQueue;
@property (strong, nonatomic) NSMutableArray *performingQueue;

@end

@implementation GMDataLoadingManager

static int max_performing_cnt = 2;

#pragma mark - Singleton

static GMDataLoadingManager *instance = nil;

+ (GMDataLoadingManager *)sharedInstance
{
    @synchronized(self)
    {
        if (!instance) {
            instance = [[GMDataLoadingManager alloc] init];
        }
        return instance;
    }
}

#pragma mark -

- (NSMutableArray *)waitingQueue
{
    if( !_waitingQueue ) {
        _waitingQueue = [[NSMutableArray alloc] init];
    }
    return _waitingQueue;
}
- (NSMutableArray *)performingQueue
{
    if( !_performingQueue ) {
        _performingQueue = [[NSMutableArray alloc] init];
    }
    return _performingQueue;
}


#pragma mark -

- (void)addWorkingWithIndexPath:(NSIndexPath *)indexPath
                       delegate:(id<GMDataLoadingDelegate>)delegate
                sideIndexPathes:(NSArray *)sideIndexPathes
{
    NSDictionary *working = @{@"indexPath" : indexPath, @"delegate" : (id)delegate};
    
    for(int i=self.waitingQueue.count-1; i>=0; i--) {
        
        NSDictionary *waiting = [self.waitingQueue objectAtIndex:i];
        NSIndexPath *waitingIndexPath = [waiting objectForKey:@"indexPath"];
        id<GMDataLoadingDelegate> waitingDelegate = [waiting objectForKey:@"delegate"];
        
        // delete duplicate workings from waiting queue
        if( [waitingIndexPath isEqual:indexPath] ) {
            [waitingDelegate dataLoadingDidCancel];
            [self.waitingQueue removeObjectAtIndex:i];
            continue;
        }
        
        // delete workings from waiting queue, if its IndexPath does NOT exist in sideIndexPathes
        BOOL shouldDelete = YES;
        for (NSIndexPath *sideIndexPath in sideIndexPathes) {
            if( [waitingIndexPath isEqual:sideIndexPath] ) {
                shouldDelete = NO;
                break;
            }
        }
        if( shouldDelete ) {
            [waitingDelegate dataLoadingDidCancel];
            [self.waitingQueue removeObjectAtIndex:i];
        }
    }
    
    // insert job at first in the waiting queue!
    [self.waitingQueue insertObject:working atIndex:0];
    
    
    
    [self performWorkingsIfPossible];
}

- (void)removeWorkingWithIndexPath:(NSIndexPath *)indexPath
{
    // remove all objects which have same IndexPath as the parameter.
    for(int i=self.performingQueue.count-1; i>=0; i--) {
        NSDictionary *working = [self.performingQueue objectAtIndex:i];
        NSIndexPath *workingIndexPath = [working objectForKey:@"indexPath"];
        if(workingIndexPath.section == indexPath.section && workingIndexPath.row == indexPath.row) {
            [self.performingQueue removeObjectAtIndex:i];
        }
    }
    
    // now some spaces are available on performingQueue
    [self performWorkingsIfPossible];
}

- (void)performWorkingsIfPossible
{
    [self performSelectorOnMainThread:@selector(performWorkingsIfPossibleAction) withObject:nil waitUntilDone:NO];
}
- (void)performWorkingsIfPossibleAction
{
    //NSLog(@"performWorkingsIfPossibleAction... waiting:%d, performing:%d", self.waitingQueue.count, self.performingQueue.count);
    //NSLog(@"performWorkingsIfPossibleAction... waiting:%d, performing:%d (%@)", self.waitingQueue.count, self.performingQueue.count, self.performingQueue);
    
    @try {

        for (int i=self.performingQueue.count; i<max_performing_cnt; i++) {
            if( self.waitingQueue.count == 0 ) break;

            NSDictionary *working = [self.waitingQueue objectAtIndex:0];
            [self.performingQueue addObject:working];
            [self.waitingQueue removeObjectAtIndex:0];
            
            [self loadContents:working];
        }

    }
    @catch (NSException *exception) {
        NSLog(@"Error! performWorkingsIfPossible");
    }
    @finally {}
}


- (void)loadContents:(NSDictionary *)working
{
    //NSIndexPath *indexPath = [working objectForKey:@"indexPath"];
    id<GMDataLoadingDelegate> delegate = [working objectForKey:@"delegate"];
    
    [delegate dataLoadingShouldStart];

}

@end
