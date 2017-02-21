//
//  CKSectionProgress.h
//  ChartKit
//
//  Created by yxiang on 2017/2/8.
//  Copyright © 2017年 yxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CKSectionProgress;

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol CKSectionProgressDelegate <NSObject>

@optional

/**
 *  Called when a segmented chart is clicked.
 *  @param aSectionProgress A sectionProgress object.
 *  @param index Aera index. */
- (void)sectionProgress:(CKSectionProgress *)aSectionProgress haveTouchToSectionAreaWithIndex:(NSInteger)index;

/**
 *  Invoked when the segment map is canceled.
 *  @param aSectionProgress A sectionProgress object.
 *  @param index Aera index. */
- (void)sectionProgress:(CKSectionProgress *)aSectionProgress haveLeaveTouchToSectionAreaWithIndex:(NSInteger)index;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

typedef NS_ENUM(NSInteger, CKSectionProgressAnimationType) {
    CKSPAEach, // Each section animation.
    CKSPAAll,  // On animation start.
};

@interface CKSectionProgress : UIView

/**
 *  Initializes the line progress bar view.
 *  @param frame The view shows the range. To the width of the high school for the larger diameter, is drawn in the center.
 *  @param aType A animation type. Defalt is `aType`.
 *  @param aHollowRadius Hollow radius.
 *  @return Progress object. */
- (CKSectionProgress *)initSectionProgressWithRect:(CGRect)frame colors:(NSArray *)aColors animationType:(CKSectionProgressAnimationType)aType hollowRadius:(CGFloat)aHollowRadius;
+ (CKSectionProgress *)sectionProgressWithRect:(CGRect)frame colors:(NSArray *)aColors animationType:(CKSectionProgressAnimationType)aType hollowRadius:(CGFloat)aHollowRadius;

@property (copy, nonatomic) UIColor *lineBackColor; // Background color of progress bar. Default is 0xf8dbbd.

@property (assign, nonatomic) NSTimeInterval duration;// Animation duration. Default is 1s.

@property (assign, nonatomic, readonly) BOOL isAnimation; // Animation state.

@property (assign, nonatomic) CGFloat startAngle; // Start angle of progress bar. Default is 0.0.

/**
 *  Change the size of each partition.
 *  @param aLocations The size of each partition.
 *  @param flag Is needs animation */
- (void)setSectionLocations:(nonnull NSArray <__kindof NSNumber *>*)aLocations animation:(BOOL)flag;

@property (weak, nonatomic) id <CKSectionProgressDelegate> delegate; // Delegate object.

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface CKSectionProgress (Unavailable)

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


NS_ASSUME_NONNULL_END
