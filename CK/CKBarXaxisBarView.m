//
//  CKBarXaxisBarView.m
//  ChartKit
//
//  Created by yxiang on 2017/2/10.
//  Copyright © 2017年 yxiang. All rights reserved.
//

#import "CKBarXaxisBarView.h"
#import "CKGradientLayer.h"
#import "CKMarocs.h"

@interface CKBarXaxisBarView () <CAAnimationDelegate>

@property (strong, nonatomic) UILabel *label;

@property (strong, nonatomic) CKGradientLayer *gradientLayer;

@property (strong, nonatomic) CAShapeLayer *maskLayer;

@end

@implementation CKBarXaxisBarView

- (instancetype)initXaxisBarViewWithFrame:(CGRect)frame colors:(NSArray *)aColors controlSpace:(CGFloat)aSpace {
    if ([super initWithFrame:frame]) {
        [self addSubview:self.label];
        
        self.titleColor = CK_RGBA_HEX(0x999999, 1);
        self.titleFont = [UIFont systemFontOfSize:12];
        self.labelWidth = frame.size.width;
        
        _gradientLayer = [CKGradientLayer layer];
        _gradientLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height-aSpace-20);
        _gradientLayer.gradientType = CKGTLine;
        _gradientLayer.colors = aColors;
        [self.layer addSublayer:_gradientLayer];
        
        _maskLayer = [CAShapeLayer layer];
        _maskLayer.frame = _gradientLayer.bounds;
        UIBezierPath *maskPath = [UIBezierPath bezierPath];
        [maskPath moveToPoint:CGPointMake(frame.size.width/2, 0)];
        [maskPath addLineToPoint:CGPointMake(frame.size.width/2, CGRectGetHeight(_maskLayer.frame))];
        _maskLayer.path = maskPath.CGPath;
        _maskLayer.lineWidth = frame.size.width;
        _maskLayer.fillColor = [UIColor clearColor].CGColor;
        _maskLayer.strokeColor = [UIColor redColor].CGColor;
        _maskLayer.strokeEnd = 1;
        _maskLayer.strokeStart = 1;
        _gradientLayer.mask = _maskLayer;
        
        _currentProgress = 0.f;
        _isAnimation = NO;
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_didClickedBlock) {
        __weak __typeof(self)weakSelf = self;
        _didClickedBlock(weakSelf);
    }
}

- (void)setProgress:(CGFloat)aPercen animation:(BOOL)flag {
    if (_currentProgress == aPercen || _isAnimation) return;
    if (flag) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
        animation.duration = _duration*ABS(_currentProgress-aPercen);
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        animation.toValue = @(1-aPercen);
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        animation.delegate = self;
        [_maskLayer addAnimation:animation forKey:nil];
    }else {
        _maskLayer.strokeStart = 1-aPercen;
    }
    _currentProgress = aPercen;
}

#pragma mark - <CAAniamtionDelegate>

- (void)animationDidStart:(CAAnimation *)anim {
    _isAnimation = YES;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag) {
        _isAnimation = NO;
    }
}

#pragma mark - Setter & Getter

- (void)setTitleColor:(UIColor *)titleColor {
    if (![_titleColor isEqual:titleColor]) {
        _label.textColor = titleColor;
        _titleColor = titleColor;
    }
}

- (void)setTitleText:(NSString *)titleText {
    if (![_titleText isEqualToString:titleText]) {
        _titleText = titleText;
        _label.text = titleText;
    }
}

- (void)setLabelWidth:(CGFloat)labelWidth {
    if (labelWidth > CGRectGetWidth(self.frame) && _labelWidth != labelWidth) {
        _labelWidth = labelWidth;
        CGPoint center = _label.center;
        CGRect rect = _label.frame;
        rect.size = CGSizeMake(_labelWidth, rect.size.height);
        _label.frame = rect;
        _label.center = center;
    }
}

- (void)setTitleFont:(UIFont *)titleFont {
    if (![_titleFont isEqual:titleFont]) {
        _label.font = titleFont;
        _titleFont = titleFont;
    }
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame)-20, CGRectGetWidth(self.frame), 20)];
        _label.textAlignment = NSTextAlignmentCenter;
    }
    return _label;
}

@end
