//
//  MyESubviewController.h
//  MyE
//
//  Created by Ye Yuan on 2/7/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// From Apple's Documentation:
//
// "If you want to divide a view hierarchy into multiple subareas and manage each one separately,
// use generic controller objects (custom objects descending from NSObject) instead of view 
// controller objects to manage each subarea. Then use a single view controller object to manage
// the generic controller objects."
//
// http://developer.apple.com/library/ios/#featuredarticles/ViewControllerPGforiPhoneOS/AboutViewControllers/AboutViewControllers.html%23//apple_ref/doc/uid/TP40007457-CH112-SW10

// This is a generic controller class that can be used to handle a subarea. It is modelled after
// UIViewController, but conforms to Apple's recommendation.
//
// Your view controller creates the instances and is responsible for managing the subview controllers.
// Alternatively you can further subdivided your view hierachy and create subview controllers inside
// other subview controllers. In both cases the controller instantiating the object is responsible for
// managing the subview controller. The responsible controller is referred to as 'parent controller.' 
// Subclasses can use the view controller when they for example need to show a modal dialog.
// 
// Methods that the parent controller should call at the apropriate times are:
// 
// - (void)viewWillAppear:(BOOL)animated;
// - (void)viewDidAppear:(BOOL)animated;
// - (void)viewWillDisappear:(BOOL)animated;
// - (void)viewDidDisappear:(BOOL)animated;
//
// - (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
// - (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration;
// - (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;
// - (void)willAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
// - (void)didAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
// - (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration;
//
// - (void)didReceiveMemoryWarning;
//
// Subclasses should always call [super didReceiveMemoryWarning]. This is recommended for all other 
// methods listed above as well.
//
// The loading of the view is similar to how UIViewController loads it views. You can either use the 
// nib based loading, or load the view in -loadView. Do not call [super loadView] in your subclass!
//

@interface MyESubviewController : NSObject {
    NSString *nibName;
    NSBundle *nibBundle;
    IBOutlet UIView *view;
    UIViewController *viewController;
    id parentController;
    BOOL loadFromNib;
}

#pragma mark - Creating a Subview Controller Using Nib Files
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle viewController:(UIViewController *)viewController parentController:(id)parentController;
@property (nonatomic, copy) NSString *nibName;
@property (nonatomic, readonly, retain) NSBundle *nibBundle;

#pragma mark - Managing the View
@property (nonatomic, retain) IBOutlet UIView *view;
- (void)loadView;
- (void)viewDidLoad;
- (void)viewDidUnload;
- (BOOL)isViewLoaded;

#pragma mark - Responding to View Events
- (void)viewWillAppear:(BOOL)animated;
- (void)viewDidAppear:(BOOL)animated;
- (void)viewWillDisappear:(BOOL)animated;
- (void)viewDidDisappear:(BOOL)animated;

#pragma mark - Handling View Rotations
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration;
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;

// Only uncomment this if you actually use this method.
//- (void)willAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
//- (void)didAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
//- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration;

#pragma mark - Handling Memory Warnings
- (void)didReceiveMemoryWarning;

#pragma mark - Getting Other Related View Controllers
@property (nonatomic, readonly) UIViewController *viewController;
@property (nonatomic, readonly) id parentController;

@end
