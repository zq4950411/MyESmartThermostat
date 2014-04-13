//
//  MyESubviewController.m
//  MyE
//
//  Created by Ye Yuan on 2/7/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyESubviewController.h"

@interface MyESubviewController ()

@property(nonatomic, readwrite, retain) NSBundle *nibBundle;

@end

@implementation MyESubviewController

#pragma mark - Creating a Subview Controller Using Nib Files

- (id)initWithNibName:(NSString *)aNibName bundle:(NSBundle *)aNibBundle viewController:(UIViewController *)aViewController parentController:(id)aParentController {
    NSParameterAssert(aViewController);
    NSParameterAssert(aParentController);
    NSAssert(([aParentController isKindOfClass:[UIViewController class]] || [aParentController isKindOfClass:[MyESubviewController class]]), @"The parent controller should be a (sub)class of UIViewController or a (sub)class of MyESubviewController");
    NSAssert(([aParentController isKindOfClass:[UIViewController class]] ? (aViewController == aParentController) : YES), @"If the parent controller is a (sub)class of UIViewController the parent view controller should be the same instance");
    
    self = [super init];
    if (self) {
        nibName = [aNibName copy];

        viewController = aViewController;
        parentController = aParentController;
        loadFromNib = YES;
    }
    return self;
}

@synthesize nibName;
@synthesize nibBundle;

- (void)dealloc {
    if ([self isViewLoaded]) {
        if (self.view.superview == nil) {
            view = nil;
            [self viewDidUnload];
            NSAssert(view == nil, @"View was reloaded in viewDidUnload");
        } else {
            NSAssert(YES, @"Subview controller is being deallocated whilst its view is still in the view hierarchy");
        }
    }
    nibName = nil;
    nibBundle = nil;
    viewController = nil;
    parentController = nil;

}

#pragma mark - Managing the View
- (UIView *)view {
    if (![self isViewLoaded]) {
        [self willChangeValueForKey:@"isViewLoaded"];
        [self willChangeValueForKey:@"view"];
        [self loadView];
        NSAssert(view != nil, @"View was not loaded");
        [self viewDidLoad];
        [self didChangeValueForKey:@"view"];
        [self didChangeValueForKey:@"isViewLoaded"];
    }
    return view;
}

- (void)setView:(UIView *)anView {
    if (anView != view) {
        view = anView;
    }
}

- (void)loadView {
    NSAssert(view == nil, @"View was already loaded");

    if (loadFromNib) {
        NSBundle *loadBundle = self.nibBundle;
        if (!loadBundle) {
            loadBundle = [NSBundle mainBundle];
        }
        
        NSString *loadName = self.nibName;
        if (!loadName) {
            loadName = NSStringFromClass([self class]);
            self.nibName = loadName;
        }
        [loadBundle loadNibNamed:loadName owner:self options:nil];
    } else {
        view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f)];
    }
    
    NSAssert(view != nil, @"View was not loaded");
}

- (void)viewDidLoad {
    // To be implemented by subclass
}

- (void)viewDidUnload {
    // To be implemented by subclass    
}

- (BOOL)isViewLoaded {
    return (view != nil);
}

#pragma mark - Responding to View Events
- (void)viewWillAppear:(BOOL)animated {
    // To be implemented by subclass
}

- (void)viewDidAppear:(BOOL)animated {
    // To be implemented by subclass
}

- (void)viewWillDisappear:(BOOL)animated {
    // To be implemented by subclass
}

- (void)viewDidDisappear:(BOOL)animated {
    // To be implemented by subclass
}

#pragma mark - Handling View Rotations
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    // To be implemented by subclass
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    // To be implemented by subclass
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    // To be implemented by subclass
}

//- (void)willAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//    // To be implemented by subclass
//}
//
//- (void)didAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
//    // To be implemented by subclass
//}
//
//- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration {
//    // To be implemented by subclass
//}

#pragma mark - Handling Memory Warnings
- (void)didReceiveMemoryWarning {
    // If our view is loaded, but not in use (superview is nil), release it
    if ([self isViewLoaded]) {
        if (self.view.superview == nil) {
            self.view = nil;
            [self viewDidUnload];
        }
    }
}

#pragma mark - Getting Other Related View Controllers
@synthesize viewController;
@synthesize parentController;

@end
