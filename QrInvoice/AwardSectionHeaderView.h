//
//  AwardSectionHeaderView.h
//  QrInvoice
//
//  Created by ChaLin LEE on 2014/7/9.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AwardSectionHeaderView : UITableViewHeaderFooterView

@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *awardNoLabel;
@property (weak, nonatomic) IBOutlet UILabel *money;

@end
