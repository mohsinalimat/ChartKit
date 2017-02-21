//
//  CKBarYaxisView.h
//  ChartKit
//
//  Created by yxiang on 2017/2/10.
//  Copyright © 2017年 yxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKBarYaxisView : UIView

@property (copy, nonatomic) UIFont *titleFont; /// Label.font. Default is `systemFontOfSize:12`.

@property (copy, nonatomic) UIColor *titleColor; /// Label.textColor. Default is 0x999999;

@property (copy, nonatomic) UIColor *lineColor; /// Line color of y-axis.

@property (copy, nonatomic) NSArray <__kindof NSString *> *YaxisTitles; /// Y-aixs labels title. Label.width = self.frame.width-self.label2LineSpace, right aligment.

@property (assign, nonatomic) CGFloat label2LineSpace; /// Label to line space. Default is 8.f.

@property (copy, nonatomic, readonly) NSArray <__kindof NSNumber *> *yLabelCenterYs;

- (void)clearView;

@end
