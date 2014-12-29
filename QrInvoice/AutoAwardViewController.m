//
//  AutoAwardViewController.m
//  QrInvoice
//
//  Created by ChaLin LEE on 2014/7/8.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import "AutoAwardViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "AwardListViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Account.h"
#import "AccountDao.h"

@interface AutoAwardViewController ()
{
    AVAudioPlayer *musicPlayer;
    Account *account;
}

@end

@implementation AutoAwardViewController

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
    self.title = @"搖搖對獎";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                      NSFontAttributeName:[UIFont fontWithName:@"AmericanTypewriter" size:22.0f]}];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:86.0f/255.0f green:222.0f/255.0f blue:167.0f/255.0f alpha:1.0]];
    [self setLeftBarButton];
    [self setMusicPlayer];
    account = [AccountDao selectSelf];
    // Do any additional setup after loading the view from its nib.
}

- (void) viewDidAppear:(BOOL)animated{
 [super viewDidAppear:animated];
 [self becomeFirstResponder];
}

- (void) viewDidDisappear:(BOOL)animated{
 [self resignFirstResponder];
 [super viewDidDisappear:animated];
 musicPlayer = nil;
}

- (BOOL) canBecomeFirstResponder{
 return YES;
}

- (void) setMusicPlayer
{
if (musicPlayer==nil) {
    NSURL *fileUrl =[[NSBundle mainBundle]URLForResource:@"coin" withExtension:@"mp3"];
    musicPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:fileUrl error:nil];
    musicPlayer.numberOfLoops = 0;
    [musicPlayer prepareToPlay];
}
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
 if (motion == UIEventSubtypeMotionShake) {
     if(account.audio){
         [musicPlayer play];
     }
 }
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event{
 if (motion == UIEventSubtypeMotionShake) {
         [musicPlayer pause];
 }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
 if (motion == UIEventSubtypeMotionShake) {
     if(account.audio){
         [musicPlayer play];
     }
 }
}

- (IBAction)tapInvAward:(id)sender {
    
//    [self.popUpAniView pulsingHalo];
    AwardListViewController *awardListVC = [[AwardListViewController alloc]init];
    [self.mm_drawerController closeDrawerAnimated:NO completion:nil];
    [self.navigationController pushViewController:awardListVC animated:YES];

}

- (void)setLeftBarButton{
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navbar_icon_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(cancelPressed)];
/*    UIBarButtonItem *backBtn =[[UIBarButtonItem alloc]initWithTitle:@"關閉" style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)];*/
    
    self.navigationItem.leftBarButtonItem = backBtn;
}

-(void)cancelPressed{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
