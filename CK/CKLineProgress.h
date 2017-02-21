//
//  CKLineProgress.h
//  ChartKit
//
//  Created by yxiang on 2017/2/8.
//  Copyright © 2017年 yxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface CKLineProgress : UIView

/**
 *  Initializes the line progress bar view.
 *  @param frame The view shows the range.
 *  @param aLineWidth A gradient type enum.
 *  @return Progress object. */
- (CKLineProgress *)initLineProgressWithRect:(CGRect)frame colors:(NSArray *)aColors lineWidth:(CGFloat)aLineWidth;
+ (CKLineProgress *)lineProgressWithRect:(CGRect)frame colors:(NSArray *)aColors lineWidth:(CGFloat)aLineWidth;

@property (copy, nonatomic) UIColor *lineBackColor; // Background color of progress bar. Default is 0xf8dbbd.

@property (assign, nonatomic, readonly) CGFloat currentProgress; // Current Progress. Readonly.

@property (assign, nonatomic) NSTimeInterval duration;// Animation duration. Default is 1s.

@property (assign, nonatomic, readonly) BOOL isAnimation; // Animation state.

@property (assign, nonatomic) BOOL isRound; // Cap is round. Default is NO.

/**
 *  Change the current progress.
 *  - Make sure that the view is loaded when this method is called, otherwise it will not do anything, such as:
 *
 *  - (void)viewDidAppear:(BOOL)animated {
 *      [lProgress setProgress:1 animation:YES];
 *  }
 *  - Make sure that this method is called after the last animation has finished.
 *
 *  @param progress The progress you want to change to, between 0 and 1.
 *  @param flag Whether the animation shows. */
- (void)setProgress:(CGFloat)progress animation:(BOOL)flag;

/**
 *  Add a click event.
 *  @param aTarget Execute the object.
 *  @param aSelector Perform the operation. */
- (void)addTagert:(id)aTarget forSelector:(SEL)aSelector;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface CKLineProgress (Unavailable)

- (instancetype)initWithFrame:(CGRect)frame __attribute__((unavailable));
- (instancetype)init __attribute__((unavailable));
- (void)setFrame:(CGRect)frame __attribute__((unavailable));
- (void)setBounds:(CGRect)bounds __attribute__((unavailable));
- (void)setCenter:(CGPoint)center __attribute__((unavailable));
- (void)setNeedsDisplay __attribute__((unavailable));
- (void)setNeedsDisplayInRect:(CGRect)rect __attribute__((unavailable));

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
