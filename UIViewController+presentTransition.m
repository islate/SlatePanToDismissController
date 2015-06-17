//
//  UIViewController+presentTransition.m
//  Slate
//
//  Created by yizelin on 13-11-22.
//  Copyright (c) 2013年 Modern Mobile Digital Media Company Limited. All rights reserved.
//

#import "UIViewController+presentTransition.h"

#import <objc/runtime.h>

#define IsIOS7AND8 ([[UIDevice currentDevice].systemVersion intValue] >= 7.0 && [[UIDevice currentDevice].systemVersion intValue] < 9.0)
#define IsIOS8 ([[UIDevice currentDevice].systemVersion intValue] >= 8.0 && [[UIDevice currentDevice].systemVersion intValue] < 9.0)

#ifndef DLog
#  ifdef DEBUG
#    define DLog(...) NSLog(__VA_ARGS__)
#  else
#    define DLog(...) /* */
#  endif
#endif

#ifndef ALog
#  define ALog(...) NSLog(__VA_ARGS__)
#endif

static char UIViewControllerDismissWithPanGestureRecognizer;
static char UIViewControllerDismissWithPanGestureRecognizerDelegate;
static char UIViewControllerLeftShadow;
static char UIViewControllerDismissWithStatusBarChange;
static char UIViewControllerBeforeDismissStatusBarStyle;
static char UIViewControllerAfterDismissStatusBarStyle;

const CGFloat kTranslationX = - 320.0f / 4.0f;
const CGFloat kDuration = 0.3f;

@interface AnimatedDelegate : NSObject <UIViewControllerAnimatedTransitioning>

@end

@implementation AnimatedDelegate

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return kDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *presentedViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *presentingViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [[transitionContext containerView] addSubview:presentedViewController.view];
    
    // 动画效果
    presentedViewController.view.transform = CGAffineTransformMakeTranslation(presentedViewController.view.bounds.size.width, 0.0f);
    
    [UIView animateWithDuration:kDuration
                     animations:^{
                         presentedViewController.view.transform = CGAffineTransformIdentity;
                         presentingViewController.view.transform = CGAffineTransformMakeTranslation(kTranslationX, 0.0f);
                     }
                     completion:^(BOOL finished) {
                         presentingViewController.view.transform = CGAffineTransformIdentity;
                         [transitionContext completeTransition:YES];
                     }
     ];
}

@end


@interface PresentationController : UIPresentationController

@end

@implementation PresentationController

- (void)presentationTransitionWillBegin
{
    UIViewController *presentedViewController = self.presentedViewController;
    
    // 添加左侧的阴影
    UIImage *shadowImage = [UIImage imageNamed:@"misc/iphone_left_drawer_shadow"];
    if (shadowImage)
    {
        UIImageView *leftShadow = objc_getAssociatedObject(presentedViewController, &UIViewControllerLeftShadow);
        if (!leftShadow)
        {
            leftShadow = [[UIImageView alloc] initWithFrame:CGRectMake(-11, 0, 11, presentedViewController.view.bounds.size.height)];
            leftShadow.image = shadowImage;
            [presentedViewController.view addSubview:leftShadow];
            
            objc_setAssociatedObject(presentedViewController, &UIViewControllerLeftShadow,
                                     leftShadow,
                                     OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
}

@end


@interface TransitoningDelegate : NSObject <UIViewControllerTransitioningDelegate>

@end

@implementation TransitoningDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [[AnimatedDelegate alloc] init];
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source
{
    return [[PresentationController alloc] initWithPresentedViewController:presented
                                                  presentingViewController:presenting];
}

@end


@interface DismissWithPanGestureRecognizerDelegate : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIView *view;

@end

@implementation UIViewController (presentTransition)

@dynamic dismissWithPanGestureRecognizer;
@dynamic dismissWithPanGestureRecognizerDelegate;
@dynamic dismissWithStatusBarChange;
@dynamic beforeDismissStatusBarStyle;
@dynamic afterDismissStatusBarStyle;

#pragma mark - present or dismiss with custom flip transition

- (void)presentFrom:(UIViewController *)viewController animated:(BOOL)animated
{
    if (IsIOS8)
    {
        self.modalPresentationStyle = UIModalPresentationCustom;
        TransitoningDelegate *delegate = [[TransitoningDelegate alloc] init];
        self.transitioningDelegate = delegate;
        [viewController presentViewController:self animated:animated completion:nil];
    }
    else
    {
        UIModalPresentationStyle oldStyle = viewController.modalPresentationStyle;
        viewController.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentActionWithViewController:viewController animated:animated];
        viewController.modalPresentationStyle = oldStyle;
    }
}

- (void)presentActionWithViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
    __weak __typeof(self) weakSelf = self;
    __weak __typeof(viewController) weakPresentingViewController = viewController;
    
    @try {
        [viewController presentViewController:self animated:NO completion:^{
            
            if (!weakSelf || !weakPresentingViewController) {
                return;
            }
            
            // 添加左侧的阴影
            UIImage *shadowImage = [UIImage imageNamed:@"misc/iphone_left_drawer_shadow"];
            if (shadowImage)
            {
                UIImageView *leftShadow = objc_getAssociatedObject(weakSelf, &UIViewControllerLeftShadow);
                if (!leftShadow)
                {
                    leftShadow = [[UIImageView alloc] initWithFrame:CGRectMake(-11, 0, 11, self.view.bounds.size.height)];
                    leftShadow.image = shadowImage;
                    [weakSelf.view addSubview:leftShadow];
                    
                    objc_setAssociatedObject(weakSelf, &UIViewControllerLeftShadow,
                                             leftShadow,
                                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                }
            }
            
            // 动画效果
            if (animated)
            {
                weakSelf.view.transform = CGAffineTransformMakeTranslation(weakSelf.view.bounds.size.width, 0.0f);
                
                [UIView animateWithDuration:kDuration
                                 animations:^{
                                     weakSelf.view.transform = CGAffineTransformIdentity;
                                     weakPresentingViewController.view.transform = CGAffineTransformMakeTranslation(kTranslationX, 0.0f);
                                 }
                                 completion:^(BOOL finished) {
                                     weakPresentingViewController.view.transform = CGAffineTransformIdentity;
                                 }
                 ];
            }
            
        }];
        
    }
    @catch (NSException *exception) {
        ALog(@"%@", exception);
    }
}

- (void)dismissAnimated:(BOOL)animated
{
    if (self.presentingViewController)
    {
        if (IsIOS8)
        {
            self.transitioningDelegate = nil;
        }
        
        if (!animated) {
            [self dismissViewControllerAnimated:NO completion:nil];
            return;
        }
        
        __weak __typeof(self) weakSelf = self;
        __weak __typeof(self.presentingViewController) weakPresentingViewController = self.presentingViewController;

        self.presentingViewController.view.transform = CGAffineTransformMakeTranslation(kTranslationX, 0.0f);

        [UIView animateWithDuration:kDuration
                         animations:^{
                             weakSelf.view.transform = CGAffineTransformMakeTranslation(weakSelf.view.bounds.size.width, 0.0f);
                             weakPresentingViewController.view.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished) {
                             [weakSelf dismissViewControllerAnimated:NO completion:nil];
                         }
         ];
        
        if (self.dismissWithStatusBarChange)
        {
            if (IsIOS7AND8)
            {
                [[UIApplication sharedApplication] setStatusBarStyle:self.afterDismissStatusBarStyle animated:NO];
            }
        }
    }
}

#pragma mark - dismiss with pan gesture

- (UIPanGestureRecognizer *)dismissWithPanGestureRecognizer
{
    UIPanGestureRecognizer *_dismissWithPanGestureRecognizer = objc_getAssociatedObject(self, &UIViewControllerDismissWithPanGestureRecognizer);
    
    if (!_dismissWithPanGestureRecognizer)
    {
        _dismissWithPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dismissWithPanGestureRecognized:)];
        objc_setAssociatedObject(self, &UIViewControllerDismissWithPanGestureRecognizer,
                                 _dismissWithPanGestureRecognizer,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self.view addGestureRecognizer:_dismissWithPanGestureRecognizer];
        _dismissWithPanGestureRecognizer.enabled = NO;   // default is disabled
        _dismissWithPanGestureRecognizer.delegate = self.dismissWithPanGestureRecognizerDelegate;
    }
    return _dismissWithPanGestureRecognizer;
}

- (void)dismissWithPanGestureRecognized:(UIPanGestureRecognizer *)recognizer
{
    UIViewController *presentingViewController = self.navigationController.presentingViewController;
    if (!presentingViewController) {
        presentingViewController = self.presentingViewController;
        if (!presentingViewController) {
            return;
        }
    }
    
    UIViewController *presentedViewController = self.navigationController;
    if (!presentedViewController) {
        presentedViewController = self;
    }
    
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        if (self.dismissWithStatusBarChange)
        {
            if (IsIOS7AND8)
            {
                CGFloat x = [recognizer translationInView:self.view].x;
                if (x > 0)
                {
                    [[UIApplication sharedApplication] setStatusBarStyle:self.afterDismissStatusBarStyle animated:NO];
                }
            }
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGFloat x = [recognizer translationInView:self.view].x;
        CGFloat animatePercent = 0.0f;
        animatePercent = (self.view.bounds.size.width - x) / self.view.bounds.size.width;
        CGFloat newTranslation = kTranslationX - kTranslationX * (1 - animatePercent);
        presentedViewController.view.transform = CGAffineTransformMakeTranslation(MAX(0.0f, x), 0.0f);
        presentingViewController.view.transform = CGAffineTransformMakeTranslation(newTranslation, 0.0);
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded ||
             recognizer.state == UIGestureRecognizerStateCancelled ||
             recognizer.state == UIGestureRecognizerStateFailed)
    {
        CGFloat x = [recognizer translationInView:self.view].x;
        CGFloat vx = [recognizer velocityInView:self.view].x;
        __weak __typeof(presentedViewController) weakPresentedViewController = presentedViewController;
        __weak __typeof(presentingViewController) weakPresentingViewController = presentingViewController;
        
        if ((vx > -20.0f && x > 120.0f) || (vx > 500.0f && x > 60.0f))
        {
            // 弹出
            [UIView animateWithDuration:kDuration
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 weakPresentedViewController.view.transform = CGAffineTransformMakeTranslation(weakPresentedViewController.view.bounds.size.width, 0);
                                 weakPresentingViewController.view.transform = CGAffineTransformIdentity;
                             }
                             completion:^(BOOL finished){
                                 [weakPresentedViewController dismissViewControllerAnimated:NO completion:nil];
                             }];
            
        }
        else
        {
            // 恢复
            [UIView animateWithDuration:kDuration
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 weakPresentedViewController.view.transform = CGAffineTransformIdentity;
                                 weakPresentingViewController.view.transform = CGAffineTransformMakeTranslation(kTranslationX, 0);
                             }
                             completion:^(BOOL finished){
                                 weakPresentingViewController.view.transform = CGAffineTransformIdentity;
                             }];
            
            if (self.dismissWithStatusBarChange)
            {
                if (IsIOS7AND8)
                {
                    [[UIApplication sharedApplication] setStatusBarStyle:self.beforeDismissStatusBarStyle animated:NO];
                }
            }
        }
    }
}

#pragma mark - dismissWithPanGestureRecognizer delegate

- (id<UIGestureRecognizerDelegate>)dismissWithPanGestureRecognizerDelegate
{
    DismissWithPanGestureRecognizerDelegate *_dismissWithPanGestureRecognizerDelegate = objc_getAssociatedObject(self, &UIViewControllerDismissWithPanGestureRecognizerDelegate);
    
    if (!_dismissWithPanGestureRecognizerDelegate)
    {
        _dismissWithPanGestureRecognizerDelegate = DismissWithPanGestureRecognizerDelegate.new;
        objc_setAssociatedObject(self, &UIViewControllerDismissWithPanGestureRecognizerDelegate,
                                 _dismissWithPanGestureRecognizerDelegate,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        _dismissWithPanGestureRecognizerDelegate.view = self.view;
    }
    return _dismissWithPanGestureRecognizerDelegate;
}

#pragma mark - dismiss with statusbar change

- (void)setDismissWithStatusBarChange:(BOOL)dismissWithStatusBarChange
{
    NSNumber *_dismissWithStatusBarChange = [NSNumber numberWithBool:dismissWithStatusBarChange];
    objc_setAssociatedObject(self, &UIViewControllerDismissWithStatusBarChange,
                             _dismissWithStatusBarChange,
                             OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)dismissWithStatusBarChange
{
    NSNumber *_dismissWithStatusBarChange = objc_getAssociatedObject(self, &UIViewControllerDismissWithStatusBarChange);
    return [_dismissWithStatusBarChange boolValue];
}

- (void)setBeforeDismissStatusBarStyle:(UIStatusBarStyle)beforeDismissStatusBarStyle
{
    NSNumber *_beforeDismissStatusBarStyle = [NSNumber numberWithInt:beforeDismissStatusBarStyle];
    objc_setAssociatedObject(self, &UIViewControllerBeforeDismissStatusBarStyle,
                             _beforeDismissStatusBarStyle,
                             OBJC_ASSOCIATION_ASSIGN);
}

- (UIStatusBarStyle)beforeDismissStatusBarStyle
{
    NSNumber *_beforeDismissStatusBarStyle = objc_getAssociatedObject(self, &UIViewControllerBeforeDismissStatusBarStyle);
    return [_beforeDismissStatusBarStyle intValue];
}

- (void)setAfterDismissStatusBarStyle:(UIStatusBarStyle)afterDismissStatusBarStyle
{
    NSNumber *_afterDismissStatusBarStyle = [NSNumber numberWithInt:afterDismissStatusBarStyle];
    objc_setAssociatedObject(self, &UIViewControllerAfterDismissStatusBarStyle,
                             _afterDismissStatusBarStyle,
                             OBJC_ASSOCIATION_ASSIGN);
}

- (UIStatusBarStyle)afterDismissStatusBarStyle
{
    NSNumber *_afterDismissStatusBarStyle = objc_getAssociatedObject(self, &UIViewControllerAfterDismissStatusBarStyle);
    return [_afterDismissStatusBarStyle intValue];
}

@end

@implementation DismissWithPanGestureRecognizerDelegate

// called when a gesture recognizer attempts to transition out of UIGestureRecognizerStatePossible. returning NO causes it to transition to UIGestureRecognizerStateFailed
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
    {
        return NO;
    }
    
    UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)gestureRecognizer;
    CGPoint translation = [panGesture translationInView:self.view];
    CGPoint velocity = [panGesture velocityInView:self.view];
    
    if (velocity.x > 0 && velocity.x < 600.0 && (sqrt(translation.x * translation.x) / sqrt(translation.y * translation.y) > 1))
    {
        // 向右pan，并且是横向的pan，速度不超过600
        // 为了不影响界面内scrollview tableview的手势
        return YES;
    }

    return NO;
}

@end

