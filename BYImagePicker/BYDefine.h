//
//  BYDefine.h
//  BYImagePicker
//
//  Created by Beryter on 2017/2/23.
//  Copyright © 2017年 Beryter. All rights reserved.
//

#ifndef BYDefine_h
#define BYDefine_h

#define iOS8Later ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
#define iOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
#define iOS9_1Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.1f)
///16进制色值
#define RGB(x) [UIColor colorWithRed:((x & 0xff0000) >> 16)/255.0 green:((x & 0x00ff00) >> 8)/255.0 blue:(x & 0x0000ff)/255.0 alpha:1.0f]
#define RGBA(x,y) [UIColor colorWithRed:((x & 0xff0000) >> 16)/255.0 green:((x & 0x00ff00) >> 8)/255.0 blue:(x & 0x0000ff)/255.0 alpha:y]
#define LineHeight  (1 / [UIScreen mainScreen].scale)

#endif /* BYDefine_h */
