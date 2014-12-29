//
//  UserInfoSingleton.m
//  WinG_APP
//
//  Created by ChaLin LEE on 2013/12/20.
//  Copyright (c) 2013年 ChaLin LEE. All rights reserved.
//

#import "UserInfoSingleton.h"
#import "SecureUDID.h"


#define USERINFO_FILE_PATH [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"Settings.plist"]

#define DOMAIN_BUNDLE @"com.QrInvoice"

#define SPECIFIC_DID_KEY @"E8D_SPECIFIC_DEVICE_ID_KEY"

@interface UserInfoSingleton (){
	
}

@end

@implementation UserInfoSingleton
static UserInfoSingleton *instance=nil;

+(UserInfoSingleton *)getInstance{
	if (instance==nil) {
		@synchronized(self){
			if (instance==nil) {
				instance=[[UserInfoSingleton alloc] init];
			}
		}
	}
	return instance;
}

-(id)init{
	self=[super init];
	if (self) {
		[self loadUserInfo];
	}
	return self;
}


-(void)loadUserInfo{
    
	NSDictionary *dic=[NSDictionary dictionaryWithContentsOfFile:USERINFO_FILE_PATH];
	if (dic==nil) {
        self.appID = @"";
        self.secureUDID = [SecureUDID UDIDForDomain:DOMAIN_BUNDLE usingKey:SPECIFIC_DID_KEY];
        self.pwd = @"";
        self.budget = 0;
        [self saveUserInfo];
	}else{
        self.appID=[dic objectForKey:@"AppID"];
		self.secureUDID =[dic objectForKey:@"SecureUDID"];
        self.pwd = [dic objectForKey:@"Pwd"];
/*        if ([[dic objectForKey:@"NickName"] isKindOfClass:[NSString class]]) {
			self.nickName = [dic objectForKey:@"NickName"];
		}else{
			self.nickName = @"";
		}*/
        self.budget = [[dic objectForKey:@"Budget"]integerValue];
    }
}

-(void)saveUserInfo{
	@synchronized(self){
		NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
        [dic setObject:self.appID forKey:@"UserID"];
        [dic setObject:self.secureUDID forKey:@"SecureUDID"];
        [dic setObject:self.pwd forKey:@"Pwd"];
		[dic setObject:[NSNumber numberWithInt:self.budget] forKey:@"Budget"];
    }
}

/*
-(BOOL)isNeedRegister{
	//if (self.authCode==nil || self.authCode.length==0) {
    if ((self.userID == nil) ||
        (self.userID.length == 0) ||
        (self.userToken == nil) ||
        (self.userToken.length == 0))
    {
		return YES;
	}
	return NO;
}*/
@end
