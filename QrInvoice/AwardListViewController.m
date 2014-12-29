//
//  AwardListViewController.m
//  QrInvoice
//
//  Created by ChaLin LEE on 2014/7/4.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import "AwardListViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "AwardSectionHeaderView.h"
#import "ReceiptDao.h"
#import "Receipt.h"
#import "AwardDao.h"
#import "Award.h"
#import "UIColor+Hex.h"
#import "MBProgressHUD.h"
#import "CheckNetwork.h"

static NSString *SectionHeaderViewIdentifier = @"SectionHeaderViewIdentifier";
@interface AwardListViewController (){
    BOOL award_Off;
}
@property (nonatomic, strong) PopUpAniView *popUpAniView;
@property (nonatomic, strong) UITableView * awardListTableView;
@end

@implementation AwardListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
            self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([CheckNetwork check] == NO) {
        debugLog(@"沒有網路");
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"請連結網路後再使用搖搖對獎功能" delegate:self cancelButtonTitle:@"確定" otherButtonTitles:nil];
        [alertView show];
    }
    
    self.title = @"中獎清單";
    [self setLeftBarButton];
    [self setRightBarButton];
    
    _awardListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width , self.view.bounds.size.height - 44)];
    _awardListTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _awardListTableView.backgroundColor = [UIColor clearColor];
//    _awardListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _awardListTableView.delegate = self;
    _awardListTableView.dataSource = self;
    [self.view addSubview:_awardListTableView];
    UINib *sectionHeaderNib = [UINib nibWithNibName:@"AwardSectionHeaderView" bundle:nil];
    [self.awardListTableView registerNib:sectionHeaderNib forHeaderFooterViewReuseIdentifier:SectionHeaderViewIdentifier];
    
    self.theNavigationBar.barTintColor = [UIColor colorWithHexRed:86 green:222 blue:167 alpha:1];
    
    [self creatAniView];
    
    receiptArray = [NSMutableArray array];
    invoYmIndex = 0;
    invoYmList = [NSMutableArray arrayWithArray:[ReceiptDao selectInvPeriodList]];
    if ([invoYmList count] > 0) {
        NSString *currentInvoYm = [invoYmList objectAtIndex:invoYmIndex];
        NSString *awardInvoYm = [ACUtility awardInvoYm];
        
        if ([ACUtility invoYmYear:currentInvoYm] == [ACUtility invoYmYear:awardInvoYm] &&
            [ACUtility invoYmMonth:currentInvoYm] > [ACUtility invoYmMonth:awardInvoYm])
        {
            [invoYmList removeObject:currentInvoYm];
            
            if ([invoYmList count] > 0) {
                currentInvoYm = [invoYmList objectAtIndex:invoYmIndex];
            } else {
                currentInvoYm = awardInvoYm;
            }
        }
        
//        currentInvoYm = [ACUtility awardInvoYm];
        self.invoYmLabel.text = [ACUtility convertDisplayString2FromInvoYm:currentInvoYm];
        [self awardInvWithReceiptArray:currentInvoYm];
        
        if (invoYmIndex - 1 < 0) {
            self.prevButton.enabled = NO;
        }
        
        if (invoYmIndex + 1 >= [invoYmList count]) {
            self.nextButton.enabled = NO;
        }
    } else {
        self.prevButton.enabled = NO;
        self.nextButton.enabled = NO;
        NSString *currentInvoYm = [ACUtility awardInvoYm];
        self.invoYmLabel.text = [ACUtility convertDisplayString2FromInvoYm:currentInvoYm];
    }
    
}

#pragma mark - Private Method

- (NSArray*) awardInvUpdateData:(NSString*)invoYm
{
    Award *award = [AwardDao selectAwardWithInvoYm:invoYm];
    NSArray *receiptList = [ReceiptDao selectReceiptNotLotteryWithInvoYm:invoYm];
    NSMutableArray *myReceiptArray = [NSMutableArray array];
    isNotReceiptInfo = NO;
    
    for (Receipt *receipt in receiptList) {
        if (award) {
            const NSString *invNum = [receipt.invNum substringFromIndex:2];
            receipt.invLottery = 1;
            
            // 特別獎
            if ([invNum isEqual:award.superPrizeNo])
            {
                receipt.invLottery = 2;
                receipt.reward = award.superPrizeAmt;
                [myReceiptArray addObject:receipt];
            }
            
            // 特獎
            if ([invNum isEqual:award.spcPrizeNo]) {
                receipt.invLottery = 2;
                receipt.reward = award.spcPrizeAmt;
                [myReceiptArray addObject:receipt];
            }
            
            // 頭獎
            NSArray *firstPrizeNoList = [award.firstPrizeNo componentsSeparatedByString:@","];
            for (NSString *firstPrizeNo in firstPrizeNoList) {
                for (NSUInteger i=[firstPrizeNo length] ; i>=3 ; i--) {
                    NSRange range;
                    range.length = i;
                    range.location = [firstPrizeNo length] - i;
                    NSString *number = [firstPrizeNo substringWithRange:range];
                    
                    if ([invNum hasSuffix:number]) {
                        receipt.invLottery = 2;
                        
                        switch (i) {
                            case 8:
                                receipt.reward = award.firstPrizeAmt;
                                break;
                                
                            case 7:
                                receipt.reward = award.secondPrizeAmt;
                                break;
                                
                            case 6:
                                receipt.reward = award.thirdPrizeAmt;
                                break;
                                
                            case 5:
                                receipt.reward = award.fourthPrizeAmt;
                                break;
                                
                            case 4:
                                receipt.reward = award.fifthPrizeAmt;
                                break;
                                
                            case 3:
                                receipt.reward = award.sixthPrizeAmt;
                                break;
                                
                            default:
                                break;
                        }
                        
                        [myReceiptArray addObject:receipt];
                        // end for
                        break;
                    }
                }
            }
            
            // 六獎
            NSArray *sixthPrizeNoList = [award.sixthPrizeNo componentsSeparatedByString:@","];
            for (NSString *sixthPrizeNo in sixthPrizeNoList) {
                if ([invNum hasSuffix:sixthPrizeNo]) {
                    receipt.invLottery = 2;
                    receipt.reward = award.sixthPrizeAmt;
                    [myReceiptArray addObject:receipt];
                }
            }
            
            [ReceiptDao updateInvLotteryAndRewardWithReceipt:receipt];
        } else {
            debugLog(@"沒有此期別可以兌獎");
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"沒有提供此期別兌獎資訊" delegate:nil cancelButtonTitle:@"確定" otherButtonTitles:nil];
//            [alertView show];
            isNotReceiptInfo = YES;
            
            Receipt *receipt = [[Receipt alloc] init];
            receipt.invNum = @"沒有提供此期別兌獎資訊";
            [myReceiptArray addObject:receipt];
            
            return myReceiptArray;
        }
    }
    
    return [ReceiptDao selectReceiptLotteryWithInvoYm:invoYm];
}

// 對發票
- (void) awardInvWithReceiptArray:(NSString*)invoYm
{
    [ACUtility insertAwardWithInvoYm:invoYm delegate:self];
    
    [receiptArray removeAllObjects];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        receiptArray = [NSMutableArray arrayWithArray:[self awardInvUpdateData:invoYm]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            [self.awardListTableView reloadData];
            long long total = 0;
            
            for (Receipt *receipt in receiptArray) {
                NSString *reward = receipt.reward;
                long long num = [reward longLongValue];
                debugLog(@"num = %lld", num);
                total += num;
            }
            
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
            NSString *strTotal = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:total]];
            self.totalAwardLabel.text = [NSString stringWithFormat:@"$%@", strTotal];
        });
    });
}

- (UITableViewCell *)tableViewCellWithReuseIdentifier:(NSString *)identifier
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    
    UILabel *label;
	CGRect rect;
    UIFont *font = [UIFont fontWithName:@"Arial-BoldMT" size:20];
    
    // Create a label.
    rect = CGRectMake(LEFT_COLUMN_OFFSET, (ROW_HEIGHT - LABEL_HEIGHT) / 2.0, LEFT_COLUMN_WIDTH, LABEL_HEIGHT);
    label = [[UILabel alloc] initWithFrame:rect];
    label.tag = LEFT_TAG;
    label.font = [UIFont boldSystemFontOfSize:MAIN_FONT_SIZE];
    label.adjustsFontSizeToFitWidth = YES;
    label.textColor = [UIColor blackColor];
    label.font = font;
    [cell.contentView addSubview:label];
    
    // Create a label.
    rect = CGRectMake(MIDDLE1_COLUMN_OFFSET, (ROW_HEIGHT - LABEL_HEIGHT) / 2.0, MIDDLE1_COLUMN_WIDTH, LABEL_HEIGHT);
    label = [[UILabel alloc] initWithFrame:rect];
    label.tag = MIDDLE1_TAG;
    label.font = [UIFont systemFontOfSize:MAIN_FONT_SIZE];
    label.textAlignment = NSTextAlignmentRight;
    label.textColor = [UIColor blackColor];
    label.font = font;
    [cell.contentView addSubview:label];
    
    // Create a label.
    if (isNotReceiptInfo == NO) {
        rect = CGRectMake(MIDDLE2_COLUMN_OFFSET, (ROW_HEIGHT - LABEL_HEIGHT) / 2.0, MIDDLE2_COLUMN_WIDTH, LABEL_HEIGHT);
    } else {
        rect = CGRectMake(30, (ROW_HEIGHT - LABEL_HEIGHT) / 2.0, MIDDLE2_COLUMN_WIDTH * 2, LABEL_HEIGHT);
    }
    
    label = [[UILabel alloc] initWithFrame:rect];
    label.tag = MIDDLE2_TAG;
    label.font = [UIFont systemFontOfSize:MAIN_FONT_SIZE];
    label.textAlignment = NSTextAlignmentRight;
    label.textColor = [UIColor colorWithHexRed:0 green:121 blue:255 alpha:1];
    label.font = font;
    [cell.contentView addSubview:label];
    
    // Create a label.
    rect = CGRectMake(RIGHT_COLUMN_OFFSET, (ROW_HEIGHT - LABEL_HEIGHT) / 2.0, RIGHT_COLUMN_WIDTH, LABEL_HEIGHT);
    label = [[UILabel alloc] initWithFrame:rect];
    label.tag = RIGHT_TAG;
    label.font = [UIFont systemFontOfSize:MAIN_FONT_SIZE];
    label.textAlignment = NSTextAlignmentRight;
    label.textColor = [UIColor colorWithHexRed:178 green:0 blue:0 alpha:1];
    label.font = font;
    [cell.contentView addSubview:label];
    
    return cell;
}

- (void)creatAniView
{
    award_Off = NO;
    [self.navigationItem.rightBarButtonItem setEnabled:award_Off];
    self.popUpAniView = [PopUpAniView view];
    [self.popUpAniView setFrame:CGRectMake(0, 0, self.view.bounds.size.width , self.view.bounds.size.height )];
    self.popUpAniView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.popUpAniView.delegate = self;
    [self.popUpAniView pulsingHalo];
    [self.view addSubview:self.popUpAniView];
}

- (void)setLeftBarButton
{
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navbar_icon_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(cancelPressed)];
    
    self.navigationItem.leftBarButtonItem = backBtn;
}

- (void)setRightBarButton
{
    UIBarButtonItem *awardBtn =[[UIBarButtonItem alloc]initWithTitle:@"對獎" style:UIBarButtonItemStylePlain target:self action:@selector(creatAniView)];
    
    self.navigationItem.RightBarButtonItem = awardBtn;
}

-(void)cancelPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)popUpAniViewCancel:(PopUpAniView *)popUpAniView
{
    award_Off = YES;
    [self.navigationItem.rightBarButtonItem setEnabled:award_Off];
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - TableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [receiptArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AppTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [self tableViewCellWithReuseIdentifier:CellIdentifier];
	}
    
    Receipt* receipt = (Receipt*) [receiptArray objectAtIndex:indexPath.row];
    
    UILabel *label;
//    label = (UILabel *)[cell viewWithTag:LEFT_TAG];
//    label.text = [NSString stringWithFormat:@"%ld", indexPath.row + 1];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    cell.textLabel.text = receipt.invNum;
    
    label = (UILabel *)[cell viewWithTag:MIDDLE1_TAG];
    label.text = [self displayType:receipt.reward];
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:receipt.invNum];
    [attributeString addAttribute:NSUnderlineStyleAttributeName
                            value:[NSNumber numberWithInt:1]
                            range:(NSRange){0,[attributeString length]}];
    
    label = (UILabel *)[cell viewWithTag:MIDDLE2_TAG];
    label.attributedText = attributeString;
//    label.text = receipt.invNum;
    
    label = (UILabel *)[cell viewWithTag:RIGHT_TAG];
    label.text = [self displayReward:receipt.reward];
    debugLog(@"receipt.reward = %@", receipt.reward);
    
    return cell;
}

- (NSString*) displayReward:(NSString*)reward
{
    if ([reward isEqualToString:@"0000200"]) {
        return @"兩百元";
    } else if ([reward isEqualToString:@"0001000"]) {
        return @"一千元";
    } else if ([reward isEqualToString:@"0004000"]) {
        return @"四千元";
    } else if ([reward isEqualToString:@"0010000"]) {
        return @"一萬元";
    } else if ([reward isEqualToString:@"0040000"]) {
        return @"四萬元";
    } else if ([reward isEqualToString:@"0200000"]) {
        return @"二十萬";
    } else if ([reward isEqualToString:@"2000000"]) {
        return @"兩百萬";
    } else if ([reward isEqualToString:@"10000000"]) {
        return @"一千萬";
    } else {
        return reward;
    }
}

- (NSString*) displayType:(NSString*)reward
{
    if ([reward isEqualToString:@"0000200"]) {
        return @"六獎";
    } else if ([reward isEqualToString:@"0001000"]) {
        return @"五獎";
    } else if ([reward isEqualToString:@"0004000"]) {
        return @"四獎";
    } else if ([reward isEqualToString:@"0010000"]) {
        return @"三獎";
    } else if ([reward isEqualToString:@"0040000"]) {
        return @"二獎";
    } else if ([reward isEqualToString:@"0200000"]) {
        return @"頭獎";
    } else if ([reward isEqualToString:@"2000000"]) {
        return @"特獎";
    } else if ([reward isEqualToString:@"10000000"]) {
        return @"特別獎";
    } else {
        return reward;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
	return  44.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    AwardSectionHeaderView *sectionHeaderView = [self.awardListTableView dequeueReusableHeaderFooterViewWithIdentifier:SectionHeaderViewIdentifier];
    
    return sectionHeaderView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 5)];
	footer.backgroundColor = [UIColor clearColor];
	return footer;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - InsertAwardDelegate

-(void) receiveSuccess:(Award*)award invoYm:(NSString*)invoYm
{
    debugLog(@"invoYm = %@", invoYm);
    debugLog(@"award = %@", award);
}

-(void) receiveError:(NSString*)errStr errCode:(int) errCode
{
    debugLog(@"errStr = %@", errStr);
}

#pragma mark - Actions

- (IBAction)prevButtonAction:(UIButton *)sender
{
    [self prev];
}

- (IBAction)nextButtonAction:(UIButton *)sender
{
    [self next];
}

- (void) prev
{
    //    currentInvoYm = [ACUtility provAwardInvoYm:currentInvoYm];
    NSString *currentInvoYm = nil;
    if (invoYmIndex - 1 >= 0) {
        self.nextButton.enabled = YES;
        self.prevButton.enabled = YES;
        
        currentInvoYm = [invoYmList objectAtIndex:--invoYmIndex];
        self.invoYmLabel.text = [ACUtility convertDisplayString2FromInvoYm:currentInvoYm];
        [self awardInvWithReceiptArray:currentInvoYm];
        
        if (invoYmIndex - 1 < 0) {
            self.prevButton.enabled = NO;
        }
    } else {
        debugLog(@"沒有前一筆");
    }
    
//    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void) next
{
    //    currentInvoYm = [ACUtility nextAwardInvoYm:currentInvoYm];
    NSString *currentInvoYm = nil;
    if (invoYmIndex + 1 < [invoYmList count]) {
        self.nextButton.enabled = YES;
        self.prevButton.enabled = YES;
        
        currentInvoYm = [invoYmList objectAtIndex:++invoYmIndex];
        self.invoYmLabel.text = [ACUtility convertDisplayString2FromInvoYm:currentInvoYm];
        [self awardInvWithReceiptArray:currentInvoYm];
        if (invoYmIndex + 1 >= [invoYmList count]) {
            self.nextButton.enabled = NO;
        }
    } else {
        debugLog(@"沒有下一筆");
    }
    
//    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    debugLog(@"跳至首頁");
    [self.navigationController popViewControllerAnimated:YES];
    
//    HomeViewController *mainVC = [[HomeViewController alloc] init];
//    UINavigationController *ncVC = [[UINavigationController alloc] initWithRootViewController:mainVC ];
//    [self.mm_drawerController setCenterViewController:ncVC withCloseAnimation:YES completion:nil];
}

@end
