//
//  ItemViewController.h
//  QrInvoice
//
//  Created by Yen on 2014/7/2.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "detailData.h"
#import "FMDatabase.h"
#import "invData.h"

@interface ItemViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *itemName;
@property (weak, nonatomic) IBOutlet UITextField *unitPrice;
@property (weak, nonatomic) IBOutlet UITextField *quantity;
@property (weak, nonatomic) IBOutlet UILabel *amount;
@property (nonatomic) detailData *gotItem;
@property (nonatomic) invData *gotData;
@property (nonatomic) NSString *invNumStr;
@property (nonatomic) int isNew;
@end
