//
//  detailData.h
//  QrInvoice
//
//  Created by Yen on 2014/7/1.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface detailData : NSObject
@property (nonatomic) NSString *invID;
@property (nonatomic) NSString *invNum;
@property (nonatomic) NSString *description;
@property (nonatomic) NSString *quantity;
@property (nonatomic) NSString *unitPrice;
@property (nonatomic) NSString *amount;
@property (nonatomic) int productType;
@property (nonatomic) int itemID;
@end
