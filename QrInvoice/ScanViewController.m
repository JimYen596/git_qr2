//
//  ScanViewController.m
//  QrInvoice
//
//  Created by Yen on 2014/7/4.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "ScanViewController.h"
#import "ZXingObjC.h"
#import "InputInvViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"
#import "QrNetAPIManager.h"
#import "ResultViewController.h"
#import "Account.h"
#import "AccountDao.h"

@interface ScanViewController ()<ZXCaptureDelegate>
{
    invData * invoiceData;
    NSString *sallerID;
    NSTimer *msgTimer;
}
@property (weak, nonatomic) IBOutlet UIView *bottonView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIImageView *scanImage;
@property (strong, nonatomic)UIActivityIndicatorView *ActInd;
@property (retain, nonatomic) ZXCapture *zxcapture;
@property (nonatomic) NSDictionary *invDic;
@end

@implementation ScanViewController
@synthesize scanImage,zxcapture;
@synthesize invDic;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"掃描新增";
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:248.0/255.0f green:205.0/255.0f blue:54.0/255.0f alpha:1.0]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName :[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"AmericanTypewriter" size:22.0f]}];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"手動輸入" style:UIBarButtonItemStyleBordered target:self action:@selector(goInputView)];
    [self setupLeftMenuButton];
    
    
}
- (void)setupLeftMenuButton{
    MMDrawerBarButtonItem *leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    leftDrawerButton.image = [UIImage imageNamed:@"navbar_icon_menu"];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
}
- (void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}
-(void)viewWillAppear:(BOOL)animated
{
    [[scanImage subviews]
     makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.ActInd stopAnimating];
    scanImage.image = [UIImage imageNamed:@"icon_qr_focus"];
    if (!zxcapture) {
        zxcapture = [[ZXCapture alloc] init];
        zxcapture.rotation = 90.0f;
        zxcapture.camera = zxcapture.back;
        zxcapture.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        zxcapture.layer.frame = self.view.bounds;
        CGAffineTransform captureSizeTransform = CGAffineTransformMakeScale(320 / self.view.frame.size.width, 480 / self.view.frame.size.height);
        zxcapture.scanRect = CGRectApplyAffineTransform(scanImage.frame, captureSizeTransform);
        
        [self.view.layer addSublayer:zxcapture.layer];
        [self.view bringSubviewToFront:self.topView];
        [self.view bringSubviewToFront:self.bottonView];
        [self.view bringSubviewToFront:scanImage];
        zxcapture.delegate = self; // this must be last.
        [zxcapture start];
    }else{
        [self.view.layer addSublayer:zxcapture.layer];
        [self.view bringSubviewToFront:self.topView];
        [self.view bringSubviewToFront:self.bottonView];
        [self.view bringSubviewToFront:scanImage];
        [zxcapture start];
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //close camera
    [zxcapture.layer removeFromSuperlayer];
    [zxcapture stop];
    zxcapture = nil;
    [[scanImage subviews]
     makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.ActInd stopAnimating];
    self.ActInd.hidden = YES;
}
-(void) viewDidDisappear:(BOOL)animated
{
        [msgTimer invalidate];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark database

-(void)addReceiptNoExist
{
    FMDatabase *db = [FMDatabase databaseWithPath:DB_PATH];
    if([db open]){
        NSString * sql = [NSString stringWithFormat:@"select * from Receipt where invID = '%@'",invoiceData.invID];
        int gotD = [invDic[@"invStatus"] isEqualToString:@"該筆發票並無開立"]?0:1;
        NSLog(@"sql==%@",sql);
        FMResultSet * rs = [db executeQuery:sql];
        if(![rs hasAnotherRow]){
            NSString *invDateStr = [invoiceData.invDate stringByReplacingOccurrencesOfString:@"/" withString:@""];
            NSString *addInvSql = [NSString stringWithFormat:@"insert into Receipt (invID,invNum,randomNumber,invDate,invPeriod,invSpent,invType,gotData,invLottery,reward) values('%@','%@',%@,%@,%@,%@,%d,%d,%d,%@)",invoiceData.invID,invoiceData.invNum,invoiceData.randomNum,invDateStr,invoiceData.invPeriod,@"0",1,gotD,0,@"0"];
            BOOL res = [db executeUpdate:addInvSql];
            if(res){
                NSLog(@"Success to add new Receipt");
                NSLog(@"sql == %@",addInvSql);
                [self addItems];
            }else{
                NSLog(@"Fail to add new Receipt");
            }
        }
        [db close];
        
    }
}
-(void)addItems
{
    int sum = 0;
    FMDatabase *db = [FMDatabase databaseWithPath:DB_PATH];
    if([db open]){
        NSString * sql = @"insert into Details(invID,invNum, description, quantity, unitPrice, amount, productType) values(?,?,?,?,?,?,?)";
        NSArray *detailsArr = invDic[@"details"];
        for(int i = 0; i < [detailsArr count] ; i++){
            BOOL res = [db executeUpdate:sql,invoiceData.invID,invoiceData.invNum,detailsArr[i][@"description"],detailsArr[i][@"quantity"],detailsArr[i][@"unitPrice"],detailsArr[i][@"amount"],@(7)];
            sum+=[detailsArr[i][@"amount"] intValue];
            NSLog(@"invID=%@,invNum=%@, description=%@, quantity=%@, unitPrice=%@, amount=%@, productType=%d",invoiceData.invID,invoiceData.invNum,detailsArr[i][@"description"],detailsArr[i][@"quantity"],detailsArr[i][@"unitPrice"],detailsArr[i][@"amount"],7);
            if (res) {
                debugLog(@"Success to insert item%d",i);
            } else {
                debugLog(@"error to insert item%d",i);
            }
        }
        NSString *sumStr = [NSString stringWithFormat:@"%d",sum];
        NSString *spentSql = [NSString stringWithFormat:@"update receipt set invspent=%@ where invID = '%@'",sumStr,invoiceData.invID];
        [db executeUpdate:spentSql];        
        [db close];
    }
    
}

#pragma mark - ZXCaptureDelegate Methods
- (void)captureResult:(ZXCapture *)capture result:(ZXResult *)result {
    if (!result) return;
    NSLog(@"result == %@",result.text);
    NSLog(@"length == %lu",(unsigned long)result.text.length);
    //NSLog(@"check == %@",[result.text substringWithRange:NSMakeRange(76, 2)]);
    BOOL check = [result.text rangeOfString:@"==:*"].location != NSNotFound;
    if(result.text.length >= 90  && check){
        [zxcapture stop];
        scanImage.image = [UIImage imageNamed:@"icon_qr_focus_on"];
        Account *ac = [AccountDao selectSelf];
        if(ac.shock){
           AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
        [self analyResult:result.text];
    }
}

-(void)analyResult:(NSString*)resultStr
{
    invoiceData = [[invData alloc]init];
    invoiceData.invNum = [resultStr substringWithRange:NSMakeRange(0, 10)];
    NSString *date = [resultStr substringWithRange:NSMakeRange(10, 7)];
    invoiceData.randomNum = [resultStr substringWithRange:NSMakeRange(17, 4)];
    sallerID = [resultStr substringWithRange:NSMakeRange(45, 8)];
    NSDictionary *dateDic = [self getPeriod:date];
    invoiceData.invPeriod = [dateDic valueForKeyPath:@"period"];
    invoiceData.invDate = [dateDic valueForKeyPath:@"date"];
    invoiceData.invID = [invoiceData.invPeriod stringByAppendingString:invoiceData.invNum];
    [self sendAPI];
    
}
-(void)sendAPI
{
    self.ActInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.ActInd.center = CGPointMake(160, 240);
    self.ActInd.hidesWhenStopped = YES;
    [self.view addSubview:self.ActInd];
    [self.ActInd startAnimating];
    
    msgTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(activeView) userInfo:nil repeats:NO];
    
    [[QrNetAPIManager requestWithFinishBlock:^(NSObject *object) {
        invDic = (NSDictionary*)object;
        NSLog(@"status == %@",invDic[@"invStatus"]);
        [self addReceiptNoExist];
        [self.ActInd stopAnimating];
        [[scanImage subviews]
         makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self presentResultView];
    } failBlock:^(NSString *errStr, int errCode) {
        NSLog(@"errStr: %@", errStr);
    }] fetchQryInvDetailWithInvNum:invoiceData.invNum InvDate:invoiceData.invDate InvTerm:invoiceData.invPeriod Encypt:@"w2EpCZGeuTvQX+C7MI7Nea==" SellerID:sallerID type:QRCode randNum:invoiceData.randomNum];
}
-(void)presentResultView
{
    ResultViewController *reVC = [[ResultViewController alloc]init];
    reVC.gotData = invDic;
    reVC.gotInv = invoiceData;
    UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:reVC];
    [self.navigationController presentViewController:navBar animated:YES completion:nil];
}
- (void)goInputView {
    InputInvViewController *vc = [[InputInvViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)activeView
{
    UILabel *label = [[UILabel alloc]init];
    label.text = @"目前網路不穩定,請檢查網路連線";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    [label setFrame:CGRectMake(0, 0, 260, 20)];
    label.center = CGPointMake(scanImage.bounds.size.width/2, scanImage.bounds.size.height/2 +40);
    label.backgroundColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0];
    label.layer.cornerRadius = 10;
    label.layer.masksToBounds = YES;
    [scanImage addSubview:label];
}
-(NSDictionary*)getPeriod:(NSString*)string
{
    NSRange range1 = NSMakeRange(0,3);
    NSRange range2 = NSMakeRange(3,2);
    int year = [[string substringWithRange:range1]intValue];
    int month = [[string substringWithRange:range2]intValue];
    NSString *dayStr = [string substringFromIndex:5];
    NSString *monthStr = [string substringWithRange:range2];
    if( month%2 == 1 ){
        month += 1;
    }
    NSString *periodStr;
    if([[NSString stringWithFormat:@"%li",(long)month] length] == 1){
        periodStr = [[NSString stringWithFormat:@"%li",(long)year] stringByAppendingString:[NSString stringWithFormat:@"0%li",(long)month]];
    }else{
        periodStr = [[NSString stringWithFormat:@"%li",(long)year] stringByAppendingString:[NSString stringWithFormat:@"%li",(long)month]];
    }
    NSString *dateStr = [NSString stringWithFormat:@"%d/%@/%@",year+1911,monthStr,dayStr];
    NSDictionary *dic = @{@"date":dateStr,@"period":periodStr};
    return dic;
}
@end
