//
//  CKLineView.m
//  ChartKit
//
//  Created by yxiang on 2017/2/20.
//  Copyright © 2017年 yxiang. All rights reserved.
//

#import "CKLineView.h"
#import "CKBarYaxisView.h"
#import "CKPolylineView.h"

@interface CKLineView ()

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) CKBarYaxisView *yaxisView;

@property (weak, nonatomic) id <CKLineViewDataSource> dataSource;

@property (strong, nonatomic) CKPolylineView *polylineView;

@property (strong, nonatomic) NSMutableArray *dottedsArray;

@property (strong, nonatomic) NSMutableArray *xAxisTitleLabels;

@property (strong, nonatomic) NSMutableArray *xAxisTitleLayers;

- (void)_initWithPolylineView;

@end

@implementation CKLineView

#pragma mark - Public Methods

- (instancetype)initWithFrame:(CGRect)frame dataSource:(id<CKLineViewDataSource>)dataSource {
    NSAssert(dataSource, @"dataSource can not be nil, when called `initWithFrame:dataSource:`");
    if ([super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        _dataSource = dataSource;
        _yaxisView = [[CKBarYaxisView alloc] initWithFrame:CGRectMake(0, 0, 48, frame.size.height-20)];
        [self addSubview:_yaxisView];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(48, 6, frame.size.width-48, frame.size.height-6)];
        [self addSubview:_scrollView];
        
        _dottedsArray = [NSMutableArray array];
        _xAxisTitleLabels = [NSMutableArray array];
        _xAxisTitleLayers = [NSMutableArray array];
        
        self.needAnimation = YES;
        self.duration = 0.6;
        self.isLineRound = NO;
        self.needPoint = YES;
        self.isShowDottedLine = YES;
        _xLabelCenterSpace = 35.f;
    }
    return self;
}

- (void)reloadData {
    [self _initWithPolylineView];
}

#pragma mark - Private Methods

- (void)_initWithPolylineView {
    NSInteger count = [_dataSource lineViewLineNumbers:self];
    NSMutableArray *percents = [NSMutableArray array];
    CGFloat count_ = 0;
    for (int i = 0; i < count; i ++) {
        NSArray *array = [_dataSource lineView:self percentsForEachLineWithIndex:i];
        count_ = MAX(array.count, count_);
        [percents addObject:array];
    }
    count_ --;
    // Clear.
    for (UIView *view in _xAxisTitleLabels) {
        [view removeFromSuperview];
    }
    [_xAxisTitleLabels removeAllObjects];
    for (CALayer *layer in _xAxisTitleLayers) {
        [layer removeFromSuperlayer];
    }
    [_xAxisTitleLayers removeAllObjects];
    if ([_dataSource respondsToSelector:@selector(lineViewXAxisTitle:)]) {
        NSArray *xAxisTitles = [_dataSource lineViewXAxisTitle:self];
        NSAssert(count_+1 == xAxisTitles.count, @"`lineViewXAxisTitle:` returns the number of arrays is not equal to the maximum number.");
        CGFloat startX = 8;
        for (NSString *aString in xAxisTitles) {
            // Label
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _xLabelCenterSpace-5, 20)];
            label.layer.masksToBounds = NO;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = _yaxisView.titleFont;
            label.textColor = _yaxisView.titleColor;
            label.text = aString;
            label.center = CGPointMake(startX, CGRectGetHeight(_scrollView.frame)-10);
            [_scrollView addSubview:label];
            [_xAxisTitleLabels addObject:label];
            // Layer
            CALayer *layer = [CALayer layer];
            layer.backgroundColor = _yaxisView.lineColor.CGColor;
            layer.bounds = CGRectMake(0, 0, 1, 5);
            layer.position = CGPointMake(startX, CGRectGetHeight(_scrollView.frame)-32.5);
            [_scrollView.layer addSublayer:layer];
            [_xAxisTitleLayers addObject:layer];
            startX += _xLabelCenterSpace;
        }
    }
    self.polylineView.frame = CGRectMake(4, 4, count_*_xLabelCenterSpace+8, CGRectGetHeight(_scrollView.frame)-34);
    _polylineView.space = _xLabelCenterSpace;
    _polylineView.colors = [_dataSource lineViewColorsForLine:self];
    _polylineView.percentsArrays = percents;
    _scrollView.contentSize = CGSizeMake(count_*_xLabelCenterSpace+16, CGRectGetHeight(_scrollView.frame));
}

#pragma mark - Life Cycle

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self _initWithPolylineView];
}

#pragma mark - Setter & Getter

- (void)setYLabelTitles:(NSArray *)yLabelTitles {
    if (_yLabelTitles != yLabelTitles) {
        _yLabelTitles = yLabelTitles;
        _yaxisView.YaxisTitles = _yLabelTitles;
        self.isShowDottedLine = _isShowDottedLine;
    }
}

- (void)setIsShowDottedLine:(BOOL)isShowDottedLine {
    _isShowDottedLine = isShowDottedLine;
    // Clear.
    for (CAShapeLayer *layer in _dottedsArray) {
        [layer removeFromSuperlayer];
    }
    [_dottedsArray removeAllObjects];
    // Add
    if (isShowDottedLine) {
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
            [_dottedsArray addObject:lineLayer];
        }
    }
}

- (CKPolylineView *)polylineView {
    if (!_polylineView) {
        _polylineView = [[CKPolylineView alloc] init];
        _polylineView.layer.masksToBounds = NO;
        [_scrollView addSubview:_polylineView];
        __weak typeof(self)weakSelf = self;
        _polylineView.pointHaveClickedBlock = ^(NSInteger tag, NSInteger index) {
            if (weakSelf.needPoint && [weakSelf.dataSource respondsToSelector:@selector(lineView:didClickedForLineTag:withPointIndex:)]) {
                [weakSelf.dataSource lineView:weakSelf didClickedForLineTag:tag withPointIndex:index];
            }
        };
    }
    return _polylineView;
}

- (void)setDuration:(NSTimeInterval)duration {
    _duration = duration;
    self.polylineView.duration = duration;
}

- (void)setNeedPoint:(BOOL)needPoint {
    _needPoint = needPoint;
    self.polylineView.isPoint = needPoint;
}

- (void)setNeedAnimation:(BOOL)needAnimation {
    _needAnimation = needAnimation;
    self.polylineView.animation = needAnimation;
}

- (void)setIsLineRound:(BOOL)isLineRound {
    _isLineRound = isLineRound;
    self.polylineView.isRound = isLineRound;
}

@end
