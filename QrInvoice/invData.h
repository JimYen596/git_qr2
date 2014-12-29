//
//  invData.h
//  QrInvoice
//
//  Created by Yen on 2014/7/1.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface invData : NSObject
@property(nonatomic) NSString *invID;
@property(nonatomic) NSString *invNum;
@property(nonatomic) NSString *randomNum;
@property(nonatomic) NSString *invDate;
@property(nonatomic) NSString *invPeriod;
@property(nonatomic) int invspent;
@property(nonatomic) int invType;
@property(nonatomic) int gotData;
@property(nonatomic) int lottery;
@property(nonatomic) int reward;
@end
