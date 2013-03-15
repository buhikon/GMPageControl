//
//  GMPageViewController.m
//  PageControl
//
//  Created by Jooyoung Lee on 14/03/13.
//  Copyright (c) 2013 Jooyoung Lee. All rights reserved.
//

#import "GMPageViewController.h"
#import "GMDataViewController.h"

@interface GMPageViewController ()
{
    BOOL _pageIsAnimating;
}

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (weak, nonatomic) IBOutlet UIView *pageViewControllerPosition;
@property (strong, nonatomic) NSTimer *eventBlockTimer;

@end

@implementation GMPageViewController

#pragma mark -
- (UIPageViewController *)pageViewController
{
    if( !_pageViewController ) {
        _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:nil];
        _pageViewController.dataSource = self;
        _pageViewController.delegate = self;
        _pageViewController.view.frame = self.pageViewControllerPosition.bounds;
        [self.pageViewControllerPosition addSubview:_pageViewController.view];
        
        NSLog(@"self.pageViewControllerPosition.frame : %@", NSStringFromCGRect(self.pageViewControllerPosition.frame));
        NSLog(@"_pageViewController.view.frame : %@", NSStringFromCGRect(_pageViewController.view.frame));
        
        
        [self validateIndexPath];
        
        GMDataViewController *firstDataViewController = [self viewControllerAtIndexPath:self.indexPath];
        [_pageViewController setViewControllers:@[firstDataViewController]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
        
        [self addChildViewController:self.pageViewController];
        
        // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
        self.pageViewControllerPosition.gestureRecognizers = self.pageViewController.gestureRecognizers;

    }
    return _pageViewController;
}

#pragma mark -

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
    
    
    _pageIsAnimating = NO;

    
    // initialization
    for(int i=0; i<self.dataViewControllers.count; i++) {
        NSArray *arr = [self.dataViewControllers objectAtIndex:i];
        for(int j=0; j<arr.count; j++) {
            GMDataViewController *dataViewController = [arr objectAtIndex:j];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
            NSIndexPath *prevIndexPath = [self prevIndexPathForIndexPath:indexPath];
            NSIndexPath *nextIndexPath = [self nextIndexPathForIndexPath:indexPath];
            
            dataViewController.indexPath = indexPath;
            dataViewController.prevIndexPath = prevIndexPath;
            dataViewController.nextIndexPath = nextIndexPath;
            
        }
    }
    
    [self pageViewController];
    [self updateDataViewControllers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (GMDataViewController *)viewControllerAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        return [[self.dataViewControllers objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    @catch (NSException *exception) {
        NSLog(@"Error! viewControllerAtIndexPath: (%d, %d)", indexPath.section, indexPath.row);
        return nil;
    }
    @finally {}
    
}


- (int)numberOfSections
{
    @try {
        return self.dataViewControllers.count;
    }
    @catch (NSException *exception) {
        NSLog(@"Error! numberOfSections");
        return 0;
    }
    @finally {}
}

- (int)numberOfRowsForSection:(int)sectionIndex
{
    @try {
        return [[self.dataViewControllers objectAtIndex:sectionIndex] count];
    }
    @catch (NSException *exception) {
        NSLog(@"Error! numberOfRowsForSection: %d", sectionIndex);
        return 0;
    }
    @finally {}
}

- (NSIndexPath *)nextIndexPathForIndexPath:(NSIndexPath *)indexPath
{
    int nextSection = indexPath.section;
    int nextIndex = indexPath.row;
    
    int maximumPage = [self numberOfRowsForSection:indexPath.section];
    
    if( nextIndex + 1 < maximumPage )
        nextIndex++;
    else {
        
        BOOL exist = NO;
        
        // find next section (if maximum page of section is 0, ignore!)
        while ( ++nextSection < [self numberOfSections] ) {
            
            int nextMaximumPage = [self numberOfRowsForSection:nextSection];
            
            if( nextMaximumPage > 0 ) {
                exist = YES;
                nextIndex = 0;
                break;
            }
        }
        
        // if no more next section, use current.
        if( !exist ) {
            nextSection = indexPath.section;
            nextIndex = indexPath.row;
        }
        
    }
    return [NSIndexPath indexPathForRow:nextIndex inSection:nextSection];
}

- (NSIndexPath *)prevIndexPathForIndexPath:(NSIndexPath *)indexPath
{
    int prevSection = indexPath.section;
    int prevIndex = indexPath.row;
    
    if( prevIndex > 0 ) {
        prevIndex--;
    }
    else {
        
        BOOL exist = NO;
        
        // find prev section (if maximum page of section is 0, ignore!)
        while ( --prevSection >= 0 ) {
            
            int prevMaximumPage = [self numberOfRowsForSection:prevSection];
            
            if( prevMaximumPage > 0 ) {
                exist = YES;
                prevIndex = [self numberOfRowsForSection:prevSection] - 1;;
                break;
            }
        }
        
        // if no more prev section, use current.
        if( !exist ) {
            prevSection = indexPath.section;
            prevIndex = indexPath.row;
        }
    }
    return [NSIndexPath indexPathForRow:prevIndex inSection:prevSection];
}

// check if IndexPath is valid or not
- (BOOL)isValidPageIndexPath:(NSIndexPath *)indexPath
{
    if( 0 > indexPath.section || indexPath.section >= self.dataViewControllers.count )
        return NO;
    
    if( 0 > indexPath.row || indexPath.row >= [[self.dataViewControllers objectAtIndex:self.indexPath.section] count] )
        return NO;
    
    return YES;
}

// get the number of all pages before the section
- (int)startIndexForSection:(int)sectionIndex
{
    if( self.dataViewControllers ) {
        
        sectionIndex = MIN(sectionIndex, self.dataViewControllers.count);
        
        int sum = 0;
        for(int i=0; i < sectionIndex; i++) {
            sum += [self numberOfRowsForSection:i];
        }
        return sum;
        
    }
    else
        return 0;
}

- (int)indexForIndexPath:(NSIndexPath *)indexPath
{
    if( [self isValidPageIndexPath:indexPath] ) {
        return [self startIndexForSection:indexPath.section]+ indexPath.row;
    }
    else
        return 0;
}

// if current indexPath has wrong data, clear it.
- (void)validateIndexPath
{
    if( self.indexPath.section >= self.dataViewControllers.count) {
        self.indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        return;
    }
    if( self.indexPath.row >= [[self.dataViewControllers objectAtIndex:self.indexPath.section] count] ) {
        self.indexPath = [NSIndexPath indexPathForRow:self.indexPath.section inSection:0];
        return;
    }
}

#pragma mark -

- (void)disableEvent
{
    if( self.eventBlockTimer ) {
        [self.eventBlockTimer invalidate];
        self.eventBlockTimer = nil;
    }
//    _pageIsAnimating = YES;
    self.view.userInteractionEnabled = NO;
    
    self.eventBlockTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                           target:self
                                                         selector:@selector(enableEvent)
                                                         userInfo:nil
                                                          repeats:NO];
}

- (void)enableEvent
{
//    _pageIsAnimating = NO;
    self.view.userInteractionEnabled = YES;
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSLog(@"BEFORE ... _pageIsAnimating : %d", _pageIsAnimating);
    
//    if (_pageIsAnimating)
//        return nil;

    GMDataViewController *dataViewController = (GMDataViewController *)viewController;
    NSIndexPath *indexPath = dataViewController.indexPath;
    NSIndexPath *prevIndexPath = [self prevIndexPathForIndexPath:indexPath];
    
    NSLog(@"      indexPath : %d,%d ... prev : %d,%d", indexPath.section,indexPath.row,prevIndexPath.section,prevIndexPath.row);
    
    if( [indexPath isEqual:prevIndexPath] ) {
        return nil;
    }
    else {
        [self disableEvent];
        
        self.indexPath = prevIndexPath;
        
        GMDataViewController *prevDataViewController = [self viewControllerAtIndexPath:prevIndexPath];
        return prevDataViewController;
    }
         
    
}
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSLog(@"NEXT ... _pageIsAnimating : %d", _pageIsAnimating);
    
//    if (_pageIsAnimating)
//        return nil;


    GMDataViewController *dataViewController = (GMDataViewController *)viewController;
    NSIndexPath *indexPath = dataViewController.indexPath;
    NSIndexPath *nextIndexPath = [self nextIndexPathForIndexPath:indexPath];
    
    NSLog(@"      indexPath : %d,%d ... next : %d,%d", indexPath.section,indexPath.row,nextIndexPath.section,nextIndexPath.row);
    
    if( [indexPath isEqual:nextIndexPath] ) {
        return nil;
    }
    else {
        [self disableEvent];
        
        self.indexPath = nextIndexPath;
        
        GMDataViewController *nextDataViewController = [self viewControllerAtIndexPath:nextIndexPath];
        return nextDataViewController;

    }
}

#pragma mark - UIPageViewControllerDelegate

//- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
//    
//}


- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    NSLog(@"ANIMATION FINISH finished:%d,completed:%d", finished, completed);
    
    //_pageIsAnimating = NO;
    
    if ( completed ) {
        [self updateDataViewControllers];
    }
}

//- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
//{
//    if (UIInterfaceOrientationIsPortrait(orientation) || ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)) {
//        // In portrait orientation or on iPhone: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.
//        
//        UIViewController *currentViewController = self.pageViewController.viewControllers[0];
//        NSArray *viewControllers = @[currentViewController];
//        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
//        
//        self.pageViewController.doubleSided = NO;
//        return UIPageViewControllerSpineLocationMin;
//    }
//    
//    // In landscape orientation: Set set the spine location to "mid" and the page view controller's view controllers array to contain two view controllers. If the current page is even, set it to contain the current and next view controllers; if it is odd, set the array to contain the previous and current view controllers.
//    GMDataViewController *currentViewController = self.pageViewController.viewControllers[0];
//    NSArray *viewControllers = nil;
//    
//    NSUInteger indexOfCurrentViewController = [self indexForIndexPath:currentViewController.indexPath]; //[self.modelController indexOfViewController:currentViewController];
//    if (indexOfCurrentViewController == 0 || indexOfCurrentViewController % 2 == 0) {
//        UIViewController *nextViewController = [self pageViewController:self.pageViewController viewControllerAfterViewController:currentViewController];
//        viewControllers = @[currentViewController, nextViewController];
//    } else {
//        UIViewController *previousViewController = [self pageViewController:self.pageViewController viewControllerBeforeViewController:currentViewController];
//        viewControllers = @[previousViewController, currentViewController];
//    }
//    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
//    
//    
//    return UIPageViewControllerSpineLocationMid;
//}


#pragma mark -

- (void)updateDataViewControllers
{
    NSIndexPath *currentIndexPath = self.indexPath;
    NSIndexPath *prevIndexPath = [self prevIndexPathForIndexPath:self.indexPath];
    NSIndexPath *nextIndexPath = [self nextIndexPathForIndexPath:self.indexPath];
    
    // unload all pages, except current pages [ prev(-1), current(0), next(+1) ]
    for (NSArray *arr in self.dataViewControllers) {
        for (GMDataViewController *dataViewController in arr) {
            if( ![dataViewController.indexPath isEqual:currentIndexPath] &&
               ![dataViewController.indexPath isEqual:prevIndexPath] &&
               ![dataViewController.indexPath isEqual:nextIndexPath] ) {
                
                [dataViewController requestUnloadingData];
            }
        }
    }
    
    // load current pages [ prev(-1), current(0), next(+1) ]
    GMDataViewController *currentDataViewController = [self viewControllerAtIndexPath:currentIndexPath];
    GMDataViewController *prevDataViewController = [self viewControllerAtIndexPath:prevIndexPath];
    GMDataViewController *nextDataViewController = [self viewControllerAtIndexPath:nextIndexPath];
    
    [currentDataViewController requestLoadingData];
    [prevDataViewController requestLoadingData];
    [nextDataViewController requestLoadingData];
}


@end
