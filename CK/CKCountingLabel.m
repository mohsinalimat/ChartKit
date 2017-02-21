//
//  CKCountingLabel.m
//  ChartKit
//
//  Created by yxiang on 2017/2/7.
//  Copyright © 2017年 yxiang. All rights reserved.
//

#import "CKCountingLabel.h"

@implementation CKCountingLabel {
    CADisplayLink *_timer;
    NSTimeInterval _duration;
    NSTimeInterval _timeStamp;
    CGFloat _changeOffset;
}

@synthesize animationEndCountingNumber = _animationEndCountingNumber;
@synthesize isAnimation = _isAnimation;

- (void)setNumberStringTo:(CGFloat)toStrNumber withDuration:(NSTimeInterval)duration animation:(BOOL)flag {
    if (flag) {
        if (_isAnimation) return;
        //    _timingFuction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        
        _duration = duration;
        _timeStamp = 0;
        _changeOffset = toStrNumber-_animationEndCountingNumber;
        
        _timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(respondToTimer:)];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        if ([[[UIDevice currentDevice] systemVersion] doubleValue]>=10.0) _timer.preferredFramesPerSecond = 30;
        else _timer.frameInterval = 2;
#pragma clang diagnostic pop
        [_timer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }else {
        [self setTextValue:toStrNumber];
    }
}

- (CGFloat)timingFunctionToRate:(CGFloat)percent {
//    CGPoint control1, control2;
//    [_timingFuction getControlPointAtIndex:1 values:(float *)&control1];
//    [_timingFuction getControlPointAtIndex:2 values:(float *)&control2];
//    CGFloat p0y = 0;
//    CGFloat p1y = control1.y;
//    CGFloat p2y = control2.y;
//    CGFloat p3y = 1;
//    CGFloat rValue = p0y*pow((1-percent), 3)+3*p1y*percent*pow((1-percent), 2)+3*p2y*pow(percent, 2)*(1-percent)+p3y*pow(percent, 3);
//    return rValue;
    return MIN(1/0.58*percent, 1);
}

- (void)respondToTimer:(CADisplayLink *)timer {
    if (_timeStamp<=_duration) {
        _isAnimation = YES;
        _timeStamp += timer.duration;
        CGFloat percent = [self timingFunctionToRate:MIN((_timeStamp/_duration), 1)];
        CGFloat offset = _changeOffset*percent;
        CGFloat offsetValue = _animationEndCountingNumber+offset;
        [self setTextValue:offsetValue];
    }
    else
    // Animation stop.
    {
        _isAnimation = NO;
        _animationEndCountingNumber += _changeOffset;
        [_timer invalidate];
        _timer = nil;
        _timeStamp = 0;
    }
}

- (void)setTextValue:(CGFloat)value {
    
    // int
    if([self.format rangeOfString:@"%(.*)d" options:NSRegularExpressionSearch].location != NSNotFound || [self.format rangeOfString:@"%(.*)i"].location != NSNotFound ) {
        self.text = [NSString stringWithFormat:@"%.0f",value];
    }
    else
    // float
    {
        self.text = [NSString stringWithFormat:self.format,value];
    }
    self.text = [self.text stringByAppendingString:self.util];
}

@end
