//
//  SearchView.m
//  QrInvoice
//
//  Created by ChaLin LEE on 2014/7/7.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import "SearchView.h"

@implementation SearchView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

+(SearchView *)view
{
    return ( SearchView *)[[[NSBundle mainBundle] loadNibNamed:@"SearchView" owner:nil options:nil]objectAtIndex:0];
}

@end
