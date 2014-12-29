//
//  LeftMenuViewController.h
//  QrInvoice
//
//  Created by ChaLin LEE on 2014/7/1.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeftMenuCell.h"
@interface LeftMenuViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView * menuTableView;
@property(nonatomic, strong) NSMutableArray *menuItems;
@property(nonatomic, strong) NSMutableArray *mutableArray;

- (void) setCenterViewController:(UIViewController *)newCenterViewController withCloseAnimation:(BOOL)animated completion:(void(^)(BOOL finished))completion;

@end
