//
//  AwardListViewController.h
//  QrInvoice
//
//  Created by ChaLin LEE on 2014/7/4.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopUpAniView.h"

#define ROW_HEIGHT 60

#define LEFT_TAG    1
#define MIDDLE1_TAG 2
#define MIDDLE2_TAG 3
#define RIGHT_TAG   4

#define LEFT_COLUMN_OFFSET 25.0
#define LEFT_COLUMN_WIDTH 160.0

#define MIDDLE1_COLUMN_OFFSET -10.0
#define MIDDLE1_COLUMN_WIDTH 80.0

#define MIDDLE2_COLUMN_OFFSET 85.0
#define MIDDLE2_COLUMN_WIDTH 140.0

#define RIGHT_COLUMN_OFFSET 190.0
#define RIGHT_COLUMN_WIDTH 120.0

#define MAIN_FONT_SIZE 18.0
#define LABEL_HEIGHT 26.0

#define IMAGE_SIDE 30.0

@interface AwardListViewController : UIViewController<PopUpAniViewDelegate,UITableViewDataSource,UITableViewDelegate, InsertAwardDelegate>
{
    NSMutableArray *receiptArray;
    
    int invoYmIndex;
    NSMutableArray *invoYmList;
    BOOL isNotReceiptInfo;
}

@property (weak, nonatomic) IBOutlet UILabel *invoYmLabel;
@property (weak, nonatomic) IBOutlet UIButton *prevButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UINavigationBar *theNavigationBar;
@property (weak, nonatomic) IBOutlet UILabel *totalAwardLabel;

- (IBAction)prevButtonAction:(UIButton *)sender;
- (IBAction)nextButtonAction:(UIButton *)sender;

@end
