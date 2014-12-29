//
//  SettingViewController.h
//  QrInvoice
//
//  Created by jakey_lee on 14/7/18.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@interface SettingViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISwitch *audioSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *shockSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *noticeSwitch;
- (IBAction)aboutPress:(id)sender;
- (IBAction)tutorialPress:(id)sender;


- (IBAction)audioChangeAction:(UISwitch *)sender;
- (IBAction)shockChangeAction:(UISwitch *)sender;
- (IBAction)noticeChangeAction:(UISwitch *)sender;

@end
