//
//  InvoiceAwardViewController.h
//  QrInvoice
//
//  Created by ChaLin LEE on 2014/7/3.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@interface InvoiceAwardViewController : UIViewController<UISearchBarDelegate, InsertAwardDelegate, TTTAttributedLabelDelegate, UIAlertViewDelegate>
{
    NSString *invoYm1;
    NSString *invoYm2;
    
    NSString *tackMoneyZone1;
    NSString *tackMoneyZone2;
    
    NSArray *noLabelList;
}

@property (weak, nonatomic) IBOutlet UILabel *superPrizeNoLab;
@property (weak, nonatomic) IBOutlet UILabel *spcPrizeNoLab;

@property (weak, nonatomic) IBOutlet UILabel *firstPrizeNo1Lab;
@property (weak, nonatomic) IBOutlet UILabel *firstPrizeNo2Lab;
@property (weak, nonatomic) IBOutlet UILabel *firstPrizeNo3Lab;

@property (weak, nonatomic) IBOutlet UILabel *sixthPrizeNo1Lab;
@property (weak, nonatomic) IBOutlet UILabel *sixthPrizeNo2Lab;

@property (weak, nonatomic) IBOutlet UISegmentedControl *monthSegmentedControl;

@property (weak, nonatomic) IBOutlet UILabel *tackMoneyZoneLabel;

//- (IBAction)tapInvAward:(id)sender;

@end
