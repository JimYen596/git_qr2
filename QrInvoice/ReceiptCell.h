//
//  ReceiptCell.h
//  QrInvoice
//
//  Created by Yen on 2014/7/1.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReceiptCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *periodLab;
@property (weak, nonatomic) IBOutlet UILabel *numberLab;
@property (weak, nonatomic) IBOutlet UILabel *typeLab;
@property (weak, nonatomic) IBOutlet UILabel *costLab;
@property (strong,nonatomic) UIView* maskView;
-(void)changeSelectedMark:(BOOL)didSelect;
@end
