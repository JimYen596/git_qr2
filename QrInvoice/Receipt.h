//
//  Receipt.h
//  QrInvoice
//
//  Created by jakey_lee on 14/7/24.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Receipt : NSObject

@property (nonatomic, strong) NSString *invID;
@property (nonatomic, strong) NSString *invNum;
@property (nonatomic, strong) NSString *randomNumber;
@property (nonatomic, strong) NSString *invDate;
@property (nonatomic, strong) NSString *invPeriod;
@property (nonatomic, assign) int64_t invSpent;
@property (nonatomic, assign) int64_t invType;
@property (nonatomic, assign) int64_t gotData;
@property (nonatomic, assign) int64_t invLottery;
@property (nonatomic, strong) NSString *reward;

@end
