//
//  UIColor+Hex.h
//  UIColor+Hex.h
//
//  Created by jakey_lee on 12/12/19.
//  Copyright (c) 2012年 jakey_lee. All rights reserved.
//

#import <UIKit/UIKit.h>

/////////////////////////////////////////////////////////////////////////////////////////////

/** 
 * Description of the Class
 *
 */
@interface UIColor (Hex)

+ (UIColor*) colorWithHexRed: (int)red green: (int)green blue: (int)blue alpha: (float)alpha;

+ (UIColor*) colorWithHexString:(NSString*)hex;

@end
