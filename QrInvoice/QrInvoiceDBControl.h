//
//  QrInvoiceDBControl.h
//  QrInvoice
//
//  Created by Yen on 2014/7/15.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "invData.h"
#import "detailData.h"

@interface QrInvoiceDBControl : NSObject
+(QrInvoiceDBControl*)shareInstance;
@end
