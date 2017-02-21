//
//  CKBarXaxisBarView.h
//  ChartKit
//
//  Created by yxiang on 2017/2/10.
//  Copyright © 2017年 yxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKBarXaxisBarView : UIView

- (instancetype)initXaxisBarViewWithFrame:(CGRect)frame colors:(NSArray *)aColors controlSpace:(CGFloat)aSpace;

@property (copy, nonatomic) UIFont *titleFont; /// Bottom label.font.

@property (copy, nonatomic) NSString *titleText; /// Bottom label.text.

@property (copy, nonatomic) UIColor *titleColor; /// Bottom label.textColor.

@property (copy, nonatomic) UIColor *barBackgroundColor; /// Progress bar background color.

@property (assign, nonatomic) CGFloat labelWidth; /// Label.frame.width. Default frame.width.

@property (assign, nonatomic) NSTimeInterval duration; /// Animation duration. Default is 1s.

@property (assign, nonatomic, readonly) CGFloat currentProgress; /// Current percent.

@property (assign, nonatomic, readonly) BOOL isAnimation; // Animation state.

@property (copy, nonatomic) void (^didClickedBlock) (__weak CKBarXaxisBarView *sender); /// Called when touchBegan.

/**
 *  Change the current progress.
 *  - Make sure that the view is loaded when this method is called, otherwise it will not do anything, such as:
 *
 *  - (void)viewDidAppear:(BOOL)animated {
 *      [xaxis setProgress:1 animation:YES];
 *  }
 *  - Make sure that this method is called after the last animation has finished.
 *
 *  @param aPercen The progress you want to change to, between 0 and 1.
 *  @param flag Whether the animation shows. */
- (void)setProgress:(CGFloat)aPercen animation:(BOOL)flag;

@end
