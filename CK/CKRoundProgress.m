//
//  CKRoundProgress.m
//  ChartKit
//
//  Created by yxiang on 2017/2/7.
//  Copyright © 2017年 yxiang. All rights reserved.
//

#import "CKRoundProgress.h"
#import "CKGradientLayer.h"
#import "CKMarocs.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 *  Obtain a Bezier curve.
 *  @param rect Width and height information.
 *  @param startAngle Start angle.
 *  @param lineWidth Line width.
 *  @param clockwise Is clockwise.
 *  @return Bezier ref. */
static CGPathRef RoundPath(CGRect rect, CGFloat startAngle, CGFloat lineWidth, BOOL clockwise) {
    CGFloat min = MIN(rect.size.width, rect.size.height);
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(rect.size.width/2, rect.size.height/2)
                                                              radius:min/2-lineWidth/2
                                                          startAngle:startAngle
                                                            endAngle:startAngle+M_PI*2
                                                           clockwise:clockwise];
    return bezierPath.CGPath;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface CKRoundProgress () <CAAnimationDelegate>

@property (strong, nonatomic) CKGradientLayer *roundProgressBar; // Annular progress bar.

@property (strong, nonatomic) CAShapeLayer *trackLayer; // Background layer.

@property (strong, nonatomic) CAShapeLayer *maskLayer; // Mask layer.

@property (weak, nonatomic) id target;

@property (assign, nonatomic) SEL selector;

//@property (strong, nonatomic) CALayer *lineCapLayer; // Line cap layer.

@end

@implementation CKRoundProgress

@synthesize isAnimation = _isAnimation;
@synthesize currentProgress = _currentProgress;
@synthesize subTitleLabel = _subTitleLabel;
@synthesize titleLabel = _titleLabel;

#pragma mark - Public Methods

- (CKRoundProgress *)initRoundProgressWithRect:(CGRect)frame colors:(NSArray *)aColors gradientType:(CKRoundProgressGradientType)aType {
    if ([super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
        _duration = 1.f;
        _isAnimation = NO;
        _currentProgress = 0.f;
        _lineWidth = 8.f;
        _startAngle = 0.f;
        _lineBackColor = CK_RGBA_HEX(0xf8dbbd, 1.f);
        
        CGFloat min = MIN(frame.size.width, frame.size.height);
        
        _roundProgressBar = [CKGradientLayer layer];
        _roundProgressBar.bounds = CGRectMake(0, 0, min, min);
        _roundProgressBar.position = CGPointMake(frame.size.width/2, frame.size.height/2);
        _roundProgressBar.colors = aColors;
        _roundProgressBar.gradientType = (CKGradientType)aType;
    }
    return self;
}

+ (CKRoundProgress *)roundProgressWithRect:(CGRect)frame colors:(NSArray *)aColors gradientType:(CKRoundProgressGradientType)aType {
    return [[self alloc] initRoundProgressWithRect:frame colors:aColors gradientType:aType];
}

- (void)addTagert:(id)aTarget forSelector:(SEL)aSelector {
    NSAssert(aTarget && aSelector, @"Illegal parameter passed in when calling `addTagert: forSelector:`");
    _target = aTarget;
    _selector = aSelector;
}

- (void)setProgress:(CGFloat)progress animation:(BOOL)flag {
    if (progress>1) {
        progress = 1.f;
    }
    if (progress<0) {
        progress = 0.f;
    }
    if (progress != _currentProgress && !_isAnimation && !_titleLabel.isAnimation) {
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

#pragma mark - Life Cycle

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    self.trackLayer.lineWidth = _lineWidth;
    _trackLayer.strokeColor = _lineBackColor.CGColor;
    _trackLayer.path = RoundPath(_roundProgressBar.frame, _startAngle, _lineWidth, YES);
    [self.layer addSublayer:_trackLayer];
    
    _roundProgressBar.startAngle = _startAngle;
    [self.layer addSublayer:_roundProgressBar];
    
    self.maskLayer.lineWidth = _lineWidth;
    _maskLayer.path = RoundPath(_roundProgressBar.frame, _startAngle, _lineWidth, _clockwise);
    _roundProgressBar.mask = _maskLayer;
    
    if (_isLineRound) {
        _maskLayer.lineCap = kCALineCapRound;
//        [self.layer addSublayer:self.lineCapLayer];
    }
    
    if (_subTitleLabel) {
        [self addSubview:_subTitleLabel];
    }
    
    if (_titleLabel) {
        [self addSubview:_titleLabel];
    }
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

- (CAShapeLayer *)trackLayer {
    if (!_trackLayer) {
        _trackLayer = [CAShapeLayer layer];
        _trackLayer.frame = _roundProgressBar.frame;
        _trackLayer.fillColor = [UIColor clearColor].CGColor;
    }
    return _trackLayer;
}

- (CAShapeLayer *)maskLayer {
    if (!_maskLayer) {
        _maskLayer = [CAShapeLayer layer];
        _maskLayer.frame = _roundProgressBar.bounds;
        _maskLayer.fillColor = [UIColor clearColor].CGColor;
        _maskLayer.strokeColor = [UIColor redColor].CGColor;
        _maskLayer.strokeStart = 0.f;
        _maskLayer.strokeEnd = 0.f;
    }
    return _maskLayer;
}

- (CKCountingLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[CKCountingLabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height*17.f/65.f, self.frame.size.width, 45)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:32];
        _titleLabel.textColor = CK_RGBA_HEX(0x333333, 1);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height*39.f/65.f, self.frame.size.width, 17)];
        _subTitleLabel.backgroundColor = [UIColor clearColor];
        _subTitleLabel.font = [UIFont systemFontOfSize:12];
        _subTitleLabel.textColor = CK_RGBA_HEX(0x333333, 1);
        _subTitleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _subTitleLabel;
}

/*
- (CALayer *)lineCapLayer {
    if (!_lineCapLayer) {
        _lineCapLayer = _roundProgressBar.copy;
        
        CAShapeLayer *mask = [CAShapeLayer layer];
        mask.frame = _lineCapLayer.bounds;
        mask.lineWidth = 0.f;
        
        mask.strokeColor = [UIColor redColor].CGColor;
        mask.fillColor = [UIColor whiteColor].CGColor;
        
        CGFloat radius = _lineWidth/2;
        CGFloat radius_c = _lineCapLayer.frame.size.width/2-radius;
        CGPoint pathCenter = CGPointMake(_lineCapLayer.frame.size.width/2+cos(_startAngle)*radius_c, _lineCapLayer.frame.size.height/2+sin(_startAngle)*radius_c);
        CGFloat startAngle = M_PI+_startAngle;
        CGFloat endAngle = startAngle+M_PI;
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:pathCenter radius:radius-mask.lineWidth/2 startAngle:startAngle endAngle:endAngle clockwise:YES];
        [path closePath];
        mask.path = path.CGPath;
        
        _lineCapLayer.mask = mask;
        
    }
    return _lineCapLayer;
}*/

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
