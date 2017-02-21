//
//  CKPolylineView.h
//  ChartKit
//
//  Created by yxiang on 2017/2/20.
//  Copyright © 2017年 yxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKPolylineView : UIView

@property (assign, nonatomic) CGFloat space; /// On the x-axis, the distance between each two points.

@property (copy, nonatomic) NSArray *colors; /// Polyline color array.

@property (strong, nonatomic) NSMutableArray *percentsArrays; /// Each polyline, the current array of all points, should be between 0 and 1.

@property (assign, nonatomic) BOOL animation; /// Needs animation.

@property (assign, nonatomic) BOOL isRound; /// Is line round.

@property (assign, nonatomic) NSTimeInterval duration; /// Animation duration.

@property (assign, nonatomic) BOOL isPoint; /// Need show point.

@property (copy, nonatomic) void (^pointHaveClickedBlock) (NSInteger tag, NSInteger index);

@end
