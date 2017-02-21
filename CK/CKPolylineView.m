//
//  CKPolylineView.m
//  ChartKit
//
//  Created by yxiang on 2017/2/20.
//  Copyright © 2017年 yxiang. All rights reserved.
//

#import "CKPolylineView.h"
#import "CKGradientLayer.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface CKPolylineButton : UIButton

@property (copy, nonatomic) void (^haveClickedBlock) (__weak CKPolylineButton *sender);

@end

@implementation CKPolylineButton

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        CALayer *layer = [CALayer layer];
        layer.position = CGPointMake(frame.size.width/2, frame.size.height/2);
        layer.cornerRadius = 4;
        layer.bounds = CGRectMake(0, 0, 8, 8);
        layer.borderWidth = 2;
        layer.backgroundColor = [UIColor whiteColor].CGColor;
        layer.borderColor = [UIColor lightGrayColor].CGColor;
        [self.layer addSublayer:layer];
    }
    return self;
}

- (void)setHaveClickedBlock:(void (^)(CKPolylineButton *__weak))haveClickedBlock {
    if (haveClickedBlock) {
        _haveClickedBlock = haveClickedBlock;
        [self addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)buttonAction:(CKPolylineButton *)sender {
    if (_haveClickedBlock) {
        _haveClickedBlock(sender);
    }
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface CKPolylineView ()

@property (strong, nonatomic) CKGradientLayer *gradientLayer;

@end

@implementation CKPolylineView

#pragma mark - Setter & Getter

- (void)setColors:(NSArray *)colors {
    if (![_colors isEqualToArray:colors]) {
        _colors = colors;
        if (colors.count == 1) {
            self.gradientLayer.backgroundColor = (__bridge CGColorRef _Nullable)(colors.firstObject);
            self.gradientLayer.colors = nil;
        }else {
            self.gradientLayer.colors = colors;
        }
    }
}

- (void)setPercentsArrays:(NSMutableArray *)percentsArrays {
    if ([_percentsArrays isEqualToArray:percentsArrays]) {
        return;
    }
    _percentsArrays = percentsArrays;
    // Clear.
    for (UIView *aView in self.subviews) {
        [aView removeFromSuperview];
    }
    // Line path.
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat startX = 4;
    for (int i = 0; i < _percentsArrays.count; i ++) {
        startX = 4;
        NSArray *percents = _percentsArrays[i];
        CGPoint bPoint = CGPointZero;
        for (int j = 0; j < percents.count; j ++) {
            CGFloat percent = 1-[percents[j] floatValue];
            if (_isRound) {
                if (j == 0) {
                    [path moveToPoint:CGPointMake(startX, CGRectGetHeight(self.frame)*percent)];
                }else {
                    CGPoint midPoint = [self midPointFor:bPoint :CGPointMake(startX, CGRectGetHeight(self.frame)*percent)];
                    [path addQuadCurveToPoint:midPoint
                                 controlPoint:[self controlPointBetweenPoint1:midPoint :bPoint]];
                    [path addQuadCurveToPoint:CGPointMake(startX, CGRectGetHeight(self.frame)*percent)
                                 controlPoint:[self controlPointBetweenPoint1:midPoint :CGPointMake(startX, CGRectGetHeight(self.frame)*percent)]];
                }
                bPoint = CGPointMake(startX, CGRectGetHeight(self.frame)*percent);
            }else {
                if (j == 0) {
                    [path moveToPoint:CGPointMake(startX, CGRectGetHeight(self.frame)*percent)];
                }else {
                    [path addLineToPoint:CGPointMake(startX, CGRectGetHeight(self.frame)*percent)];
                }
            }
            
            // Point.
            if (_isPoint) {
                CKPolylineButton *pointView = [[CKPolylineButton alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
                __weak typeof(self)weakSelf = self;
                pointView.haveClickedBlock = ^ (CKPolylineButton * __weak sender) {
                    if (weakSelf.pointHaveClickedBlock) {
                        weakSelf.pointHaveClickedBlock(i,j);
                    }
                };
                pointView.center = CGPointMake(startX, CGRectGetHeight(self.frame)*percent);
                [self addSubview:pointView];
            }
            startX += _space;
        }
    }
    self.gradientLayer.frame = self.bounds;
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.fillColor = [UIColor clearColor].CGColor;
    maskLayer.strokeColor = [UIColor redColor].CGColor;
    maskLayer.lineWidth = 2;
    maskLayer.path = path.CGPath;
    self.gradientLayer.mask = maskLayer;
    
    if (_animation) {
        CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        basicAnimation.duration = _duration;
        basicAnimation.fromValue = @0;
        basicAnimation.toValue = @1;
        [maskLayer addAnimation:basicAnimation forKey:nil];
    }
    
}

- (CGPoint)midPointFor:(CGPoint)point1 :(CGPoint)point2 {
    return CGPointMake((point1.x+point2.x)/2, (point1.y+point2.y)/2);
}

- (CGPoint)controlPointBetweenPoint1:(CGPoint)point1 :(CGPoint)point2 {
    CGPoint controlPoint = [self midPointFor:point1 :point2];
    CGFloat diffY = abs((int) (point2.y - controlPoint.y));
    if (point1.y < point2.y)
        controlPoint.y += diffY;
    else if (point1.y > point2.y)
        controlPoint.y -= diffY;
    return controlPoint;
}

- (CKGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        _gradientLayer = [CKGradientLayer layer];
        _gradientLayer.gradientType = CKGTLine;
        [self.layer addSublayer:_gradientLayer];
    }
    return _gradientLayer;
}

@end
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
