//
//  AwardDao.h
//  QrInvoice
//
//  Created by jakey_lee on 14/7/21.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Award.h"

@interface AwardDao : NSObject

+ (Award*) selectAwardWithInvoYm:(NSString*)invoYm;

+ (BOOL) insertWithAward:(Award*)award;

+ (BOOL) isContainInvoYm:(NSString*)invoYm;

@end
