//
//  HomeViewController.m
//  QrInvoice
//
//  Created by ChaLin LEE on 2014/7/1.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import "HomeViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"
#import <QuartzCore/QuartzCore.h>
#import "FMDatabase.h"
#import "HomePieView.h"
#import "MyPieElement.h"
#import "PieLayer.h"
#import "ASProgressPopUpView.h"
#import "ScanViewController.h"
#import "InvListViewController.h"
#import "InvoiceAwardViewController.h"
#import "QrNetAPIManager.h"
#import "AccountDao.h"
#import "Account.h"

@interface HomeViewController ()<ASProgressPopUpViewDataSource>{
    BOOL showPercent;
    int sum;
    int pt_total;
    int invCount;
    int rand;
    FMDatabase *db;
}
@property (weak, nonatomic) IBOutlet HomePieView *pieView;
@property (weak, nonatomic) IBOutlet ASProgressPopUpView *progressView;
//@property (strong,nonatomic) ASProgressPopUpView *progressView;
@property (strong,nonatomic) ASProgressPopUpView *progressPopView;
@property (weak, nonatomic) IBOutlet UIButton *scanBtn;
@property (weak, nonatomic) IBOutlet UIButton *awardBtn;
@property (weak, nonatomic) IBOutlet UIButton *budgtBtn;
@end

@implementation HomeViewController
@synthesize pieView;
@synthesize progressView,progressPopView;
@synthesize priceBG,titleImage,amountLab,progressBG;
@synthesize adView,scanBtn,awardBtn,budgtBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar"] forBarMetrics:UIBarMetricsDefault];
    
    db = [FMDatabase databaseWithPath:DB_PATH];
    
    [self setPieViewFrame];
    //初始化manu
    [self setupLeftMenuButton];
    //初始化圓餅圖
    [self creatPieView];
    //顯示預算金額
    [self displayBudget];
    //初始化ProgressView
    [self setupProgressView];
    
    //判斷是否執行導引畫面
    Account *user = [AccountDao selectSelf];
    if(user.userTutorial){
        self.tutorail = user.userTutorial;
        [self createTutorialView];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [self pickAD];
}
-(void)viewDidDisappear:(BOOL)animated
{
    adView.image = nil;
}
-(void)pickAD
{
    rand = arc4random()%2+1;
    NSString *adImageName = [NSString stringWithFormat:@"ad0%d",rand];
    adView.image = [UIImage imageNamed:adImageName];
    
}
-(void)singleTapping:(UIGestureRecognizer *)recognizer
{
    switch (rand) {
        case 1:{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://cht.wistronits.com"]];
            break;
        }
        case 2:{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/tw/app/xiao-lu-jian-kang-guan-li-ver.-2/id808065900?l=zh&mt=8"]];
            
            break;
        }
        default:
            break;
    }
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method

-(void) setPieViewFrame
{
    CGRect fullScreenBounds = [[UIScreen mainScreen] bounds];
    if((int)fullScreenBounds.size.height == 480){

        [self.percentLab setFrame:CGRectMake(self.percentLab.frame.origin.x, self.percentLab.frame.origin.y-45, self.percentLab.frame.size.width, self.percentLab.frame.size.height)];
        [titleImage setFrame:CGRectMake(titleImage.frame.origin.x, titleImage.frame.origin.y-60, titleImage.frame.size.width, titleImage.frame.size.height)];
        [priceBG setFrame:CGRectMake(priceBG.frame.origin.x, priceBG.frame.origin.y-30, priceBG.frame.size.width, priceBG.frame.size.height)];
        [amountLab setFrame:CGRectMake(amountLab.frame.origin.x, amountLab.frame.origin.y-30, amountLab.frame.size.width, amountLab.frame.size.height)];

        [self.progressView setFrame:CGRectMake(28 , 400, 265 , 8)];
        [progressBG setFrame:CGRectMake(28 , 399, 275 , 12)];

    }
    UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapping:)];
    [singleTap setNumberOfTapsRequired:1];
    [adView addGestureRecognizer:singleTap];
}
- (int) displayInvCount
{
    NSString *periodNow = [ACUtility getPeriodStrNow];
    if([db open]){
        NSString *sql =[ NSString stringWithFormat:@"select count(invID) as inv_count from receipt where invperiod = '%@'",periodNow];
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            invCount = [rs intForColumn:@"inv_count"];
        }
        [db close];
    }
    self.countLab.text = [NSString stringWithFormat:@"%d",invCount];
    return invCount;
}
- (void) displayBudget
{
    Account *account = [AccountDao selectSelf];
    self.budgetLab.text = [NSString stringWithFormat:@"$%lld", account.budget];
}

- (void) creatPieView
{
    int unknown_total = [self sumCostInPeriod] - [self sumCostInPeriodAllItems];
    [db open];
    for(int i = 0 ; i <= 7; i++) {
        
        pt_total = 0;
        UIColor *eleColor ;
        NSString *title;
        NSString *periodNow = [ACUtility getPeriodStrNow];
        NSString *sql = [NSString stringWithFormat:@"select sum(amount) as cost from details where invNum in (select invNum from receipt where invperiod = '%@') and productType = %d ",periodNow,i];
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            pt_total = [rs intForColumn:@"cost"];
        }
        if(i == 7){
            pt_total = pt_total + unknown_total;
        }
        switch (i) {
            case 0:
                eleColor = [UIColor colorWithRed:128.0f/255.0f green:94.0f/255.0f blue:161.0f/255.0f alpha:1.0];
                title = @"其他";
                break;
            case 1:
                eleColor = [UIColor colorWithRed:255.0f/255.0f green:144.0f/255.0f blue:0.0f/255.0f alpha:1.0];
                title = @"食";
                break;
            case 2:
                eleColor = [UIColor colorWithRed:248.0f/255.0f green:205.0f/255.0f blue:54.0f/255.0f alpha:1.0];
                title = @"衣";
                break;
            case 3:
                eleColor = [UIColor colorWithRed:222.0f/255.0f green:104.0f/255.0f blue:41.0f/255.0f alpha:1.0];
                title = @"住";
                break;
            case 4:
                eleColor = [UIColor colorWithRed:242.0f/255.0f green:97.0f/255.0f blue:117.0f/255.0f alpha:1.0];
                title = @"行";
                break;
            case 5:
                eleColor = [UIColor colorWithRed:0.0f/255.0f green:182.0f/255.0f blue:222.0f/255.0f alpha:1.0];
                title = @"育";
                break;
            case 6:
                eleColor = [UIColor colorWithRed:157.0f/255.0f green:204.0f/255.0f blue:9.0f/255.0f alpha:1.0];
                title = @"樂";
                break;
            case 7:
                eleColor = [UIColor colorWithRed:36.0f/255.0f green:187.0f/255.0f blue:126.0f/255.0f alpha:1.0];
                title = @"未分類";
                break;
            default:
                break;
        }
        MyPieElement* elem = [MyPieElement pieElementWithValue:(pt_total>=0)?pt_total:0 color:eleColor];
        sum = sum + pt_total;
        elem.title = title;
        [pieView.layer addValues:@[elem] animated:YES];
    }
    [db close];
    
    pieView.elemTapped = ^(PieElement* elem){
        [PieElement animateChanges:^{
            float percent = (100.0 * elem.val / sum > 100.0) ? 100 : 100.0 * elem.val / sum;
            [_percentLab setText:[NSString stringWithFormat:@"%ld%%",(long)percent]];
            if([[(MyPieElement*)elem title] isEqualToString:@"食"]){
                [priceBG setImage:[UIImage imageNamed:@"index_price_01"]];
            }else if ([[(MyPieElement*)elem title] isEqualToString:@"衣"]){
                [priceBG setImage:[UIImage imageNamed:@"index_price_02"]];
            }else if ([[(MyPieElement*)elem title] isEqualToString:@"住"]){
                [priceBG setImage:[UIImage imageNamed:@"index_price_03"]];
            }else if ([[(MyPieElement*)elem title] isEqualToString:@"行"]){
                [priceBG setImage:[UIImage imageNamed:@"index_price_04"]];
            }else if ([[(MyPieElement*)elem title] isEqualToString:@"育"]){
                [priceBG setImage:[UIImage imageNamed:@"index_price_05"]];
            }else if ([[(MyPieElement*)elem title] isEqualToString:@"樂"]){
                [priceBG setImage:[UIImage imageNamed:@"index_price_06"]];
            }else if ([[(MyPieElement*)elem title] isEqualToString:@"其他"]){
                [priceBG setImage:[UIImage imageNamed:@"index_price_07"]];
            }else{
                [priceBG setImage:[UIImage imageNamed:@"index_price_08"]];
            }
            
            amountLab.hidden = NO;
            [amountLab setText:[NSString stringWithFormat:@"%@:$%ld",[(MyPieElement*)elem title],(long)elem.val]];
        }];
    };
    if(sum == 0){
        CGRect fullScreenBounds = [[UIScreen mainScreen] bounds];
        if((int)fullScreenBounds.size.height == 480){
            UIImageView * chart_Def = [[UIImageView alloc]initWithFrame:CGRectMake(20, 250, 130, 130)];
            chart_Def.image = [UIImage imageNamed:@"chat_defult"];
            [self.view addSubview:chart_Def];
            [self.view bringSubviewToFront:chart_Def];
        }else{
            UIImageView * chart_Def = [[UIImageView alloc]initWithFrame:CGRectMake(18, 260, 180, 180)];
            chart_Def.image = [UIImage imageNamed:@"chat_defult"];
            [self.view addSubview:chart_Def];
            [self.view bringSubviewToFront:chart_Def];
        }
    }
}
-(void)setupProgressView
{
    if([self displayInvCount] == 0){
        CGRect progressRect = self.progressView.frame;
        [self.progressView removeFromSuperview];
        UIImageView *icon_Zero = [[UIImageView alloc]initWithFrame:CGRectMake(progressRect.origin.x-24, progressRect.origin.y-41, 50, 41)];
        icon_Zero.image = [UIImage imageNamed:@"icon_index_account_zero"];
        [self.view addSubview:icon_Zero];
    }
    
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    self.progressView.transform = transform;
    self.progressView.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:12];
    self.progressView.popUpViewAnimatedColors = @[RGB(255.0, 144.0, 0.0),RGB(234.0, 76.0, 136.0), RGB(204.0, 0.0, 0.0)];
    self.progressView.dataSource = self;
    [self.progressView showPopUpViewAnimated:YES];
    [self.view bringSubviewToFront:self.progressView];
    [self progress];
}
- (void)setupLeftMenuButton{
    MMDrawerBarButtonItem *leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    leftDrawerButton.image = [UIImage imageNamed:@"navbar_icon_menu"];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
}

#pragma mark - Button Handlers

-(void)leftDrawerButtonPress:(id)sender{
    if(!self.tutorail){
        [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    }
}

- (UIColor*)randomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

#pragma mark - Timer

- (void)progress
{
    Account *ac = [AccountDao selectSelf];
    float progress = sum/(float)ac.budget;
    [self.progressView setProgress:progress animated:YES];
    [progressPopView setProgress:progress animated:YES];
}

#pragma mark - ASProgressPopUpView dataSource

// <ASProgressPopUpViewDataSource> is entirely optional
// it allows you to supply custom NSStrings to ASProgressPopUpView
- (NSString *)progressView:(ASProgressPopUpView *)progressView stringForProgress:(float)progress
{
    int sumCost = [self sumCostInPeriod];
    if(sumCost == 0){
        return [NSString stringWithFormat:@" $%d   ",sumCost];
    }
    return [NSString stringWithFormat:@" $%d ",sumCost];
}
-(int)sumCostInPeriod
{
    int sumValue;
    [db open];
    //NSString *sql = [NSString stringWithFormat:@"select sum(amount) as total_cost from details where invid in (select invid from receipt where invperiod = '%@')",[ACUtility getPeriodStrNow]];
    NSString *sql = [NSString stringWithFormat:@"select sum(invspent) as total_cost from receipt where invperiod = '%@'",[ACUtility getPeriodStrNow]];
    FMResultSet *rs = [db executeQuery:sql];
    while ([rs next]) {
        sumValue = [rs intForColumn:@"total_cost"];
    }
    [db close];
    return sumValue;
}
-(int)sumCostInPeriodAllItems
{
    int sumValue;
    [db open];
    NSString *sql = [NSString stringWithFormat:@"select sum(amount) as total_cost from details where invid in (select invid from receipt where invperiod = '%@')",[ACUtility getPeriodStrNow]];
    FMResultSet *rs = [db executeQuery:sql];
    while ([rs next]) {
        sumValue = [rs intForColumn:@"total_cost"];
    }
    [db close];
    return sumValue;
}

// by default ASProgressPopUpView precalculates the largest popUpView size needed
// it then uses this size for all values and maintains a consistent size
// if you want the popUpView size to adapt as values change then return 'NO'
- (BOOL)progressViewShouldPreCalculatePopUpViewSize:(ASProgressPopUpView *)progressView;
{
    return NO;
}

- (IBAction)goScanView:(id)sender {
    
    ScanViewController *scanVC = [[ScanViewController alloc]init];
    UINavigationController *ncVC = [[UINavigationController alloc]initWithRootViewController:scanVC ];
    [self.mm_drawerController setCenterViewController:ncVC];
    
}

- (IBAction)setBudget:(id)sender {
    [self searchInvs];
}
- (IBAction)goAward:(id)sender {
     InvoiceAwardViewController *scanVC = [[InvoiceAwardViewController alloc]init];
    UINavigationController *ncVC = [[UINavigationController alloc]initWithRootViewController:scanVC ];
    [self.mm_drawerController setCenterViewController:ncVC];
}

-(void)searchInvs
{
    NSString * str1 = @"請輸入本期預算金額";
    NSString * str2 = @"(預算控制條 = 本期消費/本期預算)";
    NSString * msg = [NSString stringWithFormat:@"%@\n%@",str1,str2];
    UIAlertView *alertVew = [[UIAlertView alloc]initWithTitle:@"設定預算" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"確定", nil];
    alertVew.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alertVew textFieldAtIndex:0];
    textField.keyboardType = UIKeyboardTypeNumberPad;
    
//    UITextField *textfield = [alertVew textFieldAtIndex:0];
//    searchWord = textfield.text;
    [alertVew show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: {
            break;
        }
            
        case 1: {
            //            searchInv = YES;
            //            self.navigationItem.title = [NSString stringWithFormat:@"發票清單(%@)",searchWord];
            
            
            UITextField *textField = [alertView textFieldAtIndex:0];
            debugLog(@"textField = %@", textField.text);
            [AccountDao updateBudget:[textField.text longLongValue]];
            [self displayBudget];
            [self progress];
            break;
        }
            
        default:
            break;
    }
}

-(void)createTutorialView
{
    self.maskView = [[UIView alloc]initWithFrame:self.view.bounds];
    self.maskView.layer.backgroundColor = [UIColor colorWithRed:1/255.0f green:1/255.0f blue:1/255.0f alpha:0.7].CGColor;
    CGSize maskSize = self.maskView.frame.size;
    self.imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,0,0)];
    self.imgView.image = [UIImage imageNamed:@"intr_01"];
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         [self.imgView setFrame:CGRectMake(maskSize.width/2-145,([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)?maskSize.height/2-203 :maskSize.height/2-135, 290, 270)];
                     }
                     completion:^(BOOL finished){
                         NSLog(@"Done!");
                     }];
    [self.maskView addSubview:self.imgView];
    [self.view addSubview:self.maskView];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.tutorail){
        [self performSelector:@selector(changeTutorialImage) withObject:nil];
    }
}
-(void)changeTutorialImage
{
    static int inx = 0;
    NSArray *imgArr = @[@"intr_02",@"intr_03",@"intr_04"];
    if(inx == imgArr.count){
        self.tutorail = NO;
        [self.maskView removeFromSuperview];
        self.maskView = nil;
        self.imgView = nil;
        [AccountDao updateUserTutorial:NO];
        return;
    }
    self.imgView.image =[UIImage imageNamed:imgArr[inx++]];    
}
@end
