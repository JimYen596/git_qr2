//
//  AccountDao.m
//  QrInvoice
//
//  Created by jakey_lee on 14/7/21.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import "AccountDao.h"
#import "FMDatabase.h"

@implementation AccountDao

+ (Account*) selectSelf
{
    FMDatabase *fmdb = [FMDatabase databaseWithPath:DB_PATH];
    
    Account *account = nil;
    if ([fmdb open]) {
        FMResultSet *rs = [fmdb executeQuery:@"SELECT * FROM Account WHERE name = ?", ACCOUNT_SELF];
        if ([rs next]) {
            account = [[Account alloc] init];
            account.account_id = [rs intForColumn:@"account_id"];
            account.name = [rs stringForColumn:@"name"];
            account.audio = [rs boolForColumn:@"audio"];
            account.shock = [rs boolForColumn:@"shock"];
            account.notice = [rs boolForColumn:@"notice"];
            account.budget = [rs longLongIntForColumn:@"budget"];
            account.userTutorial = [rs boolForColumn:@"userTutorial"];
        }
        
        [rs close];
        [fmdb close];
    }
    
    return account;
}

+ (BOOL) updateAudio:(BOOL)audio
{
    FMDatabase *fmdb = [FMDatabase databaseWithPath:DB_PATH];
    BOOL success = NO;
    if ([fmdb open]) {
        success = [fmdb executeUpdate:@"UPDATE Account SET audio = ? WHERE name = ?", [NSNumber numberWithInt:audio], ACCOUNT_SELF];
        
        [fmdb close];
    }
    
    return success;
}

+ (BOOL) updateShock:(BOOL)shock
{
    FMDatabase *fmdb = [FMDatabase databaseWithPath:DB_PATH];
    BOOL success = NO;
    if ([fmdb open]) {
        success = [fmdb executeUpdate:@"UPDATE Account SET shock = ? WHERE name = ?", [NSNumber numberWithInt:shock], ACCOUNT_SELF];
        
        [fmdb close];
    }
    
    return success;
}

+ (BOOL) updateNotice:(BOOL)notice
{
    FMDatabase *fmdb = [FMDatabase databaseWithPath:DB_PATH];
    BOOL success = NO;
    if ([fmdb open]) {
        success = [fmdb executeUpdate:@"UPDATE Account SET notice = ? WHERE name = ?", [NSNumber numberWithInt:notice], ACCOUNT_SELF];
        
        [fmdb close];
    }
    
    return success;
}

+ (BOOL) updateBudget:(long long)budget
{
    FMDatabase *fmdb = [FMDatabase databaseWithPath:DB_PATH];
    BOOL success = NO;
    if ([fmdb open]) {
        success = [fmdb executeUpdate:@"UPDATE Account SET budget = ? WHERE name = ?", [NSNumber numberWithLongLong:budget], ACCOUNT_SELF];
        
        [fmdb close];
    }
    
    return success;
}

+ (BOOL) updateUserTutorial:(BOOL)tutorial
{
    FMDatabase *fmdb = [FMDatabase databaseWithPath:DB_PATH];
    BOOL success = NO;
    if ([fmdb open]) {
        success = [fmdb executeUpdate:@"UPDATE Account SET userTutorial = ? WHERE name = ?", [NSNumber numberWithInt:tutorial], ACCOUNT_SELF];
        
        [fmdb close];
    }
    
    return success;
}

@end
