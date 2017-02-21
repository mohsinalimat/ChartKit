//
//  CKRoundProgress.h
//  ChartKit
//
//  Created by yxiang on 2017/2/7.
//  Copyright © 2017年 yxiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKCountingLabel.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

typedef NS_ENUM(NSInteger, CKRoundProgressGradientType) {
    CKRPGAngle, // Angle gradient.
    CKRPGLine   // Line gradient.
};

@interface CKRoundProgress : UIView

/**
 *  Initializes the circular progress bar view.
 *  @param frame The view shows the range. To the width of the high school for the larger diameter, is drawn in the center.
 *  @param aColors Progress bar all colors.
 *  @param aType A gradient type enum.
 *  @return Progress object. */
- (CKRoundProgress *)initRoundProgressWithRect:(CGRect)frame colors:(NSArray *)aColors gradientType:(CKRoundProgressGradientType)aType;
+ (CKRoundProgress *)roundProgressWithRect:(CGRect)frame colors:(NSArray *)aColors gradientType:(CKRoundProgressGradientType)aType;

@property (copy, nonatomic) UIColor *lineBackColor; // Background color of progress bar. Default is 0xf8dbbd.

@property (assign, nonatomic) CGFloat lineWidth; // Progress bar width. Default is 8.0.

@property (assign, nonatomic) CGFloat startAngle; // Start angle of progress bar. Default is 0.0.

@property (assign, nonatomic) BOOL clockwise; // Is clockwise. Default is NO.

@property (assign, nonatomic) BOOL isLineRound; // Line header and ender is round. Default is NO.

@property (assign, nonatomic, readonly) CGFloat currentProgress; // Current Progress. Readonly.

@property (assign, nonatomic) NSTimeInterval duration;// Animation duration. Default is 1s.

@property (assign, nonatomic, readonly) BOOL isAnimation; // Animation state.

/**
 *  Add a click event.
 *  @param aTarget Execute the object.
 *  @param aSelector Perform the operation. */
- (void)addTagert:(id)aTarget forSelector:(SEL)aSelector;

/**
 *  Change the current progress. 
 *  - Make sure that the view is loaded when this method is called, otherwise it will not do anything, such as:
 *
 *  - (void)viewDidAppear:(BOOL)animated {
 *      [progress setProgress:1 animation:YES];
 *  }
 *  - Make sure that this method is called after the last animation has finished.
 *
 *  @param progress The progress you want to change to, between 0 and 1.
 *  @param flag Whether the animation shows. */
- (void)setProgress:(CGFloat)progress animation:(BOOL)flag;

@property (strong, nonatomic, readonly) CKCountingLabel *titleLabel; // No nil.

@property (strong, nonatomic, readonly) UILabel *subTitleLabel; // No nil.

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface CKRoundProgress (Unavailable)

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

