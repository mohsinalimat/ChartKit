//
//  CKBarYaxisView.m
//  ChartKit
//
//  Created by yxiang on 2017/2/10.
//  Copyright © 2017年 yxiang. All rights reserved.
//

#import "CKBarYaxisView.h"
#import "CKMarocs.h"

@implementation CKBarYaxisView {
    NSMutableArray *_labels;
    CALayer *_lineLayer;
}

- (void)setYaxisTitles:(NSArray<__kindof NSString *> *)YaxisTitles {
    if (!YaxisTitles || [YaxisTitles isEqual:_YaxisTitles] || YaxisTitles.count <= 1) return;
    // Clear.
    [self clearView];
    _labels = [NSMutableArray array];
    // Basic value set.
    _titleColor = _titleColor?:CK_RGBA_HEX(0x999999, 1);
    _titleFont = _titleFont?:[UIFont systemFontOfSize:12];
    _lineColor = _lineColor?:CK_RGBA_HEX(0x999999, 1);
    _label2LineSpace = (_label2LineSpace>0)?_label2LineSpace:8.f;
    // Add label.
    CGFloat labelSpace = (CGRectGetHeight(self.frame)-20)/(YaxisTitles.count-1);
    NSMutableArray *centers = [NSMutableArray array];
    for (int i = 0; i < YaxisTitles.count; i ++) {
        UILabel *label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentRight;
        label.textColor = _titleColor;
        label.font = _titleFont;
        label.text = YaxisTitles[i];
        label.frame = CGRectMake(0, labelSpace*i, CGRectGetWidth(self.frame)-_label2LineSpace, 20);
        [_labels addObject:label];
        [self addSubview:label];
        [centers addObject:[NSNumber numberWithFloat:CGRectGetMidY(label.frame)]];
    }
    _yLabelCenterYs = centers.copy;
    _lineLayer = [CALayer layer];
    _lineLayer.backgroundColor = _lineColor.CGColor;
    _lineLayer.frame = CGRectMake(CGRectGetWidth(self.frame)-0.5, 0, 0.5, CGRectGetHeight(self.frame)-10);
    [self.layer addSublayer:_lineLayer];
}

- (void)clearView {
    for (UILabel *label in _labels) {
        [label removeFromSuperview];
    }
    [_labels removeAllObjects];
    _labels = nil;
    [_lineLayer removeFromSuperlayer];
    _lineLayer = nil;
}

@end
