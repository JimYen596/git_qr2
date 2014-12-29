//
//  AwardDao.m
//  QrInvoice
//
//  Created by jakey_lee on 14/7/21.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import "AwardDao.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "Receipt.h"

@implementation AwardDao

+ (Award*) selectAwardWithInvoYm:(NSString*)invoYm
{
    FMDatabase *fmdb = [FMDatabase databaseWithPath:DB_PATH];
    
    Award *award = nil;
    if ([fmdb open]) {
        FMResultSet *rs = [fmdb executeQuery:@"SELECT * FROM Award WHERE invoYm = ?", invoYm];
        if ([rs next]) {
            award = [[Award alloc] init];
            award.award_id = [rs intForColumn:@"award_id"];
            award.invoYm = [rs stringForColumn:@"invoYm"];
            award.superPrizeNo = [rs stringForColumn:@"superPrizeNo"];
            award.spcPrizeNo = [rs stringForColumn:@"spcPrizeNo"];
            award.firstPrizeNo = [rs stringForColumn:@"firstPrizeNo"];
            award.sixthPrizeNo = [rs stringForColumn:@"sixthPrizeNo"];
            award.superPrizeAmt = [rs stringForColumn:@"superPrizeAmt"];
            award.spcPrizeAmt = [rs stringForColumn:@"spcPrizeAmt"];
            award.firstPrizeAmt = [rs stringForColumn:@"firstPrizeAmt"];
            award.secondPrizeAmt = [rs stringForColumn:@"secondPrizeAmt"];
            award.thirdPrizeAmt = [rs stringForColumn:@"thirdPrizeAmt"];
            award.fourthPrizeAmt = [rs stringForColumn:@"fourthPrizeAmt"];
            award.fifthPrizeAmt = [rs stringForColumn:@"fifthPrizeAmt"];
            award.sixthPrizeAmt = [rs stringForColumn:@"sixthPrizeAmt"];
        }
        
        [rs close];
        [fmdb close];
    }
    
    return award;
}

+ (BOOL) insertWithAward:(Award*)award
{
    FMDatabase *fmdb = [FMDatabase databaseWithPath:DB_PATH];
    BOOL success = NO;
    if ([fmdb open]) {
        success = [fmdb executeUpdate:@"INSERT INTO Award (invoYm, superPrizeNo, spcPrizeNo, firstPrizeNo, sixthPrizeNo, superPrizeAmt, spcPrizeAmt, firstPrizeAmt, secondPrizeAmt, thirdPrizeAmt, fourthPrizeAmt, fifthPrizeAmt, sixthPrizeAmt) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" withArgumentsInArray:
                   @[award.invoYm,
                     award.superPrizeNo,
                     award.spcPrizeNo,
                     award.firstPrizeNo,
                     award.sixthPrizeNo,
                     award.superPrizeAmt,
                     award.spcPrizeAmt,
                     award.firstPrizeAmt,
                     award.secondPrizeAmt,
                     award.thirdPrizeAmt,
                     award.fourthPrizeAmt,
                     award.fifthPrizeAmt,
                     award.sixthPrizeAmt]];
        
        [fmdb close];
    }
    
    return success;
}

// 包含對應的期數(如10302)
+ (BOOL) isContainInvoYm:(NSString*)invoYm
{
    FMDatabase *fmdb = [FMDatabase databaseWithPath:DB_PATH];
    int count = 0;
    if ([fmdb open]) {
        count = [fmdb intForQuery:@"SELECT count(*) FROM Award WHERE invoYm = ?", invoYm];
        
        [fmdb close];
    }
    
    return count == 1;
}

@end
