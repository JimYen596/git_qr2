//
//  ItemCell.m
//  QrInvoice
//
//  Created by Yen on 2014/7/2.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import "ItemCell.h"

@implementation ItemCell
@synthesize itemName;
- (void)awakeFromNib
{
    itemName.textColor = RGB(44, 93, 205);
    itemName.lineBreakMode = NSLineBreakByWordWrapping;
    //itemName.numberOfLines = 0;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
