//
//  InputInvViewController.h
//  QrInvoice
//
//  Created by Yen on 2014/7/3.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCMaskedTextFieldView.h"

@interface InputInvViewController : UIViewController
@property (strong,nonatomic) OCMaskedTextFieldView *numHead;
@property (strong,nonatomic) OCMaskedTextFieldView *numBody;
@property (strong,nonatomic) OCMaskedTextFieldView *randomNumber;
@property (strong,nonatomic) UITextField *boughtTime;
@property (strong,nonatomic) UITextField *spent;
@end
