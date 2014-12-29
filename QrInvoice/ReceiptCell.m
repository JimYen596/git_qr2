//
//  ReceiptCell.m
//  QrInvoice
//
//  Created by Yen on 2014/7/1.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import "ReceiptCell.h"

@implementation ReceiptCell
@synthesize maskView;
- (void)awakeFromNib
{
    UIImage *check_btn = [UIImage imageNamed:@"btn_check"];
    maskView = [[UIView alloc]initWithFrame:CGRectMake(8, 25, 32, 32)];
    [maskView.layer setCornerRadius:CGRectGetHeight([maskView bounds]) / 2];
    maskView.layer.masksToBounds = YES;
    maskView.layer.borderWidth = 5;
    maskView.layer.borderColor = [[UIColor whiteColor] CGColor];
    maskView.layer.contents = (id)[check_btn CGImage];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)changeSelectedMark:(BOOL)didSelect
{
    if(didSelect == YES){
        [self addSubview:maskView];
    }else{
        [maskView removeFromSuperview];
    }
}
@end
