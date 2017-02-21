//
//  CKLineView.h
//  ChartKit
//
//  Created by yxiang on 2017/2/20.
//  Copyright © 2017年 yxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKLineView;

@protocol CKLineViewDataSource <NSObject>

/**
 *  How many polylines are there in the line view.
 *  @param aLineView The view object.
 *  @return Number of polylines. */
- (NSInteger)lineViewLineNumbers:(CKLineView *)aLineView;

/**
 *  Polyline color array.
 *  @param aLineView The view object.
 *  @return The colors. */
- (NSArray *)lineViewColorsForLine:(CKLineView *)aLineView;

/**
 *  Each polyline, the current array of all points, should be between 0 and 1.
 *  @param aLineView The view object.
 *  @param index Polyline label.
 *  @return Numeric array. */
- (NSArray *)lineView:(CKLineView *)aLineView percentsForEachLineWithIndex:(NSInteger)index;

@optional

/**
 *  Returns the title of the x-axis for each tick, and its number must be `lineView:percentsForEachLineWithIndex:` The maximum number of arrays returned by the method is the same.
 *  @param aLineView aLineView The view object.
 *  @return The titles. */
- (NSArray *)lineViewXAxisTitle:(CKLineView *)aLineView;

/**
 *  When a little need to display, a point will be clicked after the callback.
 *  @param aLineView The view object.
 *  @param tag Line tag.
 *  @param index Point index. */
- (void)lineView:(CKLineView *)aLineView didClickedForLineTag:(NSInteger)tag withPointIndex:(NSInteger)index;

@end

@interface CKLineView : UIView

/**
 *  Initialize the view object.
 *  @param frame Frame information.
 *  @param dataSource Data source object.
 *  @return The view object. */
- (instancetype)initWithFrame:(CGRect)frame dataSource:(id <CKLineViewDataSource>)dataSource;

- (void)reloadData; /// Reload the line chart. Will re-call the dataSource method.

@property (copy, nonatomic) NSArray *yLabelTitles; /// Y-axis title.

@property (assign, nonatomic) CGFloat xLabelCenterSpace; /// On the x-axis, the distance between each two points. Default is 35.f.

@property (assign, nonatomic) BOOL isShowDottedLine; /// Whether dotted lines are displayed. Default is YES.

#pragma mark - After the set, the next reload effective.

@property (assign, nonatomic) BOOL isLineRound; /// Curve or straight line? NO means a straight line, YES is the curve. Default is NO.

@property (assign, nonatomic) BOOL needAnimation; /// Whether or not an animation is required to draw a line segment. Default is YES.

@property (assign, nonatomic) BOOL needPoint; /// Line, whether the need for point display. Default is YES.

@property (assign, nonatomic) NSTimeInterval duration; /// Animation time. Default is 0.6s.

@end
