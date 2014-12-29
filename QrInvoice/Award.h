//
//  Award.h
//  QrInvoice
//
//  Created by jakey_lee on 14/7/21.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Award : NSObject

@property (nonatomic, assign) int64_t award_id;
@property (nonatomic, strong) NSString *invoYm;
@property (nonatomic, strong) NSString *superPrizeNo;
@property (nonatomic, strong) NSString *spcPrizeNo;
@property (nonatomic, strong) NSString *firstPrizeNo;
@property (nonatomic, strong) NSString *sixthPrizeNo;
@property (nonatomic, strong) NSString *superPrizeAmt;
@property (nonatomic, strong) NSString *spcPrizeAmt;
@property (nonatomic, strong) NSString *firstPrizeAmt;
@property (nonatomic, strong) NSString *secondPrizeAmt;
@property (nonatomic, strong) NSString *thirdPrizeAmt;
@property (nonatomic, strong) NSString *fourthPrizeAmt;
@property (nonatomic, strong) NSString *fifthPrizeAmt;
@property (nonatomic, strong) NSString *sixthPrizeAmt;

@end
