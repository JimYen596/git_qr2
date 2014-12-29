//
//  UserInfoSingleton.h
//  WinG_APP
//
//  Created by ChaLin LEE on 2013/12/20.
//  Copyright (c) 2013年 ChaLin LEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfoSingleton : NSObject

@property(nonatomic, strong)NSString *appID;
@property(nonatomic, strong)NSString *secureUDID;
@property(nonatomic, strong)NSString *pwd;
@property(nonatomic)int budget;

+(UserInfoSingleton *)getInstance;
-(void)loadUserInfo;
-(void)saveUserInfo;
//-(BOOL)isNeedRegister;
@end
