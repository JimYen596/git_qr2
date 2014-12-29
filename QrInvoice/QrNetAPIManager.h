//
//  QrNetAPIManager.h
//  QrInvoice
//
//  Created by ChaLin LEE on 2014/7/15.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QrNetAPIManager : NSObject
@property (nonatomic, copy) void (^finishBlock) (NSObject *);
@property (nonatomic, copy) void (^failBlock) (NSString *, int);

- (id)initWithFinishBlock:(void (^)(NSObject *))finishBlockToRun failBlock:(void (^)(NSString *, int))failBlockToRun;

+ (QrNetAPIManager *)requestWithFinishBlock:(void (^)(NSObject *objcet))finishBlockToRun failBlock:(void (^)(NSString *errStr, int errCode))failBlockToRun;

+ (QrNetAPIManager *)sharedManager;

//查詢中獎發票號碼清單
-(void)fetchQryWinningListWithInvTerm:(NSString *)invterm;


//查詢發票表頭
-(void)fetchQryInvHeaderWithInvNum:(NSString *)invNum InvDate:(NSString *)invDate type:(CodeType)type;


//查詢發票明細,type = QRCode : encrypt,sellerID必填 ; type = Barcode : invTerm必填
-(void)fetchQryInvDetailWithInvNum:(NSString *)invNum InvDate:(NSString *)invDate InvTerm:(NSString *)invTerm Encypt:(NSString*)encrypt SellerID:(NSString *)sellerID type:(CodeType)type randNum:(NSString *)randNum;
@end
