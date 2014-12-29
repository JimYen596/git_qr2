//
//  ACUtility.h
//  WinG_APP
//
//  Created by ChaLin LEE on 2014/1/3.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Award.h"

#define DATE_DEFAULT_FORMAT @"yyyy_MM_dd_HH"

@protocol InsertAwardDelegate <NSObject>
@required
-(void) receiveSuccess:(Award*)award invoYm:(NSString*)invoYm;
-(void) receiveError:(NSString*)errStr errCode:(int) errCode;
@end

typedef enum
{
    QRCode = 0,
    Barcode = 1
}CodeType;

@interface ACUtility : NSObject

+(NSString *)getServerUrlString;

+(NSString *)getInvAppUrlString;


+(NSString *)getDateNowDateString;

+(NSDate *)getDateFromDateString:(NSString *)sourceDateString;
+ (NSString *)intervalSinceNow: (NSString *) theDate;
+ (NSInteger)getDateToDateDays:(NSDate *)date withSaveDate:(NSDate *)saveDate;

+(UIImage *)resizeImage:(UIImage *)image withMaxWidth:(float) maxWidth andMaxHeight:(float)maxHeight;

+ (NSString *)random4Number;

+(NSDictionary*)jsonToDictionary:(NSObject*)object;
-(NSDictionary*)convertDetailsUTF8ToCH:(NSDictionary*)dic;
+ (NSDate*) awardDate;
+ (void) localNotification;

// 轉換日期年月日時分為字串
+ (NSString*) convertDateToString:(NSDate*)date;
//得到當前發票的期別字串(YYYMM)
+ (NSString*) getPeriodStrNow;

// 根據期數寫入資料庫
+ (void) insertAwardWithInvoYm:(NSString*)invoYm delegate:(id<InsertAwardDelegate>)delegate;

// 最近一期兌獎期別
+ (NSString*) awardInvoYm;
// 前一期兌獎期別
+ (NSString*) nextAwardInvoYm:(NSString*)invoYm;
// 後一期兌獎期別
+ (NSString*) provAwardInvoYm:(NSString*)invoYm;
// 將該期轉換成顯示月份
+ (NSString*) convertDisplayStringFromInvoYm:(NSString*)invoYm;
// 將該期轉換成顯示年月份
+ (NSString*) convertDisplayString2FromInvoYm:(NSString*)invoYm;
// 將該期年份取出
+ (int) invoYmYear:(NSString*)invoYm;
// 將該期月份取出
+ (int) invoYmMonth:(NSString*)invoYm;

@end
