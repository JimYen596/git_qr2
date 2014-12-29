//
//  AppDelegate.m
//  QrInvoice
//
//  Created by ChaLin LEE on 2014/7/1.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import "AppDelegate.h"
#import "MMDrawerController.h"
#import "HomeViewController.h"
#import "LeftMenuViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "FMDatabase.h"
#import "UserInfoSingleton.h"
#import "ACUtility.h"
#import "Reachability.h"

@interface AppDelegate ()
{
    Reachability *reachability;
}
@property (nonatomic,strong) MMDrawerController * drawerController;


@end

@implementation AppDelegate

-(BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    //偵測網路狀態
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    [self updateInterfaceWithReachability:reachability];
    
    UIViewController * leftSideDrawerViewController = [[LeftMenuViewController alloc] init];
    
    UIViewController * centerViewController = [[HomeViewController alloc] init];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:centerViewController];
    
    self.drawerController = [[MMDrawerController alloc]
                             initWithCenterViewController:navigationController
                             leftDrawerViewController:leftSideDrawerViewController
                             rightDrawerViewController:nil];
//    [self.drawerController setShowsShadow:YES];
    
    [self.drawerController setMaximumLeftDrawerWidth:100.0];
    [self.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [self.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    self.drawerController.shouldStretchDrawer = NO;
    
    [self.window setRootViewController:self.drawerController];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UserInfoSingleton *userInfo=[UserInfoSingleton getInstance];
    [userInfo saveUserInfo];
    
    debugLog(@"DB_PATH = %@", DB_PATH);
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:DB_PATH] == NO) {
        FMDatabase * db = [FMDatabase databaseWithPath:DB_PATH];
        if ([db open]) {
            NSString * receipt = @"CREATE TABLE 'Receipt' ('invID' VARCHAR(15) PRIMARY KEY NOT NULL UNIQUE,'invNum' VARCHAR(10),'randomNumber' VARCHAR(4),'invDate' VARCHAR(8),'invPeriod' VARCHAR(5),'invSpent' INTEGER,'invType' INTEGER,'gotData' INTEGER,'invLottery' INTEGER,'reward' VARCHAR(10))";
            NSString * details =@"CREATE TABLE 'Details' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL ,'invID' VARCHAR(15),'invNum' VARCHAR(10),'description' VARCHAR(30),'quantity' VARCHAR(4),'unitPrice' VARCHAR(8),'amount' VARCHAR(10),'productType' INTEGER)";
            NSString * award = @"CREATE TABLE 'Award' ('award_id' INTEGER PRIMARY KEY AUTOINCREMENT, 'invoYm' TEXT UNIQUE, 'superPrizeNo' TEXT, 'spcPrizeNo' TEXT, 'firstPrizeNo' TEXT, 'sixthPrizeNo' TEXT, 'superPrizeAmt' TEXT, 'spcPrizeAmt' TEXT, 'firstPrizeAmt' TEXT, 'secondPrizeAmt' TEXT, 'thirdPrizeAmt' TEXT, 'fourthPrizeAmt' TEXT, 'fifthPrizeAmt' TEXT, 'sixthPrizeAmt' TEXT)";
            NSString * account = @"CREATE TABLE 'Account' ('account_id' INTEGER PRIMARY KEY, 'name' TEXT UNIQUE, 'audio' BOOLEAN, 'shock' BOOLEAN, 'notice' BOOLEAN,'userTutorial' BOOLEAN DEFAULT '1', 'budget' INTEGER)";
            BOOL receiptResult = [db executeUpdate:receipt];
            BOOL detailsResult = [db executeUpdate:details];
            BOOL awardResult = [db executeUpdate:award];
            BOOL accountResult = [db executeUpdate:account];
            if (receiptResult || detailsResult || awardResult || accountResult) {
                debugLog(@"succ to creating db table");
                
                NSString *sql = @"INSERT INTO Account (account_id, name, audio, shock, notice, budget) VALUES (1, 'self', 1, 1, 1, 10000)";
                BOOL b = [db executeUpdate:sql];
                if (b) {
                    debugLog(@"insert Account success");
                }
                
#if TEST_DB_AWARD_LIST == 1
                for (int i=0 ; i<1000 ; i++) {
                    NSString *sql = @"INSERT INTO Receipt (invID, invNum, randomNumber, invDate, invPeriod, invSpent, invType, gotData, invLottery, reward) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                    [db executeUpdate:sql withArgumentsInArray:@[[NSString stringWithFormat:@"%d", i],
                                                                 @"AA52585255",
                                                                 @"",
                                                                 @"20140413",
                                                                 @"10304",
                                                                 [NSNumber numberWithLong:222],
                                                                 [NSNumber numberWithLong:0],
                                                                 [NSNumber numberWithLong:0],
                                                                 [NSNumber numberWithLong:0],
                                                                 @"0"]];
                }
#endif
            } else {
                debugLog(@"error when creating db table");
            }
            [db close];
        } else {
            debugLog(@"error when open db");
        }
    }

    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
//    CGRect fullScreenBounds = [[UIScreen mainScreen] bounds];
//    NSLog(@"高==%f,寬==%f",fullScreenBounds.size.height,fullScreenBounds.size.width);
//    //手机别名： 用户定义的名称
//    NSString* userPhoneName = [[UIDevice currentDevice] name];
//    NSLog(@"手机别名: %@", userPhoneName);
//    //设备名称
//    NSString* deviceName = [[UIDevice currentDevice] systemName];
//    NSLog(@"设备名称: %@",deviceName );
//    //手机系统版本
//    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
//    NSLog(@"手机系统版本: %@", phoneVersion);
//    //手机型号
//    NSString* phoneModel = [[UIDevice currentDevice] model];
//    NSLog(@"手机型号: %@",phoneModel );
//    //地方型号  （国际化区域名称）
//    NSString* localPhoneModel = [[UIDevice currentDevice] localizedModel];
//    NSLog(@"国际化区域名称: %@",localPhoneModel );
//    
//    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//    // 当前应用名称
//    NSString *appCurName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
//    NSLog(@"当前应用名称：%@",appCurName);
//    // 当前应用软件版本  比如：1.0.1
//    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
//    NSLog(@"当前应用软件版本:%@",appCurVersion);
//    // 当前应用版本号码   int类型
//    NSString *appCurVersionNum = [infoDictionary objectForKey:@"CFBundleVersion"];
//    NSLog(@"当前应用版本号码：%@",appCurVersionNum);
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [ACUtility localNotification];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    [self updateInterfaceWithReachability: curReach];
}

- (void)updateInterfaceWithReachability:(Reachability *)curReach
{
    NetworkStatus curStatus;
    
    BOOL m_bReachableViaWWAN;
    BOOL m_bReachableViaWifi;
    BOOL m_bReachable;
    
    curStatus = [curReach currentReachabilityStatus];

    if (curStatus == ReachableViaWWAN) {
        m_bReachableViaWWAN = true;
    } else {
        m_bReachableViaWWAN = false;
    }
    
    if (curStatus == ReachableViaWiFi) {
        m_bReachableViaWifi = true;
    } else {
        m_bReachableViaWifi = false;
    }
    
    m_bReachable = (m_bReachableViaWifi || m_bReachableViaWWAN);
    
    if (!m_bReachable) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"無法連接網路" message:@"請檢查網路連線" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [av show];
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    debugLog(@"handleOpenURL");
    
//    [viewController handleURL:url];
    
    return YES;
}

@end
