//
//  ResultViewController.h
//  QrInvoice
//
//  Created by Yen on 2014/7/16.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "invData.h"
#import "detailData.h"
#import "FMDatabase.h"

@interface ResultViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *invNumLab;
@property (weak, nonatomic) IBOutlet UILabel *randNumLab;
@property (weak, nonatomic) IBOutlet UILabel *invDateLab;
@property (weak, nonatomic) IBOutlet UILabel *invSpentLab;
@property (nonatomic) NSMutableArray *itemDataArr;
@property (nonatomic) NSDictionary *gotData;
@property (nonatomic) invData * gotInv;
@end
