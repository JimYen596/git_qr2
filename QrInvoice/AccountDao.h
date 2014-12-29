//
//  AccountDao.h
//  QrInvoice
//
//  Created by jakey_lee on 14/7/21.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Account.h"

#define ACCOUNT_SELF @"self"

@interface AccountDao : NSObject

+ (Account*) selectSelf;

+ (BOOL) updateAudio:(BOOL)audio;
+ (BOOL) updateShock:(BOOL)shock;
+ (BOOL) updateNotice:(BOOL)notice;
+ (BOOL) updateBudget:(long long)budget;
+ (BOOL) updateUserTutorial:(BOOL)tutorial;

@end
