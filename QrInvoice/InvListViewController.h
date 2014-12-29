//
//  InvListViewController.h
//  QrInvoice
//
//  Created by Yen on 2014/7/1.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"
#import "ReceiptCell.h"
#import "invData.h"
#import "DetailViewController.h"

@interface InvListViewController : UIViewController
@property (weak, nonatomic) IBOutlet UINavigationBar *periodNavi;
@property (weak, nonatomic) IBOutlet UISearchBar *invSearchBar;


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@property (strong, nonatomic) NSMutableArray *dataArray;
@end
