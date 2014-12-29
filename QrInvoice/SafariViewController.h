//
//  SafariViewController.h
//  QrInvoice
//
//  Created by jakey_lee on 14/8/14.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import <UIKit/UIKit.h>


#define INVOICE_AWARD_URL @"http://invoice.etax.nat.gov.tw"

@interface SafariViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)returnAction:(UIButton *)sender;

@end
