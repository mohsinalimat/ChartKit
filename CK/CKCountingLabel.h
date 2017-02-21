//
//  CKCountingLabel.h
//  ChartKit
//
//  Created by yxiang on 2017/2/7.
//  Copyright © 2017年 yxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKCountingLabel : UILabel

//@property (strong, nonatomic) CAMediaTimingFunction *timingFuction; // I want to translate to function, but failed.

@property (assign, nonatomic, readonly) BOOL isAnimation; // Is timer runing.

@property (assign, nonatomic, readonly) CGFloat animationEndCountingNumber; // The number of animation did stop, mean to `toStrNumber`.

@property (copy, nonatomic) NSString *util; // Last word of number.

@property (copy, nonatomic) NSString *format; // Unit.

/**
 *  Begin animation, and will to number.
 *  @param toStrNumber A will to number.
 *  @param duration Animation total duration
 *  @param flag If needs animation flag. */
- (void)setNumberStringTo:(CGFloat)toStrNumber withDuration:(NSTimeInterval)duration animation:(BOOL)flag;

@end
