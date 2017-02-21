//
//  CKGradientLayer.m
//  ChartKit
//
//  Created by yxiang on 2017/2/7.
//  Copyright © 2017年 yxiang. All rights reserved.
//

#import "CKGradientLayer.h"

#if __has_feature(objc_arc)
#define BRIDGE_CAST(T) (__bridge T)
#else
#define BRIDGE_CAST(T) (T)
#endif

#define byte unsigned char
#define F2CC(x) ((byte)(255 * x))
#define RGBAF(r,g,b,a) (F2CC(r) << 24 | F2CC(g) << 16 | F2CC(b) << 8 | F2CC(a))
#define RGBA(r,g,b,a) ((byte)r << 24 | (byte)g << 16 | (byte)b << 8 | (byte)a)
#define RGBA_R(c) ((uint)c >> 24 & 255)
#define RGBA_G(c) ((uint)c >> 16 & 255)
#define RGBA_B(c) ((uint)c >> 8 & 255)
#define RGBA_A(c) ((uint)c >> 0 & 255)

static inline byte blerp(byte a, byte b, float w)
{
    return a + w * (b - a);
}
static inline int lerp(int a, int b, float w)
{
    return RGBA(blerp(RGBA_R(a), RGBA_R(b), w),
                blerp(RGBA_G(a), RGBA_G(b), w),
                blerp(RGBA_B(a), RGBA_B(b), w),
                blerp(RGBA_A(a), RGBA_A(b), w));
}
static inline int multiplyByAlpha(int c)
{
    float a = RGBA_A(c) / 255.0;
    return RGBA((byte)(RGBA_R(c) * a),
                (byte)(RGBA_G(c) * a),
                (byte)(RGBA_B(c) * a),
                RGBA_A(c));
}
void angleGradient(byte* data, int w, int h, int* colors, int colorCount, float* locations, int locationCount)
{
    if (colorCount < 1) return;
    if (locationCount > 0 && locationCount != colorCount) return;
    
    int* p = (int*)data;
    float centerX = (float)w / 2;
    float centerY = (float)h / 2;
    
    for (int y = 0; y < h; y++)
        for (int x = 0; x < w; x++) {
            float dirX = x - centerX;
            float dirY = y - centerY;
            float angle = atan2f(dirY, dirX);
            if (dirY < 0) angle += 2 * M_PI;
            angle /= 2 * M_PI;
            
            int index = 0, nextIndex = 0;
            float t = 0;
            
            if (locationCount > 0) {
                for (index = locationCount - 1; index >= 0; index--) {
                    if (angle >= locations[index]) {
                        break;
                    }
                }
                if (index >= locationCount) index = locationCount - 1;
                nextIndex = index + 1;
                if (nextIndex >= locationCount) nextIndex = locationCount - 1;
                float ld = locations[nextIndex] - locations[index];
                t = ld <= 0 ? 0 : (angle - locations[index]) / ld;
            }
            else {
                t = angle * (colorCount - 1);
                index = t;
                t -= index;
                nextIndex = index + 1;
                if (nextIndex >= colorCount) nextIndex = colorCount - 1;
            }
            
            int lc = colors[index];
            int rc = colors[nextIndex];
            int color = lerp(lc, rc, t);
            color = multiplyByAlpha(color);
            *p++ = color;
        }
}

@implementation CKGradientLayer

#pragma mark - Life Cycle

- (instancetype)init {
    if ([super init]) {
        self.needsDisplayOnBoundsChange = YES;
        self.gradientType = CKGTLine;
        self.startPoint = CGPointMake(0.5, 0);
        self.endPoint = CGPointMake(0.5, 1);
    }
    return self;
}

- (void)drawInContext:(CGContextRef)ctx {
    
    if (self.gradientType == CKGTLine) {
        CGContextSetFillColorWithColor(ctx, self.backgroundColor);
        CGRect rect = CGContextGetClipBoundingBox(ctx);
        CGContextFillRect(ctx, rect);
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
        gradientLayer.colors = self.colors;
        gradientLayer.startPoint = self.startPoint;
        gradientLayer.endPoint = self.endPoint;
        [self addSublayer:gradientLayer];
    }else if (self.gradientType == CKGTAngle) {
        CGContextSetFillColorWithColor(ctx, self.backgroundColor);
        CGContextRotateCTM(ctx, self.startAngle);
        CGRect rect = CGContextGetClipBoundingBox(ctx);
        CGContextFillRect(ctx, rect);
        
        CGImageRef img = [self newImageGradientInRect:rect];
        CGContextDrawImage(ctx, rect, img);
        CGImageRelease(img);
    }
}

- (id)copyWithZone:(NSZone *)zone
{
    CKGradientLayer *layer = [CKGradientLayer layer];
    layer.frame = self.frame;
    layer.colors = self.colors;
    layer.locations = self.locations;
    layer.startAngle = self.startAngle;
    layer.gradientType = self.gradientType;
    layer.startPoint = self.startPoint;
    layer.endPoint = self.endPoint;
    return layer;
}

#pragma mark - Private Methods

- (CGImageRef)newImageGradientInRect:(CGRect)rect
{
    return [[self class] newImageGradientInRect:rect colors:self.colors locations:self.locations];
}

#pragma mark - Public Methods

+ (CGImageRef)newImageGradientInRect:(CGRect)rect colors:(NSArray *)colors locations:(NSArray *)locations
{
    int w = CGRectGetWidth(rect);
    int h = CGRectGetHeight(rect);
    int bitsPerComponent = 8;
    int bpp = 4 * bitsPerComponent / 8;
    int byteCount = w * h * bpp;
    
    int colorCount = (int)colors.count;
    int locationCount = (int)locations.count;
    int* cols = NULL;
    float* locs = NULL;
    
    if (colorCount > 0) {
        cols = calloc(colorCount, bpp);
        int *p = cols;
        for (id cg in colors) {
            CGColorRef c = BRIDGE_CAST(CGColorRef)cg;
            float r, g, b, a;
            
            size_t n = CGColorGetNumberOfComponents(c);
            const CGFloat *comps = CGColorGetComponents(c);
            if (comps == NULL) {
                *p++ = 0;
                continue;
            }
            r = comps[0];
            if (n >= 4) {
                g = comps[1];
                b = comps[2];
                a = comps[3];
            }
            else {
                g = b = r;
                a = comps[1];
            }
            *p++ = RGBAF(r, g, b, a);
        }
    }
    if (locationCount > 0 && locationCount == colorCount) {
        locs = calloc(locationCount, sizeof(locs[0]));
        float *p = locs;
        for (NSNumber *n in locations) {
            *p++ = [n floatValue];
        }
    }
    
    byte* data = malloc(byteCount);
    angleGradient(data, w, h, cols, colorCount, locs, locationCount);
    
    if (cols) free(cols);
    if (locs) free(locs);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Little;
    CGContextRef ctx = CGBitmapContextCreate(data, w, h, bitsPerComponent, w * bpp, colorSpace, bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    CGImageRef img = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    free(data);
    return img;
}

@end

