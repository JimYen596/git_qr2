//
//  DetailViewController.h
//  QrInvoice
//
//  Created by Yen on 2014/7/2.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "invData.h"
#import "detailData.h"
#import "FMDatabase.h"
#import "ItemCell.h"
#import "ItemViewController.h"
typedef void(^DateDidChange)(void);
@interface DetailViewController : UIViewController
//@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *numHead;
@property (weak, nonatomic) IBOutlet UITextField *numBody;
@property (weak, nonatomic) IBOutlet UITextField *randNum;
@property (weak, nonatomic) IBOutlet UITextField *boughtTime;
@property (weak, nonatomic) IBOutlet UITextField *spent;
@property (nonatomic) invData *gotData;
@property (nonatomic) NSMutableArray *itemDataArr;
@property (nonatomic) BOOL canEditing;
@property (nonatomic,copy) DateDidChange dateChanged;
@end
