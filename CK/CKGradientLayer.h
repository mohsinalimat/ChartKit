//
//  CKGradientLayer.h
//  ChartKit
//
//  Created by yxiang on 2017/2/7.
//  Copyright © 2017年 yxiang. All rights reserved.
//
//  Thanks to Pavel Ivashkov for providing the source code for creating gradient layers. I just add a normal gradient layer, other code copy from `AngleGradientLayer`.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CKGradientType) {
    CKGTAngle, // Angle gradient.
    CKGTLine   // Line gradient.
};

CA_CLASS_AVAILABLE (10.6, 3.0, 9.0, 2.0)
@interface CKGradientLayer : CALayer <NSCopying>

/*  The array of CGColorRef objects defining the color of each gradient
 *  stop. Defaults to nil. Animatable. */
@property (nullable, copy) NSArray *colors;

/*  An optional array of NSNumber objects defining the location of each
 *  gradient stop as a value in the range [0,1]. The values must be
 *  monotonically increasing. If a nil array is given, the stops are
 *  assumed to spread uniformly across the [0,1] range. When rendered,
 *  the colors are mapped to the output colorspace before being
 *  interpolated. Defaults to nil. */
@property (nullable, copy) NSArray<NSNumber *> *locations;

@property (nonatomic) CGFloat startAngle; // Start angle. Default is 0. Only for CKGTAngle.

@property (assign, nonatomic) CKGradientType gradientType; // Gradent type. Default is CKGTLine.

/* The start and end points of the gradient when drawn into the layer's
 * coordinate space. The start point corresponds to the first gradient
 * stop, the end point to the last gradient stop. Both points are
 * defined in a unit coordinate space that is then mapped to the
 * layer's bounds rectangle when drawn. (I.e. [0,0] is the bottom-left
 * corner of the layer, [1,1] is the top-right corner.) The default values
 * are [.5,0] and [.5,1] respectively. Both are animatable. Only for CKGTLine. */
@property CGPoint startPoint;
@property CGPoint endPoint;

/* The core method generating gradient image.
 */
+ (CGImageRef)newImageGradientInRect:(CGRect)rect colors:(NSArray *)colors locations:(NSArray *)locations;

@end

NS_ASSUME_NONNULL_END
