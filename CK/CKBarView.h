//
//  CKBarView.h
//  ChartKit
//
//  Created by yxiang on 2017/2/10.
//  Copyright © 2017年 yxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKBarView;

extern NSString * const cKBarViewXaxisTitleKey; /// Key of x-axis title.
extern NSString * const cKBarViewXaxisPercentKey; /// Key of x-axis bar percent.

@protocol CKBarViewDataSource <NSObject>

/**
 *  Y-axis titles in bar view.
 *  @param aBarView Bar view object.
 *  @return Titles array. */
- (NSArray *)barViewYaxisTitles:(CKBarView *)aBarView;

/**
 *  Total elements in bar view.
 *  @param aBarView Bar view object.
 *  @return Total count. */
- (NSInteger)barViewForItemCount:(CKBarView *)aBarView;

/**
 *  Each column of information, including the percentage and title.
 *  @param aBarView Bar view object.
 *  @param index Which element.
 *  @return Information dictionary. */
- (NSDictionary *)barView:(CKBarView *)aBarView xaxisBarViewInfoForIndex:(NSInteger)index;

@end

@protocol CKBarViewDelegate <NSObject>

@optional

/**
 *  The column is clicked after the callback.
 *  @param aBarView Bar view object.
 *  @param index Which element. */
- (void)barView:(CKBarView *)aBarView didClickedItemForIndex:(NSInteger)index;

@end

/// Future use.
typedef NS_ENUM(NSInteger, CKBAnimationType) {
    CKBAEach, /// Animation when bar appearence.
    CKBAAll   /// Animation together.
};

@interface CKBarView : UIView

/**
 *  Initialize a histogram object.
 *  @param frame Frame information
 *  @param dataSource Data source object.
 *  @return The view of bar object. */
- (instancetype)initBarViewWithFrame:(CGRect)frame dataSource:(id <CKBarViewDataSource>)dataSource;

/**
 *  Reload data. */
- (void)reloadData;

/// Delegate object.
@property (weak, nonatomic) id <CKBarViewDelegate> delegate;

#pragma mark - Apparence

@property (assign, nonatomic) CGFloat elementsCenterXSpace UI_APPEARANCE_SELECTOR; /// The space of each element.

@property (copy, nonatomic) NSArray *elementGradientColors UI_APPEARANCE_SELECTOR; /// The gradient color of element.

@property (assign, nonatomic) CGFloat elementWidth UI_APPEARANCE_SELECTOR; /// The width of each element.

@property (assign, nonatomic) CGFloat elementXBegin UI_APPEARANCE_SELECTOR; /// The x begin at x-axis value.

@end
