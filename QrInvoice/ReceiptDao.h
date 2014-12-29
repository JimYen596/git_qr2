//
//  ReceiptDao.h
//  QrInvoice
//
//  Created by jakey_lee on 14/7/24.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Receipt.h"

@interface ReceiptDao : NSObject

+ (NSArray*) selectReceiptWithInvoYm:(NSString*)invoYm;

// 未開獎名單
+ (NSArray*) selectReceiptNotLotteryWithInvoYm:(NSString*)invoYm;

// 中獎名單
+ (NSArray*) selectReceiptLotteryWithInvoYm:(NSString*)invoYm;

+ (BOOL) updateInvLotteryAndRewardWithReceipt:(Receipt*)receipt;

+ (NSArray*) selectInvPeriodList;

@end
