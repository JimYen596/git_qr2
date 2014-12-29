//
//  Account.h
//  QrInvoice
//
//  Created by jakey_lee on 14/7/21.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Account : NSObject

@property (nonatomic, assign) int64_t account_id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL audio;
@property (nonatomic, assign) BOOL shock;
@property (nonatomic, assign) BOOL notice;
@property (nonatomic, assign) BOOL userTutorial;
@property (nonatomic, assign) int64_t budget;

@end
