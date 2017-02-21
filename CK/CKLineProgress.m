//
//  CKLineProgress.m
//  ChartKit
//
//  Created by yxiang on 2017/2/8.
//  Copyright © 2017年 yxiang. All rights reserved.
//

#import "CKLineProgress.h"
#import "CKGradientLayer.h"
#import "CKMarocs.h"

@interface CKLineProgress () <CAAnimationDelegate>

@property (strong, nonatomic) CALayer *trackLayer; // Background layer.

@property (strong, nonatomic) CKGradientLayer *lineProgressBar; // Line progress bar.

@property (strong, nonatomic) CAShapeLayer *maskLayer; // Mask layer.

@property (weak, nonatomic) id target;

@property (assign, nonatomic) SEL selector;

@end

@implementation CKLineProgress

@synthesize currentProgress = _currentProgress;
@synthesize isAnimation = _isAnimation;

#pragma mark - Public Methods

- (CKLineProgress *)initLineProgressWithRect:(CGRect)frame colors:(NSArray *)aColors lineWidth:(CGFloat)aLineWidth {
    if ([super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        _duration = 1.f;
        _isAnimation = NO;
        _currentProgress = 0.f;
        _isRound = NO;
        _lineBackColor = CK_RGBA_HEX(0xf8dbbd, 1.f);
        
        CGRect rect = CGRectMake(0, (frame.size.height-aLineWidth)/2, frame.size.width, aLineWidth);
        
        _lineProgressBar = [CKGradientLayer layer];
        _lineProgressBar.frame = rect;
        _lineProgressBar.colors = aColors;
        _lineProgressBar.gradientType = CKGTLine;
        _lineProgressBar.startPoint = CGPointMake(0, 0.5);
        _lineProgressBar.endPoint = CGPointMake(1, 0.5);
        _lineProgressBar.masksToBounds = YES;
    }
    return self;
}

+ (CKLineProgress *)lineProgressWithRect:(CGRect)frame colors:(NSArray *)aColors lineWidth:(CGFloat)aLineWidth {
    return [[self alloc] initLineProgressWithRect:frame colors:aColors lineWidth:aLineWidth];
}

- (void)setProgress:(CGFloat)progress animation:(BOOL)flag {
    if (progress>1) {
        progress = 1.f;
    }
    if (progress<0) {
        progress = 0.f;
    }
    if (progress != _currentProgress && !_isAnimation) {
        if (flag) {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            animation.duration = _duration*ABS(progress-_currentProgress);
            animation.fillMode = kCAFillModeForwards;
            animation.removedOnCompletion = NO;
            animation.toValue = @(progress);
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            animation.delegate = self;
            [_maskLayer addAnimation:animation forKey:nil];
        }else {
            _maskLayer.strokeEnd = progress;
        }
        _currentProgress = progress;
    }
}

- (void)addTagert:(id)aTarget forSelector:(SEL)aSelector {
    NSAssert(aTarget && aSelector, @"Illegal parameter passed in when calling `addTagert: forSelector:`");
    _target = aTarget;
    _selector = aSelector;
}

#pragma mark - Life Cycle

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGFloat cornerRadius = 0.f;
    if (_isRound) {
        cornerRadius = _lineProgressBar.frame.size.height/2;
    }
    
    self.trackLayer.backgroundColor = _lineBackColor.CGColor;
    _trackLayer.cornerRadius = cornerRadius;
    [self.layer addSublayer:_trackLayer];
    
    _lineProgressBar.cornerRadius = cornerRadius;
    [self.layer addSublayer:_lineProgressBar];
    
    _lineProgressBar.mask = self.maskLayer;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (_target && _selector != NULL) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Warc-performSelector-leaks"
        [_target performSelector:_selector withObject:self];
#pragma clang diagnostic pop
    }
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

- (CALayer *)trackLayer {
    if (!_trackLayer) {
        _trackLayer = [CALayer layer];
        _trackLayer.frame = _lineProgressBar.frame;
    }
    return _trackLayer;
}

- (CAShapeLayer *)maskLayer {
    if (!_maskLayer) {
        _maskLayer = [CAShapeLayer layer];
        _maskLayer.frame = _lineProgressBar.bounds;
        _maskLayer.fillColor = [UIColor clearColor].CGColor;
        _maskLayer.strokeColor = [UIColor redColor].CGColor;
        _maskLayer.strokeStart = 0.f;
        _maskLayer.strokeEnd = 0.f;
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0, _lineProgressBar.bounds.size.height/2)];
        [path addLineToPoint:CGPointMake(_lineProgressBar.bounds.size.width, _lineProgressBar.bounds.size.height/2)];
        path.lineWidth = _lineProgressBar.bounds.size.height;
        _maskLayer.lineWidth = _lineProgressBar.bounds.size.height;
        _maskLayer.path = path.CGPath;
    }
    return _maskLayer;
}

@end
