//
//  SearchView.h
//  QrInvoice
//
//  Created by ChaLin LEE on 2014/7/7.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchView : UIView
@property (weak, nonatomic) IBOutlet UILabel *numberLab;
@property (weak, nonatomic) IBOutlet UILabel *unawardLab;

+(SearchView *)view;
@end
//MeHeadView *meHeadView = [[[NSBundle mainBundle] loadNibNamed:@"MeHeadView" owner:nil options:nil] objectAtIndex:0]