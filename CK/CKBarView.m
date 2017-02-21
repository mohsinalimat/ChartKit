//
//  CKBarView.m
//  ChartKit
//
//  Created by yxiang on 2017/2/10.
//  Copyright © 2017年 yxiang. All rights reserved.
//

#import "CKBarView.h"
#import "CKMarocs.h"
#import "CKBarYaxisView.h"
#import "CKBarXaxisBarView.h"

NSString * const cKBarViewXaxisTitleKey = @"titleText"; /// Key of x-axis title.
NSString * const cKBarViewXaxisPercentKey = @"percent"; /// Key of x-axis bar percent.

#define APPEARENCE_OBJECT [CKBarView appearance]

@interface CKBarView () <UIScrollViewDelegate>

@property (weak, nonatomic) id <CKBarViewDataSource> dataSource;

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) CKBarYaxisView *yaxisView;

@property (strong, nonatomic) NSMutableArray *xaxisLineLayers;

@property (strong, nonatomic) NSMutableArray *bars;

@property (strong, nonatomic) NSMutableArray *barInfos;

- (void)_initUIElement;

- (BOOL)_isBarAllPartShowWithBarIndex:(CKBarXaxisBarView *)barView forJudegmentX:(CGFloat)jx;

@end

@implementation CKBarView {
    NSInteger _elementCount;
    NSInteger _currentCount;
    BOOL _animationFlag;
}

+ (void)initialize {
    [CKBarView appearance].elementXBegin =
    [CKBarView appearance].elementWidth = 20.f;
    [CKBarView appearance].elementGradientColors = @[(__bridge id)[UIColor redColor].CGColor,(__bridge id)[UIColor greenColor].CGColor];
    [CKBarView appearance].elementsCenterXSpace = 30.f;
    
}

#pragma mark - Public Methods

- (instancetype)initBarViewWithFrame:(CGRect)frame dataSource:(id<CKBarViewDataSource>)dataSource {
    NSAssert(dataSource, @"dataSource can not be nil, when called `initBarViewWithFrame:dataSource:`");
    if ([super initWithFrame:frame]) {
        _dataSource = dataSource;
        _yaxisView = [[CKBarYaxisView alloc] initWithFrame:CGRectMake(0, 0, 48, frame.size.height-20)];
        [self addSubview:_yaxisView];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(48, 10, frame.size.width-48, frame.size.height-10)];
//        _scrollView.delegate = self;
        [self addSubview:_scrollView];
        
        [self _initUIElement];
    }
    return self;
}

- (void)reloadData {
    // Clear.
    for (CALayer *layer in _xaxisLineLayers) {
        [layer removeAllAnimations];
        [layer removeFromSuperlayer];
    }
    [_xaxisLineLayers removeAllObjects];
    _xaxisLineLayers = nil;
    for (UIView *view in _bars) {
        [view removeFromSuperview];
    }
    [_bars removeAllObjects];
    _bars = nil;
    [_barInfos removeAllObjects];
    _barInfos = nil;
    
    _scrollView.contentOffset = CGPointZero;
    
    [self _initUIElement];
}

#pragma mark - Private Methods

- (void)_initUIElement {
    // Y-aixs.
    _yaxisView.YaxisTitles = [_dataSource barViewYaxisTitles:self];
    // X-aixs line layers.
    _xaxisLineLayers = [NSMutableArray array];
    for (NSNumber *centerx in _yaxisView.yLabelCenterYs) {
        CAShapeLayer *lineLayer = [CAShapeLayer layer];
        CGFloat beginX = CGRectGetMaxX(_yaxisView.frame);
        lineLayer.frame = CGRectMake(beginX, [centerx floatValue]-0.25, CGRectGetWidth(self.frame)-beginX, 0.5);
        lineLayer.lineDashPattern = @[@2,@2];
        lineLayer.strokeColor = _yaxisView.lineColor.CGColor;
        UIBezierPath *linePath = [UIBezierPath bezierPath];
        [linePath moveToPoint:CGPointMake(0, 0.25)];
        [linePath addLineToPoint:CGPointMake(CGRectGetWidth(self.frame)-beginX, 0.25)];
        lineLayer.path = linePath.CGPath;
        [self.layer insertSublayer:lineLayer atIndex:0];
        [_xaxisLineLayers addObject:lineLayer];
    }
    
    // Elements.
    _bars = [NSMutableArray array];
    _barInfos = [NSMutableArray array];
    CGFloat height = CGRectGetHeight(_scrollView.frame);
    CGFloat beginx = APPEARENCE_OBJECT.elementXBegin;
    CGFloat maxWidth = APPEARENCE_OBJECT.elementsCenterXSpace-10+APPEARENCE_OBJECT.elementWidth;
    CGFloat oringinSpace = APPEARENCE_OBJECT.elementsCenterXSpace+APPEARENCE_OBJECT.elementWidth;
    _elementCount = [_dataSource barViewForItemCount:self];
    _scrollView.contentSize = CGSizeMake((_elementCount-0.5)*oringinSpace+2*beginx, height);

    NSInteger count = (CGRectGetWidth(_scrollView.frame)-beginx)/oringinSpace;
    if (count*oringinSpace < CGRectGetWidth(_scrollView.frame)-beginx) {
        count ++;
    }
    
    for (int i = 0; i < _elementCount; i ++) {
        
        NSDictionary *dict = [_dataSource barView:self xaxisBarViewInfoForIndex:i];
        [_barInfos addObject:dict];
        CKBarXaxisBarView *xaxis = [[CKBarXaxisBarView alloc] initXaxisBarViewWithFrame:CGRectMake(beginx+i*oringinSpace, 0, APPEARENCE_OBJECT.elementWidth, height)
                                                                                 colors:APPEARENCE_OBJECT.elementGradientColors
                                                                           controlSpace:10];
        xaxis.titleText = dict[cKBarViewXaxisTitleKey];
        xaxis.labelWidth = maxWidth;
        [_bars addObject:xaxis];
        [_scrollView addSubview:xaxis];
        
        CGFloat progress = [dict[cKBarViewXaxisPercentKey] floatValue];
//        if (i < count) {
            [xaxis setProgress:progress animation:YES];
//            _currentCount = i;
//        }
        
        __weak typeof(self)weakSelf = self;
        xaxis.didClickedBlock = ^ (CKBarXaxisBarView * __weak sender) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(barView:didClickedItemForIndex:)]) {
                [weakSelf.delegate barView:weakSelf didClickedItemForIndex:i];
            }
        };
    }
    
}

- (BOOL)_isBarAllPartShowWithBarIndex:(CKBarXaxisBarView *)barView forJudegmentX:(CGFloat)jx {
    CGFloat currentx = _scrollView.frame.size.width+_scrollView.contentOffset.x;
    if (jx <= currentx ) {
        return YES;
    }
    return NO;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x > 0 && scrollView.contentOffset.x < scrollView.contentSize.width-scrollView.frame.size.width && _currentCount < _elementCount-1) {
        CKBarXaxisBarView *bar = _bars[_currentCount+1];
        if ([self _isBarAllPartShowWithBarIndex:bar forJudegmentX:CGRectGetMaxX(bar.frame)-APPEARENCE_OBJECT.elementWidth/4] && _animationFlag) {
            NSDictionary *dict = _barInfos[_currentCount];
            [bar setProgress:[dict[cKBarViewXaxisPercentKey] floatValue] animation:YES];
            _currentCount ++;
        }else if ([self _isBarAllPartShowWithBarIndex:bar forJudegmentX:CGRectGetMinX(bar.frame)-APPEARENCE_OBJECT.elementsCenterXSpace] && !_animationFlag) {
            NSDictionary *dict = _barInfos[_currentCount];
            [bar setProgress:[dict[cKBarViewXaxisPercentKey] floatValue] animation:NO];
            _currentCount ++;
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _animationFlag = YES;
    NSLog(@"手指点击了");
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    _animationFlag = NO;
    NSLog(@"手指放弃点击了");
}

@end
