//
//  ReceiptDao.m
//  QrInvoice
//
//  Created by jakey_lee on 14/7/24.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import "ReceiptDao.h"
#import "FMDatabase.h"

@implementation ReceiptDao

+ (NSArray*) selectReceiptWithInvoYm:(NSString*)invoYm
{
    FMDatabase *fmdb = [FMDatabase databaseWithPath:DB_PATH];
    
    Receipt *receipt;
    NSMutableArray *receiptList = [NSMutableArray array];
    if ([fmdb open]) {
        FMResultSet *rs = [fmdb executeQuery:@"SELECT * FROM Receipt WHERE invPeriod = ?", invoYm];
        
        while ([rs next]) {
            receipt = [[Receipt alloc] init];
            receipt.invID = [rs stringForColumn:@"invID"];
            receipt.invNum = [rs stringForColumn:@"invNum"];
            receipt.randomNumber = [rs stringForColumn:@"randomNumber"];
            receipt.invDate = [rs stringForColumn:@"invDate"];
            receipt.invPeriod = [rs stringForColumn:@"invPeriod"];
            receipt.invSpent = [rs longLongIntForColumn:@"invSpent"];
            receipt.invType = [rs longLongIntForColumn:@"invType"];
            receipt.invLottery = [rs longLongIntForColumn:@"invLottery"];
            receipt.invSpent = [rs longLongIntForColumn:@"invSpent"];
            receipt.reward = [rs stringForColumn:@"reward"];
            
            [receiptList addObject:receipt];
        }
        
        [rs close];
        [fmdb close];
    }
    
    return receiptList;
}

+ (NSArray*) selectReceiptNotLotteryWithInvoYm:(NSString*)invoYm
{
    FMDatabase *fmdb = [FMDatabase databaseWithPath:DB_PATH];
    
    Receipt *receipt;
    NSMutableArray *receiptList = [NSMutableArray array];
    if ([fmdb open]) {
        FMResultSet *rs = [fmdb executeQuery:@"SELECT * FROM Receipt WHERE invPeriod = ? and invLottery = 0", invoYm];
        
        while ([rs next]) {
            receipt = [[Receipt alloc] init];
            receipt.invID = [rs stringForColumn:@"invID"];
            receipt.invNum = [rs stringForColumn:@"invNum"];
            receipt.randomNumber = [rs stringForColumn:@"randomNumber"];
            receipt.invDate = [rs stringForColumn:@"invDate"];
            receipt.invPeriod = [rs stringForColumn:@"invPeriod"];
            receipt.invSpent = [rs longLongIntForColumn:@"invSpent"];
            receipt.invType = [rs longLongIntForColumn:@"invType"];
            receipt.invLottery = [rs longLongIntForColumn:@"invLottery"];
            receipt.invSpent = [rs longLongIntForColumn:@"invSpent"];
            receipt.reward = [rs stringForColumn:@"reward"];
            
            [receiptList addObject:receipt];
        }
        
        [rs close];
        [fmdb close];
    }
    
    return receiptList;
}

+ (NSArray*) selectReceiptLotteryWithInvoYm:(NSString*)invoYm
{
    FMDatabase *fmdb = [FMDatabase databaseWithPath:DB_PATH];
    
    Receipt *receipt;
    NSMutableArray *receiptList = [NSMutableArray array];
    if ([fmdb open]) {
        FMResultSet *rs = [fmdb executeQuery:@"SELECT * FROM Receipt WHERE invPeriod = ? and invLottery = 2", invoYm];
        
        while ([rs next]) {
            receipt = [[Receipt alloc] init];
            receipt.invID = [rs stringForColumn:@"invID"];
            receipt.invNum = [rs stringForColumn:@"invNum"];
            receipt.randomNumber = [rs stringForColumn:@"randomNumber"];
            receipt.invDate = [rs stringForColumn:@"invDate"];
            receipt.invPeriod = [rs stringForColumn:@"invPeriod"];
            receipt.invSpent = [rs longLongIntForColumn:@"invSpent"];
            receipt.invType = [rs longLongIntForColumn:@"invType"];
            receipt.invLottery = [rs longLongIntForColumn:@"invLottery"];
            receipt.invSpent = [rs longLongIntForColumn:@"invSpent"];
            receipt.reward = [rs stringForColumn:@"reward"];
            
            [receiptList addObject:receipt];
        }
        
        [rs close];
        [fmdb close];
    }
    
    return receiptList;
}

+ (BOOL) updateInvLotteryAndRewardWithReceipt:(Receipt*)receipt
{
    FMDatabase *fmdb = [FMDatabase databaseWithPath:DB_PATH];
    BOOL success = NO;
    if ([fmdb open]) {
        success = [fmdb executeUpdate:@"UPDATE Receipt SET invLottery = ?, reward = ? WHERE invID = ?", [NSNumber numberWithLongLong:receipt.invLottery], receipt.reward, receipt.invID];
        
        [fmdb close];
    }
    
    return success;
}

+ (NSArray*) selectInvPeriodList
{
    FMDatabase *fmdb = [FMDatabase databaseWithPath:DB_PATH];
    
    NSMutableArray *list = [NSMutableArray array];
    if ([fmdb open]) {
        FMResultSet *rs = [fmdb executeQuery:@"SELECT DISTINCT invPeriod FROM Receipt ORDER BY cast(invPeriod as unsigned) DESC"];
        
        while ([rs next]) {
            NSString *invPeriod = [rs stringForColumn:@"invPeriod"];
            
            [list addObject:invPeriod];
        }
        
        [rs close];
        [fmdb close];
    }
    
    return list;
}

@end
