//
//  CKSectionProgress.m
//  ChartKit
//
//  Created by yxiang on 2017/2/8.
//  Copyright © 2017年 yxiang. All rights reserved.
//

#import "CKSectionProgress.h" 
#import "CKMarocs.h"

@interface CKSectionProgress () <CAAnimationDelegate>

@property (strong, nonatomic) NSMutableArray <__kindof CAShapeLayer *> *sectionLayerArray; // Store each color layer.

@property (copy, nonatomic) NSArray <__kindof NSNumber *> *locations; // Store loction information.

@property (strong, nonatomic) CALayer *contentLayer; // A content layer of each color layer.

@property (strong, nonatomic) CAShapeLayer *maskLayer; // A mask layer.

@property (strong, nonatomic) CAShapeLayer *contentBackLayer; // A mask layer.

@property (copy, nonatomic) NSArray *colors; // Store all color.

@property (weak, nonatomic) CAShapeLayer *ccopyLayerForSelectedAnimation;

/**
 *  Initializes all color layers.
 *  @param aLocations All layers display range information. 
 *  @param flag Needs animation. */
- (void)_initLayersWithLocations:(NSArray<__kindof NSNumber *> *)aLocations animation:(BOOL)flag;

/**
 *  Finds the area index of the point that is currently clicked.
 *  @param touch Click Coordinates.
 *  @return Area subscript. */
- (NSInteger)_judgementTouchPointToIndex:(UITouch *)touch;

- (CAShapeLayer *)_ccopyLayerFromIndex:(NSInteger)index;

@end

@implementation CKSectionProgress {
    CGFloat _minOfWiOrHe; // The smaller of the length and width.
    CGFloat _showLineWidth; // Displayed width.
    CKSectionProgressAnimationType _type;
    NSInteger _currentIndex; // Touch current area index.
}

@synthesize isAnimation = _isAnimation;
@synthesize duration = _duration;

#pragma mark - Public Methods

- (CKSectionProgress *)initSectionProgressWithRect:(CGRect)frame colors:(NSArray *)aColors animationType:(CKSectionProgressAnimationType)aType hollowRadius:(CGFloat)aHollowRadius {
    if ([super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.masksToBounds = NO;
        _type = aType;
        _currentIndex = NSNotFound;
        _lineBackColor = CK_RGBA_HEX(0xf8dbbd, 1.f);
        _duration = 1.f;
        _isAnimation = NO;
        _startAngle = 0.f;
        
        _colors = aColors;
        
        _sectionLayerArray = [NSMutableArray array];
        
        [self.layer addSublayer:self.contentLayer];
        
        _showLineWidth = _minOfWiOrHe/2-aHollowRadius;
        
    }
    return self;
}

+ (CKSectionProgress *)sectionProgressWithRect:(CGRect)frame colors:(NSArray *)aColors animationType:(CKSectionProgressAnimationType)aType hollowRadius:(CGFloat)aHollowRadius {
    return [[self alloc] initSectionProgressWithRect:frame colors:aColors animationType:aType hollowRadius:aHollowRadius];
}

- (void)setSectionLocations:(NSArray<__kindof NSNumber *> *)aLocations animation:(BOOL)flag {
    NSAssert(_sectionLayerArray.count <= aLocations.count, @"Illegal parameters were passed when `setSectionLocations:animation:` was called");
    if (_isAnimation) return;
    // Clear layer.
    for (CAShapeLayer *layer in _sectionLayerArray) {
        [layer removeFromSuperlayer];
    }
    [_sectionLayerArray removeAllObjects];
    // Clear mask.
    _contentLayer.mask = nil;
    _maskLayer = nil;
    
    _locations = aLocations;
    // Add new layer.
    [self _initLayersWithLocations:aLocations animation:flag];
}

#pragma mark - Private Methods

- (void)_initLayersWithLocations:(NSArray<__kindof NSNumber *> *)aLocations animation:(BOOL)flag {
    CGFloat beginLocation = 0.f; // A location begin value.
    for (int i = 0; i < aLocations.count; i ++) {
        CGFloat toLocation = [aLocations[i] floatValue]; // Get to location value.
        if (toLocation == beginLocation) continue;
        CAShapeLayer *colorLayer = [CAShapeLayer layer];
        colorLayer.frame = _contentLayer.bounds;
        colorLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(_minOfWiOrHe/2, _minOfWiOrHe/2)
                                                         radius:_minOfWiOrHe/4
                                                     startAngle:_startAngle+beginLocation*M_PI*2
                                                       endAngle:_startAngle+toLocation*M_PI*2
                                                      clockwise:YES].CGPath;
        colorLayer.lineWidth = _minOfWiOrHe/2;
        colorLayer.strokeColor = (__bridge CGColorRef)_colors[i];
        colorLayer.fillColor = [UIColor clearColor].CGColor;
        [_contentLayer addSublayer:colorLayer];
        [_sectionLayerArray addObject:colorLayer];
        
        // Animation.
        if (_type == CKSPAEach) {
            CAShapeLayer *colorMask = [CAShapeLayer layer];
            colorMask.frame = colorLayer.bounds;
            colorMask.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(_minOfWiOrHe/2, _minOfWiOrHe/2)
                                                            radius:_minOfWiOrHe/2-_showLineWidth/2
                                                        startAngle:_startAngle+beginLocation*M_PI*2
                                                          endAngle:_startAngle+toLocation*M_PI*2
                                                         clockwise:YES].CGPath;
            colorMask.lineWidth = _showLineWidth;
            colorMask.fillColor = [UIColor clearColor].CGColor;
            colorMask.strokeColor = [UIColor redColor].CGColor;
            colorLayer.mask = colorMask;
            
            if (flag) {
                CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
                basicAnimation.duration = _duration;
                basicAnimation.fillMode = kCAFillModeForwards;
                basicAnimation.removedOnCompletion = NO;
                basicAnimation.fromValue = @0;
                basicAnimation.toValue = @1;
                [colorMask addAnimation:basicAnimation forKey:nil];
                if (i == aLocations.count-1) {
                    basicAnimation.delegate = self;
                }
            }else {
                colorMask.strokeEnd = 1;
            }
        }
        beginLocation = toLocation;
    }
    
    if (_type == CKSPAAll && flag) {
        if (flag) {
            _contentLayer.mask = self.maskLayer;
            CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            basicAnimation.duration = _duration;
            basicAnimation.fillMode = kCAFillModeForwards;
            basicAnimation.removedOnCompletion = NO;
            basicAnimation.fromValue = @0;
            basicAnimation.toValue = @1;
            [_maskLayer addAnimation:basicAnimation forKey:nil];
            basicAnimation.delegate = self;
        }else {
            _contentLayer.mask = self.maskLayer;
            self.maskLayer.strokeEnd = 1;
        }
    }
}

- (NSInteger)_judgementTouchPointToIndex:(UITouch *)touch {
    CGPoint aPoint = [touch locationInView:self];
    if (!CGRectContainsPoint(self.bounds, aPoint)) {
        return NSNotFound;
    }
    CGPoint origin = _contentLayer.position;
    CGPoint translatePoint = CGPointMake(aPoint.x-origin.x, aPoint.y-origin.y);
    CGFloat atan2Value = atan2(translatePoint.y, translatePoint.x); // [-M_PI , M_PI] .
    if (atan2Value < 0) {
        atan2Value += M_PI*2;
    } // [0 , 2*M_PI]
    CGFloat beginLocation = 0.f;
    for (int i = 0; i < _locations.count; i ++) {
        CGFloat location = [_locations[i] floatValue];
        CGFloat b_a = beginLocation*M_PI*2;
        CGFloat e_a = location*M_PI*2;
        beginLocation = location;
        if (atan2Value >= b_a && atan2Value < e_a) {
            return i;
        }
    }
    return NSNotFound;
}

- (CAShapeLayer *)_ccopyLayerFromIndex:(NSInteger)index {
    if (index == NSNotFound) {
        return nil;
    }
    CGFloat toWidth = _showLineWidth*0.5;
    CAShapeLayer *copyLayer = [CAShapeLayer layer];
    copyLayer.frame = _contentLayer.frame;
    copyLayer.lineWidth = toWidth;
    copyLayer.strokeColor = (__bridge CGColorRef)_colors[index];
    copyLayer.fillColor = [UIColor clearColor].CGColor;
    
    CGFloat begin = 0.f;
    CGFloat end = [_locations[index] floatValue];
    if (index != 0) {
        begin = [_locations[index-1] floatValue];
    }
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(_minOfWiOrHe/2, _minOfWiOrHe/2)
                                                        radius:_minOfWiOrHe/2-toWidth/2
                                                    startAngle:_startAngle+begin*M_PI*2
                                                      endAngle:_startAngle+end*M_PI*2
                                                     clockwise:YES];
    copyLayer.path = path.CGPath;
    [self.layer addSublayer:copyLayer];
    
    UIBezierPath *toPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(_minOfWiOrHe/2, _minOfWiOrHe/2)
                                                          radius:_minOfWiOrHe/2+toWidth/2-1
                                                      startAngle:_startAngle+begin*M_PI*2
                                                        endAngle:_startAngle+end*M_PI*2
                                                       clockwise:YES];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.duration = 0.1;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.fromValue = (__bridge id)path.CGPath;
    animation.toValue = (__bridge id)toPath.CGPath;
    [copyLayer addAnimation:animation forKey:nil];
    
    return copyLayer;
}

#pragma mark - Life Cycle

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [_contentLayer addSublayer:self.contentBackLayer];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSInteger index = [self _judgementTouchPointToIndex:touches.allObjects.firstObject];
    if (index != NSNotFound) {
        _currentIndex = index;
        
        self.ccopyLayerForSelectedAnimation = [self _ccopyLayerFromIndex:index];
        
        if (_delegate && [_delegate respondsToSelector:@selector(sectionProgress:haveTouchToSectionAreaWithIndex:)]) {
            [_delegate sectionProgress:self haveTouchToSectionAreaWithIndex:_currentIndex];
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSInteger index = [self _judgementTouchPointToIndex:touches.allObjects.firstObject];
    if (index != _currentIndex && index != NSNotFound) {
        // Clear.
        [self.ccopyLayerForSelectedAnimation removeAllAnimations];
        [self.ccopyLayerForSelectedAnimation removeFromSuperlayer];
        
        // Add new.
        self.ccopyLayerForSelectedAnimation = [self _ccopyLayerFromIndex:index];
        
        _currentIndex = index;
        
        if (_delegate && [_delegate respondsToSelector:@selector(sectionProgress:haveTouchToSectionAreaWithIndex:)]) {
            [_delegate sectionProgress:self haveTouchToSectionAreaWithIndex:_currentIndex];
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSInteger index = [self _judgementTouchPointToIndex:touches.allObjects.firstObject];
    if (index != NSNotFound) {
        _currentIndex = NSNotFound;
        // Clear.
        /*
        // Animation.
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
        animation.duration = 0.1;
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        animation.fromValue = (__bridge id)self.ccopyLayerForSelectedAnimation.path;
        CGFloat toWidth = _showLineWidth*0.5;
        CGFloat begin = 0.f;
        CGFloat end = [_locations[index] floatValue];
        if (index != 0) {
            begin = [_locations[index-1] floatValue];
        }
        UIBezierPath *toPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(_minOfWiOrHe/2, _minOfWiOrHe/2)
                                                              radius:_minOfWiOrHe/2-toWidth/2
                                                          startAngle:_startAngle+begin*M_PI*2
                                                            endAngle:_startAngle+end*M_PI*2
                                                           clockwise:YES];
        animation.toValue = (__bridge id)toPath.CGPath;
        [self.ccopyLayerForSelectedAnimation addAnimation:animation forKey:nil];
        */
        [self.ccopyLayerForSelectedAnimation removeAllAnimations];
        [self.ccopyLayerForSelectedAnimation removeFromSuperlayer];
        
        if (_delegate && [_delegate respondsToSelector:@selector(sectionProgress:haveLeaveTouchToSectionAreaWithIndex:)]) {
            [_delegate sectionProgress:self haveLeaveTouchToSectionAreaWithIndex:index];
        }
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

- (CAShapeLayer *)maskLayer {
    if (!_maskLayer) {
        _maskLayer = [CAShapeLayer layer];
        _maskLayer.frame = _contentLayer.bounds;
        _maskLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(_minOfWiOrHe/2, _minOfWiOrHe/2)
                                                        radius:_minOfWiOrHe/2-_showLineWidth/2
                                                    startAngle:_startAngle
                                                      endAngle:_startAngle+M_PI*2
                                                     clockwise:YES].CGPath;
        _maskLayer.lineWidth = _showLineWidth;
        _maskLayer.fillColor = [UIColor clearColor].CGColor;
        _maskLayer.strokeColor = [UIColor redColor].CGColor;
    }
    return _maskLayer;
}

- (CALayer *)contentLayer {
    if (!_contentLayer) {
        _contentLayer = [CALayer layer];
        _minOfWiOrHe = MIN(self.frame.size.width, self.frame.size.height);
        _contentLayer.bounds = CGRectMake(0, 0, _minOfWiOrHe, _minOfWiOrHe);
        _contentLayer.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    }
    return _contentLayer;
}

- (CAShapeLayer *)contentBackLayer {
    if (!_contentBackLayer) {
        _contentBackLayer = [CAShapeLayer layer];
        _contentBackLayer.frame = _contentLayer.bounds;
        _contentBackLayer.lineWidth = _showLineWidth;
        _contentBackLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(_minOfWiOrHe/2, _minOfWiOrHe/2)
                                                                radius:_minOfWiOrHe/2-_showLineWidth/2
                                                            startAngle:_startAngle
                                                              endAngle:_startAngle+M_PI*2
                                                             clockwise:YES].CGPath;
        _contentBackLayer.fillColor = [UIColor clearColor].CGColor;
        _contentBackLayer.strokeColor = _lineBackColor.CGColor;
    }
    return _contentBackLayer;
}

@end
