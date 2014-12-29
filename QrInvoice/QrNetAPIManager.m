//
//  QrNetAPIManager.m
//  QrInvoice
//
//  Created by ChaLin LEE on 2014/7/15.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import "QrNetAPIManager.h"
#import "AFNetworking.h"
//#import "ACUtility.h"
//#import "UserInfoSingleton.h"

#define INVAPP_SERVICE_URL_STRING [ACUtility getInvAppUrlString]

#define APPID @"EINV2201406188413"
#define VERSION @"0.2"
#define GENERATION @"V2"

@implementation QrNetAPIManager

- (id)initWithFinishBlock:(void (^)(NSObject *))finishBlockToRun failBlock:(void (^)(NSString *, int))failBlockToRun
{
    self = [super init];
    if (self) {
        self.finishBlock = finishBlockToRun;
        self.failBlock = failBlockToRun;
    }
    return self;
}

+ (QrNetAPIManager *)requestWithFinishBlock:(void (^)(NSObject *objcet))finishBlockToRun failBlock:(void (^)(NSString *errStr, int errCode))failBlockToRun
{
    return [[QrNetAPIManager alloc] initWithFinishBlock:finishBlockToRun failBlock:failBlockToRun];
}

+ (QrNetAPIManager *)sharedManager
{
    static QrNetAPIManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[QrNetAPIManager alloc] init];
    });
    return sharedManager;
}

-(void)fetchQryWinningListWithInvTerm:(NSString *)invterm
{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.securityPolicy setAllowInvalidCertificates:YES];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSDictionary *params = @{@"appID":APPID,
                             @"action":@"QryWinningList",
                             @"invTerm":invterm,
                             @"UUID":@"",
                             @"version":VERSION
                             };
    
    NSLog(@"======%@",params);

    [manager POST:INVAPP_SERVICE_URL_STRING
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
//              NSString *className = NSStringFromClass([responseObject class]);
//              NSLog(@"className = %@", className);
              
              NSLog(@"JSON: %@", responseObject);
              // 塞到finishBlock傳給使用的class
              self.finishBlock(responseObject);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              // 塞到failBlock傳給使用的class
              self.failBlock(error.description, error.code);
          }];
}

-(void)fetchQryInvHeaderWithInvNum:(NSString *)invNum InvDate:(NSString *)invDate type:(CodeType)type
{

    UserInfoSingleton *userInfo=[UserInfoSingleton getInstance];
    NSString *CodeStr = nil;
    if (type == QRCode) {
        CodeStr = @"QRCode";
    }else{
        CodeStr = @"Barcode";
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.securityPolicy setAllowInvalidCertificates:YES];
    //    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSDictionary *params = @{@"appID":APPID,
                             @"type":CodeStr,
                             @"invNum":invNum,
                             @"generation":GENERATION,
                             @"invDate":invDate,
                             @"action":@"qryInvHeader",
                             @"UUID":userInfo.secureUDID,
                             @"version":VERSION
                             };
    
    NSLog(@"======%@",params);
    
    [manager POST:INVAPP_SERVICE_URL_STRING
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              // 塞到finishBlock傳給使用的class
              self.finishBlock(responseObject);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              // 塞到failBlock傳給使用的class
              self.failBlock(error.description, error.code);
          }];
}

-(void)fetchQryInvDetailWithInvNum:(NSString *)invNum InvDate:(NSString *)invDate InvTerm:(NSString *)invTerm Encypt:(NSString*)encrypt SellerID:(NSString *)sellerID type:(CodeType)type randNum:(NSString *)randNum
{
    if (invTerm == nil) {
        invTerm = @"";
    }
    UserInfoSingleton *userInfo=[UserInfoSingleton getInstance];
    NSString *CodeStr = nil;
    if (type == QRCode) {
        CodeStr = @"QRCode";
    }else{
        CodeStr = @"Barcode";
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.securityPolicy setAllowInvalidCertificates:YES];
    //    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSDictionary *params = @{@"appID":APPID,
                             @"type":CodeStr,
                             @"invNum":invNum,
                             @"generation":GENERATION,
                             @"invTerm":invTerm,
                             @"invDate":invDate,
                             @"encrypt":encrypt,
                             @"sellerID":sellerID,
                             @"action":@"qryInvDetail",
                             @"UUID":userInfo.secureUDID,
                             @"randomNumber":randNum,
                             @"version":VERSION
                             };
    
    //NSLog(@"======%@",params);
    
    [manager POST:INVAPP_SERVICE_URL_STRING
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              // 塞到finishBlock傳給使用的class
              self.finishBlock(responseObject);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              // 塞到failBlock傳給使用的class
              self.failBlock(error.description, error.code);
          }];
}

@end
