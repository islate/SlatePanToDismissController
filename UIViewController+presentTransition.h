//
//  UIViewController+presentTransition.h
//  Slate
//
//  Created by yizelin on 13-11-22.
//  Copyright (c) 2013年 Modern Mobile Digital Media Company Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  特殊present/dismiss效果的UIViewController类别
 *  1、present时向左滑动进入
 *  2、dismiss时向右滑动退出
 *  3、可以用pan手势来dismiss
 */
@interface UIViewController (presentTransition)

@property (nonatomic, strong, readonly) UIPanGestureRecognizer *dismissWithPanGestureRecognizer;
@property (nonatomic, strong, readonly) id<UIGestureRecognizerDelegate> dismissWithPanGestureRecognizerDelegate;

/**
 *  dismissWithStatusBarChange=YES  dismiss过程中，改变statusbar的样式
 *  dismissWithStatusBarChange=NO   不改变dismiss前后statusbar样式
 *
 *  beforeDismissStatusBarStyle     dismiss之前的statusbar样式
 *  afterDismissStatusBarStyle      dismiss之后的statusbar样式
 */
@property (nonatomic, assign) BOOL dismissWithStatusBarChange;
@property (nonatomic, assign) UIStatusBarStyle beforeDismissStatusBarStyle;
@property (nonatomic, assign) UIStatusBarStyle afterDismissStatusBarStyle;

/**
 *  present方法
 *
 *  @param viewController 在这个controller之上弹出
 *  @param animated       是否有向左滑动进入效果
 */
- (void)presentFrom:(UIViewController *)viewController animated:(BOOL)animated;

/**
 *  dismiss方法
 *
 *  @param animated 是否有向右滑动退出效果
 */
- (void)dismissAnimated:(BOOL)animated;

@end
