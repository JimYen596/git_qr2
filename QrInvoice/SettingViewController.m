//
//  SettingViewController.m
//  QrInvoice
//
//  Created by jakey_lee on 14/7/18.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import "SettingViewController.h"
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "ACUtility.h"
#import "AccountDao.h"
#import "Account.h"
#import "TutorialViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

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
    
    // Do any additional setup after loading the view from its nib.
    self.title = @"設定";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                      NSFontAttributeName:[UIFont fontWithName:@"AmericanTypewriter" size:22.0f]}];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.0f/255.0f green:182.0f/255.0f blue:222.0f/255.0f alpha:1.0]];
    
    [self setupLeftMenuButton];
//    [self setupRightButton];
    
    Account *account = [AccountDao selectSelf];
    if (account) {
        self.audioSwitch.on = account.audio;
        self.shockSwitch.on = account.shock;
        self.noticeSwitch.on = account.notice;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method

- (void)setupLeftMenuButton
{
    MMDrawerBarButtonItem *leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    leftDrawerButton.image = [UIImage imageNamed:@"navbar_icon_menu"];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
}

- (void)setupRightButton
{
    UIBarButtonItem *btnAdd = [[UIBarButtonItem alloc]initWithTitle:@"搖搖對獎" style:UIBarButtonItemStylePlain target:self action:@selector(autoAward)];
    
    [self.navigationItem setRightBarButtonItem:btnAdd animated:YES];
}

#pragma mark - Actions

- (void)leftDrawerButtonPress:(id)sender
{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)autoAward
{
//    AutoAwardViewController *autoAwardVC = [[AutoAwardViewController alloc]initWithNibName:@"AutoAwardViewController" bundle:nil];
//    UINavigationController * ncVC = [[UINavigationController alloc] initWithRootViewController:autoAwardVC];
//    [self presentViewController:ncVC animated:YES completion:NULL];
}

- (IBAction)aboutPress:(id)sender {
    
    NSLog(@"aboutPress");
    UIViewController *vc = [[UIViewController alloc]init];
    CGRect webFrame = CGRectMake(0.0, 0.0, 320.0, [[UIScreen mainScreen]bounds].size.height);
    UIWebView *webView = [[UIWebView alloc] initWithFrame:webFrame];

    [webView setBackgroundColor:[UIColor whiteColor]];
    
    webView.scalesPageToFit = YES;
    
    NSURL *url = [NSURL URLWithString:@"http://cht.wistronits.com"];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [webView loadRequest:requestObj];
    
    [vc.view addSubview:webView];
    
    [self.navigationController pushViewController:vc animated:YES];
    
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://cht.wistronits.com"]];
}

- (IBAction)tutorialPress:(id)sender {
    
    NSLog(@"tutorialPress");
    TutorialViewController *tutoVC = [[TutorialViewController alloc]init];
    [self.mm_drawerController setCenterViewController:tutoVC];
    
}

- (IBAction)audioChangeAction:(UISwitch *)sender
{
    [AccountDao updateAudio:sender.isOn];
}

- (IBAction)shockChangeAction:(UISwitch *)sender
{
    [AccountDao updateShock:sender.isOn];
}

- (IBAction)noticeChangeAction:(UISwitch *)sender
{
    if (sender.isOn) {
//        NSLog(@"on");
        NSDate *date = [ACUtility awardDate];
        NSLog(@"date = %@", date);
        NSString *time = [ACUtility convertDateToString:date];
        NSString *msg = [NSString stringWithFormat:@"下次兌獎時間:\n%@\n將會通知提醒!", time];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"確定" otherButtonTitles:nil];
        [alertView show];
    }
    
    [AccountDao updateNotice:sender.isOn];
}

@end
