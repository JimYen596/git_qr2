//
//  QrInvoiceDBControl.m
//  QrInvoice
//
//  Created by Yen on 2014/7/15.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//
#import "QrInvoiceDBControl.h"
#define DB_PATH             [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"user.sqlite"]
#define CREATE_RECEIPT_TABLE @"CREATE TABLE 'Receipt' ('invID' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL ,'invNum' VARCHAR(10),'randomNumber' VARCHAR(4),'invDate' VARCHAR(8),'invPeriod' VARCHAR(5),'invSpent' INTEGER,'invType' INTEGER,'gotData' INTEGER,'invLottery' INTEGER,'reward' VARCHAR(10))"
#define CREATE_DETAILS_TABLE @"CREATE TABLE 'Details' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL ,'invNum' VARCHAR(10),'description' VARCHAR(30),'quantity' VARCHAR(4),'unitPrice' VARCHAR(8),'amount' VARCHAR(10),'productType' INTEGER)"
#define CREATE_AWARD_TABLE   @"CREATE TABLE 'Award' ('invYM' VARCHAR(5), 'superPrizeNo' VARCHAR(8), 'spcPrizeNo' VARCHAR(8), 'spcPrizeNo2' VARCHAR(8), 'spcPrizeNo3' VARCHAR(8), 'firstPrizeNo' VARCHAR(8), 'firstPrizeNo2' VARCHAR(8), 'firstPrizeNo3' VARCHAR(8), 'firstPrizeNo4' VARCHAR(8), 'firstPrizeNo5' VARCHAR(8), 'firstPrizeNo6' VARCHAR(8), 'firstPrizeNo7' VARCHAR(8), 'firstPrizeNo8' VARCHAR(8), 'firstPrizeNo9' VARCHAR(8), 'firstPrizeNo10' VARCHAR(8), 'sixthPrizeNo' VARCHAR(8), 'sixthPrizeNo2' VARCHAR(8), 'sixthPrizeNo3' VARCHAR(8))"
#define QUERY_RECEIPT_WITH_PERIOD @"select * from Receipt where invPeriod = ?"
#define QUERY_RECEIPT_WITH_PERIOD_SEARCH @"select * from Receipt where invPeriod = ? AND invNum in (select distinct invNum from Details where description like '%%%@%%' )"
#define QUERY_ITEMS_WITH_INVNUM @"select * from Details where invNum = ?"
#define DELETE_RECEIPTS @"delete from Receipt WHERE invNum in (%@)"
#define DELETE_ITEMS @"delete from Details WHERE invNum in (%@)"

@interface QrInvoiceDBControl()
{
    FMDatabase *db;
}
@end

static QrInvoiceDBControl *instance = nil;

@implementation QrInvoiceDBControl
+(QrInvoiceDBControl*)shareInstance
{
    @synchronized(self){
      if(instance == nil){
          instance = [[QrInvoiceDBControl alloc] init];
      }
    }
    return instance;
}
-(id)init
{
    self = [super init];
    if(self){
        [self openDB];
    }
    return self;
}
-(void)openDB
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:DB_PATH] == NO){
        db = [FMDatabase databaseWithPath:DB_PATH];
        [self createTable];
    }
        db = [FMDatabase databaseWithPath:DB_PATH];
}
-(void)createTable
{
    if([db open]){
        BOOL createReceipt = [db executeUpdate:CREATE_RECEIPT_TABLE];
        BOOL createDetails = [db executeUpdate:CREATE_DETAILS_TABLE];
        BOOL createAward = [db executeUpdate:CREATE_AWARD_TABLE];
        if(createReceipt){
            NSLog(@"Success to create Receipt table");
        }else{
            NSLog(@"Error to create Receipt table");
        }
        if(createDetails){
            NSLog(@"Success to create Details table");
        }else{
            NSLog(@"Error to create Details table");
        }
        if(createAward){
            NSLog(@"Success to create Award table");
        }else{
            NSLog(@"Error to create Award table");
        }
        [db close];
    }else{
        NSLog(@"Error to open DB");
    }
}

#pragma Query
-(NSMutableArray*)queryReceiptWithPeriod:(NSString*)period
{
    NSMutableArray *dataArray = [@[] mutableCopy];
    if([db open]){
      FMResultSet * rs = [db executeQuery:QUERY_RECEIPT_WITH_PERIOD,period];
      while ([rs next]) {
          invData *Data = [[invData alloc]init];
          Data.invID = [rs stringForColumn:@"invID"];
          Data.invNum = [rs stringForColumn:@"invNum"];
          Data.randomNum = [rs stringForColumn:@"randomNumber"];
          Data.invDate = [rs stringForColumn:@"invDate"];
          Data.invPeriod = [rs stringForColumn:@"invPeriod"];
          Data.invspent = [rs intForColumn:@"invSpent"];
          Data.invType = [rs intForColumn:@"invType"];
          Data.gotData = [rs intForColumn:@"gotData"];
          Data.lottery = [rs intForColumn:@"invLottery"];
          Data.reward = [rs intForColumn:@"reward"];
          [dataArray addObject:Data];
      }
       [db close];
    }
    return dataArray;
}
-(NSMutableArray*)queryReceiptWithPeriod:(NSString*)period searchWord:(NSString*)searchWord
{
    NSMutableArray *dataArray = [@[] mutableCopy];
    NSString *sql = [NSString stringWithFormat:QUERY_RECEIPT_WITH_PERIOD_SEARCH,searchWord];
    if([db open]){
        FMResultSet * rs = [db executeQuery:sql,period];
        while ([rs next]) {
            invData *Data = [[invData alloc]init];
            Data.invID = [rs stringForColumn:@"invID"];
            Data.invNum = [rs stringForColumn:@"invNum"];
            Data.randomNum = [rs stringForColumn:@"randomNumber"];
            Data.invDate = [rs stringForColumn:@"invDate"];
            Data.invPeriod = [rs stringForColumn:@"invPeriod"];
            Data.invspent = [rs intForColumn:@"invSpent"];
            Data.invType = [rs intForColumn:@"invType"];
            Data.gotData = [rs intForColumn:@"gotData"];
            Data.lottery = [rs intForColumn:@"invLottery"];
            Data.reward = [rs intForColumn:@"reward"];
            [dataArray addObject:Data];
        }
        [db close];
    }
    return dataArray;
}
-(NSMutableArray*)queryItemsWithInvNumber:(NSString*)invNum
{
    NSMutableArray *dataArray = [@[] mutableCopy];
    if ([db open]) {
        FMResultSet * rs = [db executeQuery:QUERY_ITEMS_WITH_INVNUM,invNum];
        while ([rs next]) {
            detailData *Data = [[detailData alloc]init];
            Data.invNum = [rs stringForColumn:@"invNum"];
            Data.description = [rs stringForColumn:@"description"];
            Data.quantity = [rs stringForColumn:@"quantity"];
            Data.unitPrice = [rs stringForColumn:@"unitPrice"];
            Data.amount = [rs stringForColumn:@"amount"];
            Data.productType = [rs intForColumn:@"productType"];
            Data.itemID = [rs intForColumn:@"id"];
            [dataArray addObject:Data];
        }
        [db close];
    }
    return dataArray;
}
#pragma DELETE
-(void)deleteReceipts:(NSString*)selectedStr
{
    if ([db open]) {
        BOOL res = [db executeUpdate:DELETE_RECEIPTS,selectedStr];
        if (!res) {
            debugLog(@"error to delete data");
        } else {
            debugLog(@"succ to delete inv data");
            if([db executeUpdate:DELETE_ITEMS,selectedStr]){
                debugLog(@"succ to delete item data");
            }
        }
        [db close];
    }
}
#pragma UPDATE

#pragma INSERT

@end
