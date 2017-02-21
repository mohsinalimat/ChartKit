//
//  CKMarocs.h
//  ChartKit
//
//  Created by yxiang on 2017/2/7.
//  Copyright © 2017年 yxiang. All rights reserved.
//

#ifndef CKMarocs_h
#define CKMarocs_h

/**
 *  Color form hex value. */
#define CK_RGBA_HEX(c, a) [UIColor colorWithRed:(((c&0xFF0000)>>16))/255.0 green:(((c&0xFF00)>>8))/255.0 blue:((c&0xFF))/255.0 alpha:a]

#endif /* CKMarocs_h */
