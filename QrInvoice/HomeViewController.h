//
//  HomeViewController.h
//  QrInvoice
//
//  Created by ChaLin LEE on 2014/7/1.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *budgetLab;
@property (weak, nonatomic) IBOutlet UILabel *amountLab;
@property (weak, nonatomic) IBOutlet UILabel *percentLab;
@property (weak, nonatomic) IBOutlet UILabel *countLab;
@property (weak, nonatomic) IBOutlet UIImageView *priceBG;
@property (weak, nonatomic) IBOutlet UIImageView *titleImage;
@property (weak, nonatomic) IBOutlet UIImageView *progressBG;
@property (weak, nonatomic) IBOutlet UIImageView *adView;
@property (nonatomic) BOOL tutorail;
@property (nonatomic) UIView *maskView;
@property (nonatomic) UIImageView *imgView;
- (IBAction)setBudget:(id)sender;


@end
