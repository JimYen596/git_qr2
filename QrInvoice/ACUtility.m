//
//  ACUtility.m
//  WinG_APP
//
//  Created by ChaLin LEE on 2014/1/3.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import "ACUtility.h"
#import "UserInfoSingleton.h"
#import "AwardDao.h"
#import "QrNetAPIManager.h"
#import "MBProgressHUD.h"

#define SERVER_URL @"https://www.einvoice.nat.gov.tw/PB2CAPIVAN/invapp/"
#define InvApp_URL @"InvApp"

@implementation ACUtility

+(NSString *)getServerUrlString{
    return SERVER_URL;
}
+(NSString *)getInvAppUrlString{
    return [NSString stringWithFormat:@"%@%@",[self getServerUrlString],InvApp_URL];
}

+(NSString *)getDateNowDateString{
    NSDate* now = [NSDate date];
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
//    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    fmt.dateFormat = @"HH_mm_ss";
    return [fmt stringFromDate:now];
}
+(NSDate *)getDateFromDateString:(NSString *)sourceDateString{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:DATE_DEFAULT_FORMAT];
	return [formatter dateFromString:sourceDateString];
}
+ (NSInteger)getDateToDateDays:(NSDate *)date withSaveDate:(NSDate *)saveDate{
    NSCalendar* chineseClendar = [ [ NSCalendar alloc ] initWithCalendarIdentifier:NSGregorianCalendar ];
    NSUInteger unitFlags =  NSHourCalendarUnit | NSMinuteCalendarUnit |
    NSSecondCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    NSDateComponents *cps = [ chineseClendar components:unitFlags fromDate:date  toDate:saveDate  options:0];
    NSInteger diffDay   = [ cps day ];
    return diffDay;
}

+ (NSString *)intervalSinceNow: (NSString *) theDate
{    
    NSString *timeString=@"";
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy_MM_dd_HH_mm"];
    NSDate *fromdate=[format dateFromString:theDate];
    NSTimeZone *fromzone = [NSTimeZone systemTimeZone];
    NSInteger frominterval = [fromzone secondsFromGMTForDate: fromdate];
    NSDate *fromDate = [fromdate  dateByAddingTimeInterval: frominterval];
    
    //获取当前<u><font color="\"red\"">时</font></u>间
    NSDate *adate = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: adate];
    NSDate *localeDate = [adate  dateByAddingTimeInterval: interval];
    
    double intervalTime = [fromDate timeIntervalSinceReferenceDate] - [localeDate timeIntervalSinceReferenceDate];
   
    long lTime = fabs((long)intervalTime);
//    NSInteger iSeconds =  lTime % 60;
    NSInteger iMinutes = (lTime / 60) % 60;
    NSInteger iHours = fabs(lTime/3600);
    NSInteger iDays = lTime/60/60/24;
//    NSInteger iMonth =lTime/60/60/24/12;
//    NSInteger iYears = lTime/60/60/24/384;
    
    
//    NSLog(@"相差%d年%d月 或者 %d日%d时%d分%d秒", iYears,iMonth,iDays,iHours,iMinutes,iSeconds);
    if (intervalTime > 0) {
        timeString = [NSString stringWithFormat:@"%d%@%d%@%d%@", iDays, NSLocalizedString(@"Day", @"天"), (iHours - iDays * 24 ), NSLocalizedString(@"Hour", @"時"), iMinutes, NSLocalizedString(@"Minute", @"分")];
    }else{
        timeString = NSLocalizedString(@"ZeroTime", @"00天00時00分");
    }
    
/*    if (iHours<1 && iMinutes>0)
    {
        timeString=[NSString stringWithFormat:@"%d分",iMinutes];
        
    }else if (iHours>0&&iDays<1 && iMinutes>0) {
        timeString=[NSString stringWithFormat:@"%d时%d分",iHours,iMinutes];
    }
    else if (iHours>0&&iDays<1) {
        timeString=[NSString stringWithFormat:@"%d时",iHours];
    }else if (iDays>0 && iHours>0)
    {
        timeString=[NSString stringWithFormat:@"%d天%d时",iDays,iHours];
    }
    else if (iDays>0)
    {
        timeString=[NSString stringWithFormat:@"%d天",iDays];
    }*/
    return timeString;
}

+(UIImage *)resizeImage:(UIImage *)image withMaxWidth:(float) maxWidth andMaxHeight:(float)maxHeight{
	//@synchronized(self) {
	float width=image.size.width;
	float height=image.size.height;
	if (width<=maxWidth && height <=maxHeight) {
		return image;
	}
	//CGAffineTransform transform=CGAffineTransformIdentity;
	CGRect bounds=CGRectMake(0, 0, width, height);
	if (width>maxWidth || height>maxHeight) {
		CGFloat ratio=width/height;
		if (width>height) {
			bounds.size.width=maxWidth;
			bounds.size.height=maxWidth/ratio;
		}else {
			bounds.size.width=maxHeight*ratio;
			bounds.size.height=maxHeight;
		}
	}
	UIGraphicsBeginImageContext(bounds.size);
	[image drawInRect:bounds];
	UIImage *imageCopy=UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return imageCopy;
}
+ (NSString *)random4Number
{
    
    //用了大写字母,自己感觉要比小写好点吧，方法比较笨，嘿嘿
/*    NSArray *changeArray = [[NSArray alloc] initWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",
                             @"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",nil];*/
    NSArray *changeArray = [[NSArray alloc] initWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",
                            nil];
    
    
    NSMutableString *getStr = [[NSMutableString alloc] initWithCapacity:5]; //可变字符串，存取得到的随机数
    
    NSMutableString *changeString = [[NSMutableString alloc] initWithCapacity:6]; //可变string，最终想要的验证码
    for(NSInteger i = 0; i < 4; i++) //得到四个随机字符，取四次，可自己设长度
    {
        NSInteger index = arc4random() % ([changeArray count] - 1);  //得到数组中随机数的下标
        getStr = [changeArray objectAtIndex:index];  //得到数组中随机数，赋给getStr
        
        changeString = (NSMutableString *)[changeString stringByAppendingString:getStr];
        //把随机字符加到可变string后面，循环四次后取完
    }
    return changeString;
}

//把API字串轉成dictionary
+(NSDictionary*)jsonToDictionary:(NSObject*)object
{
    debugLog(@"object = %@", object);
    
    NSString *str = [[NSString stringWithFormat:@"%@",object] stringByReplacingOccurrencesOfString:@";" withString:@","];
    str = [str stringByReplacingOccurrencesOfString:@"=" withString:@":"];
    NSArray *lineArray = [str componentsSeparatedByString:@"\n"];
    NSString *regex = @".*[{},()].*";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    NSString *jsonString = nil;
    for(NSString *linStr in lineArray){
        NSArray *arr = [linStr componentsSeparatedByString:@":"];
        if([arr count] > 1){
            NSString *noSpceKeyStr = [arr[0] stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSString *noSpceValueStr = [arr[1] stringByReplacingOccurrencesOfString:@" " withString:@""];
            noSpceValueStr = [noSpceValueStr stringByReplacingOccurrencesOfString:@"," withString:@""];
            noSpceValueStr = [noSpceValueStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            
            if ([predicate evaluateWithObject:noSpceKeyStr] == NO) {
                noSpceKeyStr = [NSString stringWithFormat:@"\"%@\":",noSpceKeyStr];
                jsonString=[jsonString stringByAppendingString:noSpceKeyStr];
                //NSLog(@"%@",noSpceKeyStr);
            }
            if ([predicate evaluateWithObject:noSpceValueStr] == NO) {
                noSpceValueStr = [NSString stringWithFormat:@"\"%@\",",noSpceValueStr];
                noSpceValueStr = [noSpceValueStr stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
                
                jsonString=[jsonString stringByAppendingString:noSpceValueStr];
                //NSLog(@"%@",noSpceValueStr);
            }else{
                jsonString = [jsonString stringByAppendingString:noSpceValueStr];
                //NSLog(@"%@",noSpceValueStr);
            }
        }else{
            NSString *noSpceStr = [arr[0] stringByReplacingOccurrencesOfString:@" " withString:@""];
            if(!jsonString){
                jsonString = [noSpceStr mutableCopy];
                //NSLog(@"%@",jsonString);
                jsonString = [jsonString stringByAppendingString:@"\n"];
                continue;
            }
            jsonString = [jsonString stringByAppendingString:noSpceStr];
            //NSLog(@"%@",noSpceStr);
        }
        jsonString = [jsonString stringByAppendingString:@"\n"];
    }
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"(" withString:@"["];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@")" withString:@"]"];
    //jsonString = [jsonString stringByReplacingOccurrencesOfString:@":(" withString:@":["];
    //jsonString = [jsonString stringByReplacingOccurrencesOfString:@")," withString:@"],"];
    NSLog(@"jsonString==%@",jsonString);
    
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    
    NSDictionary *dic =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    NSLog(@"inner === %@",dic);
    
    return dic;
}

-(NSDictionary*)convertDetailsUTF8ToCH:(NSDictionary*)dic
{
    
    NSArray *detailsArr = dic[@"details"];
    for(int i = 0 ; i < [detailsArr count] ; i++){
        NSString *translateString = [detailsArr[i] objectForKey:@"description"];
        NSString *tempStr3 = [[@"\""stringByAppendingString:translateString] stringByAppendingString:@"\""];
        NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
        NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                                                               mutabilityOption:NSPropertyListImmutable
                                                                         format:NULL
                                                               errorDescription:NULL];
        dic[@"details"][i][@"description"] = returnStr;
    }
    return dic;
}

// 兌獎日期
+ (NSDate*) awardDate
{
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:
                                        (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit) fromDate:today];
    
    if (dateComponents.month % 2 == 0) {
        dateComponents.month++;
    } else if (dateComponents.month % 2 == 1 && dateComponents.day >= 25 && dateComponents.hour >= 18) {
        dateComponents.month += 2;
    }
    
    dateComponents.day = 25;
    dateComponents.hour = 18;
    dateComponents.minute = 0;
    dateComponents.second = 0;
    
    // test
//    dateComponents.year = 2012;
//    dateComponents.month = 5;
    
    NSLog(@"year = %ld", dateComponents.year);
    NSLog(@"month = %ld", dateComponents.month);
    NSLog(@"day = %ld", dateComponents.day);
    NSLog(@"hour = %ld", dateComponents.hour);
    
    return [calendar dateFromComponents:dateComponents];
}

+ (void) localNotification
{
    NSLog(@"local notification");
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [self awardDate]; // [now dateByAddingTimeInterval:10];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.alertBody = @"對發票的時候到了，祝您中獎!";
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

+ (NSString*) convertDateToString:(NSDate*)date
{
    return [ACUtility convertDateToStringWithFormat:@"yyyy年M月dd日HH時" date:date];
}

+ (NSString*) convertDateToStringWithFormat:(NSString*)format date:(NSDate*)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:date];
}

+(NSString*)getPeriodStrNow
{
    NSDate *today = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:today];
    NSInteger thisYear = [components year];
    NSInteger thisMonth = [components month];
    thisYear = thisYear -1911;
    if( thisMonth%2 == 1 ){
        thisMonth += 1;
    }
    NSString *periodStr;
    if([[NSString stringWithFormat:@"%li",(long)thisMonth] length] == 1){
        periodStr = [[NSString stringWithFormat:@"%li",(long)thisYear] stringByAppendingString:[NSString stringWithFormat:@"0%li",(long)thisMonth]];
    }else{
        periodStr = [[NSString stringWithFormat:@"%li",(long)thisYear] stringByAppendingString:[NSString stringWithFormat:@"%li",(long)thisMonth]];
    }
    
    return periodStr;
}

+ (void) insertAwardWithInvoYm:(NSString*)invoYm delegate:(id<InsertAwardDelegate>)delegate
{
    if ([AwardDao isContainInvoYm:invoYm] == NO) {
        [[QrNetAPIManager requestWithFinishBlock:^(NSObject *object) {
            //        debugLog(@"object = %@", object);
            NSDictionary *dict = (NSDictionary*) object;
            debugLog(@"msg = %@", [dict objectForKey:@"msg"]);
           
            if ([[dict objectForKey:@"msg"] isEqualToString:@"無此期別資料"]) {
                
            } else {
                // 千萬特獎號碼
                NSString *superPrizeNo = [self calcWithDictionary:dict name:@"superPrizeNo" isFirstNumber:NO];
                // 特獎號碼
                NSString *spcPrizeNo = [self calcWithDictionary:dict name:@"spcPrizeNo" isFirstNumber:NO];
                // 頭獎號碼
                NSString *firstPrizeNo = [self calcWithDictionary:dict name:@"firstPrizeNo" isFirstNumber:YES];
                // 六獎號碼
                NSString *sixthPrizeNo = [self calcWithDictionary:dict name:@"sixthPrizeNo" isFirstNumber:YES];
                
                // 千萬特獎金額
                NSString *superPrizeAmt = [dict objectForKey:@"superPrizeAmt"];
                // 特獎金額
                NSString *spcPrizeAmt = [dict objectForKey:@"spcPrizeAmt"];
                // 頭獎金額
                NSString *firstPrizeAmt = [dict objectForKey:@"firstPrizeAmt"];
                // 二獎金額
                NSString *secondPrizeAmt = [dict objectForKey:@"secondPrizeAmt"];
                // 三獎金額
                NSString *thirdPrizeAmt = [dict objectForKey:@"thirdPrizeAmt"];
                // 四獎金額
                NSString *fourthPrizeAmt = [dict objectForKey:@"fourthPrizeAmt"];
                // 五獎金額
                NSString *fifthPrizeAmt = [dict objectForKey:@"fifthPrizeAmt"];
                // 六獎金額
                NSString *sixthPrizeAmt = [dict objectForKey:@"sixthPrizeAmt"];
                
                Award *award = [[Award alloc] init];
                award.invoYm = [dict objectForKey:@"invoYm"];
                award.superPrizeNo = superPrizeNo;
                award.spcPrizeNo = spcPrizeNo;
                award.firstPrizeNo = firstPrizeNo;
                award.sixthPrizeNo = sixthPrizeNo;
                award.superPrizeAmt = superPrizeAmt;
                award.spcPrizeAmt = spcPrizeAmt;
                award.firstPrizeAmt = firstPrizeAmt;
                award.secondPrizeAmt = secondPrizeAmt;
                award.thirdPrizeAmt = thirdPrizeAmt;
                award.fourthPrizeAmt = fourthPrizeAmt;
                award.fifthPrizeAmt = fifthPrizeAmt;
                award.sixthPrizeAmt = sixthPrizeAmt;
                [AwardDao insertWithAward:award];
                
                if (delegate) {
                    [delegate receiveSuccess:award invoYm:invoYm];
                }
            }
            
        } failBlock:^(NSString *errStr, int errCode) {
//            debugLog(@"errStr: %@", errStr);
            if (delegate) {
                [delegate receiveError:errStr errCode:errCode];
            }
        }] fetchQryWinningListWithInvTerm:invoYm];
    } else {
        if (delegate) {
            [delegate receiveSuccess:nil invoYm:invoYm];
        }
    }
}

+ (NSString*) calcWithDictionary:(NSDictionary*)dict name:(NSString*)name isFirstNumber:(BOOL)isFirstNumber
{
    NSMutableString *list = [NSMutableString stringWithString:@""];
    
    int count = 1;
    while (YES) {
        NSString *str = nil;
        if (count == 1) {
            if (isFirstNumber) {
                str = [NSString stringWithFormat:@"%@%d", name, count];
            } else {
                str = name;
            }
        } else {
            str = [NSString stringWithFormat:@"%@%d", name, count];
        }
        
        NSString *no = [dict objectForKey:str];
        if ([no length] == 0) {
            break;
        }
        
        [list appendString:[NSString stringWithFormat:@"%@,", no]];
        count++;
    }
    
    NSRange range;
    range.length = 1;
    range.location = [list length] - 1;
    [list deleteCharactersInRange:range];
    
    debugLog(@"list = %@", list);
    return list;
}

+ (NSString*) awardInvoYm
{
    NSDate *nowDate = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit) fromDate:nowDate];
    
    debugLog(@"dateComponents = (%ld, %ld, %ld)", dateComponents.year, dateComponents.month, dateComponents.day);
    
    // 雙月
    if (dateComponents.month % 2 == 0) {
        dateComponents.month -= 2;
    }
    // 單月
    else if (dateComponents.month % 2 == 1) {
        // 25號當天下午6:00或26號以後
        if ((dateComponents.day == 25 && dateComponents.hour >= 18) ||
            dateComponents.day > 25)
        {
            dateComponents.month--;
        }
        // 24號以前
        else {
            dateComponents.month -= 3;
        }
    }
    
    long year = dateComponents.year;
    long month = dateComponents.month;
    
    if (year - 1911 > 0) {
        year -= 1911;
    }
    
    if (month <= 0) {
        month = 12 - month;
        year--;
    }
    
    debugLog(@"dateComponents.year = %ld", year);
    debugLog(@"month = %ld", month);
    
    return [self invoYmWithYear:year month:month];
}

+ (NSString*) nextAwardInvoYm:(NSString*)invoYm
{
    int year = [self invoYmYear:invoYm];
    int month = [self invoYmMonth:invoYm];
    
    return [self invoYmWithYear:year month:month];
}

+ (NSString*) provAwardInvoYm:(NSString*)invoYm
{
    int year = [self invoYmYear:invoYm];
    int month = [self invoYmMonth:invoYm] - 2;
    
    if (month <= 0) {
        month = 12 - month;
        year--;
    }
    
    return [self invoYmWithYear:year month:month];
}

+ (NSString*) invoYmWithYear:(long)year month:(long)month
{
    return [NSString stringWithFormat:@"%ld%02ld", year, month];
}

+ (NSString*) convertDisplayStringFromInvoYm:(NSString*)invoYm
{
    int month = [self invoYmMonth:invoYm];
    return [self convertDisplayStringFromMonth:month];
}

+ (NSString*) convertDisplayStringFromMonth:(long)month
{
    return [NSString stringWithFormat:@"%02ld-%02ld月", month - 1, month];
}

+ (NSString*) convertDisplayString2FromInvoYm:(NSString*)invoYm
{
    int year = [self invoYmYear:invoYm];
    int month = [self invoYmMonth:invoYm];
    
    return [NSString stringWithFormat:@"%d年%02d-%02d月", year, month - 1, month];
}

+ (int) invoYmYear:(NSString*)invoYm
{
    int year = 0;
    if ([invoYm length] == 5) {
        year = [[invoYm substringToIndex:3] intValue];
    } else {
        year = [[invoYm substringToIndex:2] intValue];
    }
    
    if (year - 1911 > 0) {
        year -= 1911;
    }
    
    return year;
}

+ (int) invoYmMonth:(NSString*)invoYm
{
    return [[invoYm substringFromIndex:3] intValue];
}


@end
