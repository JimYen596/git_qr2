//
//  InvoiceAwardViewController.m
//  QrInvoice
//
//  Created by ChaLin LEE on 2014/7/3.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import "InvoiceAwardViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"
#import "AwardListViewController.h"
#import "AutoAwardViewController.h"
#import "SearchView.h"
#import "QrNetAPIManager.h"
#import "AwardDao.h"
#import "Award.h"
#import "MBProgressHUD.h"
#import "UIColor+Hex.h"
#import "SafariViewController.h"
#import "CheckNetwork.h"
#import "HomeViewController.h"
#import "UIViewController+MMDrawerController.h"

@interface InvoiceAwardViewController (){
    UISearchBar *_searchBar;
}
@property (nonatomic, strong) SearchView * searchView;
//@property (strong,nonatomic) UIView *searchView;
@end

@implementation InvoiceAwardViewController

@synthesize searchView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
            self.edgesForExtendedLayout = UIRectEdgeNone;
/*        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            self.view.bounds = CGRectMake(0, -20, self.view.frame.size.width, self.view.frame.size.height );
 //           self.searchView = [SearchView view];
        }*/
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([CheckNetwork check] == NO) {
        debugLog(@"沒有網路");
        
        NSString *invoYm = [ACUtility awardInvoYm];
        if ([AwardDao isContainInvoYm:invoYm] == NO) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"請連結網路後再使用發票對獎功能" delegate:self cancelButtonTitle:@"確定" otherButtonTitles:nil];
            [alertView show];
            
        }
    }
    
    self.title = @"發票對獎";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                      NSFontAttributeName:[UIFont fontWithName:@"AmericanTypewriter" size:22.0f]}];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:86.0f/255.0f green:222.0f/255.0f blue:167.0f/255.0f alpha:1.0]];
    
    [self setupLeftMenuButton];
    [self setupRightButton];
    
    CGRect tempFrame = [UIScreen mainScreen].applicationFrame;
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, tempFrame.size.width, 44.0)];
    _searchBar.delegate = self;
    _searchBar.keyboardType = UIKeyboardTypeNumberPad;
    _searchBar.translucent = YES;
    _searchBar.placeholder = @"請輸入末三碼";
    
    self.searchView = [SearchView view];
    [self.view addSubview:_searchBar];
    
    [self.monthSegmentedControl addTarget:self action:@selector(controlEventValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self calcAward];
    
    noLabelList = @[self.superPrizeNoLab, self.spcPrizeNoLab, self.firstPrizeNo1Lab, self.firstPrizeNo2Lab, self.firstPrizeNo3Lab, self.sixthPrizeNo1Lab, self.sixthPrizeNo2Lab];
    
    UIScreen *screen = [UIScreen mainScreen];
    debugLog(@"size = %f, %f", screen.bounds.size.width, screen.bounds.size.height);
    TTTAttributedLabel *tttLabel = nil;
    if(screen.bounds.size.height == 320) {
        tttLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(45, 350, 320, 100)];
    } else {
        tttLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(45, 430, 320, 100)];
    }
    
    NSString *labelText = @"財政部統一發票中獎號碼網頁";
    tttLabel.delegate = self;
    tttLabel.text = labelText;
    NSRange range;
    range.length = [labelText length];
    range.location = 0;
    [tttLabel addLinkToURL:[NSURL URLWithString:INVOICE_AWARD_URL] withRange:range];
    [self.view addSubview:tttLabel];
}

#pragma mark - Private Method

- (NSString*) currentInvoYm
{
    switch (self.monthSegmentedControl.selectedSegmentIndex) {
        case 0:
            return invoYm1;
            break;
            
        case 1:
            return invoYm2;
            break;
            
        default:
            break;
    }
    
    return nil;
}

- (NSString*) currentTackMoneyZone
{
    switch (self.monthSegmentedControl.selectedSegmentIndex) {
        case 0:
            return tackMoneyZone1;
            break;
            
        case 1:
            return tackMoneyZone2;
            break;
            
        default:
            break;
    }
    
    return nil;
}

- (void) calcAward
{
    invoYm1 = [ACUtility awardInvoYm];
    [ACUtility insertAwardWithInvoYm:invoYm1 delegate:self];
    int year1 = [ACUtility invoYmYear:invoYm1] + 1911;
    int money1 = [ACUtility invoYmMonth:invoYm1] + 2;
    tackMoneyZone1 = [NSString stringWithFormat:@"領獎期間 %04d/%02d/06 至 %04d/%02d/05止", year1, money1, year1, money1 + 3];
    self.tackMoneyZoneLabel.text = tackMoneyZone1;
    
    NSString *strMonth = [ACUtility convertDisplayStringFromInvoYm:invoYm1];
    debugLog(@"strMonth = %@", strMonth);
    [self.monthSegmentedControl setTitle:strMonth forSegmentAtIndex:0];
    
    invoYm2 = [ACUtility provAwardInvoYm:invoYm1];
    int year2 = [ACUtility invoYmYear:invoYm2] + 1911;
    int money2 = [ACUtility invoYmMonth:invoYm2] + 2;
    tackMoneyZone2 = [NSString stringWithFormat:@"領獎期間 %04d/%02d/06 至 %04d/%02d/05止", year2, money2, year2, money2 + 3];
    strMonth = [ACUtility convertDisplayStringFromInvoYm:invoYm2];
    [self.monthSegmentedControl setTitle:strMonth forSegmentAtIndex:1];
    [ACUtility insertAwardWithInvoYm:invoYm2 delegate:nil];
}

- (long) convertMonthFromString:(NSString*)strMonth
{
    NSRange range;
    range.length = 2;
    range.location = 4;
    
    return [[strMonth substringWithRange:range] intValue];
}

- (void) displayAwardWithInvoYm:(NSString*)invoYm
{
    Award *award = [AwardDao selectAwardWithInvoYm:invoYm];
    self.superPrizeNoLab.text = award.superPrizeNo;
    self.spcPrizeNoLab.text = award.spcPrizeNo;
    
//    debugLog(@"award.superPrizeNo = %@", award.superPrizeNo);
//    debugLog(@"award.spcPrizeNo = %@", award.spcPrizeNo);
    
    NSArray *firstPrizeNoList = [award.firstPrizeNo componentsSeparatedByString:@","];
    for (int i=1 ; i<=[firstPrizeNoList count] ; i++) {
        switch (i) {
            case 1: {
                self.firstPrizeNo1Lab.text = [firstPrizeNoList objectAtIndex:i-1];
                NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:self.firstPrizeNo1Lab.text];
                NSRange range;
                range.length = 3;
                range.location = 5;
                [attrString beginEditing];
                [attrString addAttribute: NSForegroundColorAttributeName
                                   value:[UIColor redColor]
                                   range:range];
                [attrString endEditing];
                self.firstPrizeNo1Lab.attributedText = attrString;
                break;
            }
                
            case 2: {
                self.firstPrizeNo2Lab.text = [firstPrizeNoList objectAtIndex:i-1];
                NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:self.firstPrizeNo2Lab.text];
                NSRange range;
                range.length = 3;
                range.location = 5;
                [attrString beginEditing];
                [attrString addAttribute: NSForegroundColorAttributeName
                                   value:[UIColor redColor]
                                   range:range];
                [attrString endEditing];
                self.firstPrizeNo2Lab.attributedText = attrString;
                break;
            }
                
            case 3: {
                self.firstPrizeNo3Lab.text = [firstPrizeNoList objectAtIndex:i-1];
                NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:self.firstPrizeNo3Lab.text];
                NSRange range;
                range.length = 3;
                range.location = 5;
                [attrString beginEditing];
                [attrString addAttribute: NSForegroundColorAttributeName
                                   value:[UIColor redColor]
                                   range:range];
                [attrString endEditing];
                self.firstPrizeNo3Lab.attributedText = attrString;
                break;
            }
            
            default:
                break;
        }
    }
    
    NSArray *sixthPrizeNoList = [award.sixthPrizeNo componentsSeparatedByString:@","];
    for (int i=1 ; i<=[sixthPrizeNoList count] ; i++) {
        switch (i) {
            case 1:
                self.sixthPrizeNo1Lab.text = [sixthPrizeNoList objectAtIndex:i-1];
                break;
                
            case 2:
                self.sixthPrizeNo2Lab.text = [sixthPrizeNoList objectAtIndex:i-1];
                break;
                
            default:
                break;
        }
    }
    
//    NSString *str = [award.firstPrizeNo stringByReplacingOccurrencesOfString:@"," withString:@"\n"];
//    self.firstPrizeNo1Lab.text = str;
}

- (void)setupLeftMenuButton
{
    MMDrawerBarButtonItem *leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    leftDrawerButton.image = [UIImage imageNamed:@"navbar_icon_menu"];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
}

- (void)setupRightButton
{
    UIBarButtonItem *btnAdd = [[UIBarButtonItem alloc]initWithTitle:@"搖搖對獎" style:UIBarButtonItemStylePlain target:self action:@selector(autoAward)];
    
    [self.navigationItem setRightBarButtonItem:btnAdd animated:YES];
}

#pragma mark - Button Handlers

- (void)leftDrawerButtonPress:(id)sender
{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    [_searchBar resignFirstResponder];
}

- (void)autoAward
{
    AutoAwardViewController *autoAwardVC = [[AutoAwardViewController alloc]initWithNibName:@"AutoAwardViewController" bundle:nil];
    UINavigationController * ncVC = [[UINavigationController alloc] initWithRootViewController:autoAwardVC];
    [self presentViewController:ncVC animated:YES completion:NULL];
}

#pragma mark - UISearchBarDelegate

- (BOOL) matchSearchText:(NSString*)searchText label:(UILabel*)labelNo
{
    NSString *newNo = nil;
    if ([labelNo.text length] == 8) {
        NSRange range;
        range.length = 3;
        range.location = 5;
        newNo = [labelNo.text substringWithRange:range];
    } else {
        newNo = labelNo.text;
    }
    
    debugLog(@"labelNo.text = %@", labelNo.text);
    
    if ([searchText isEqualToString:newNo]) {
        [labelNo setBackgroundColor:[UIColor colorWithHexRed:145 green:145 blue:145 alpha:1]];
        return YES;
    } else {
        return NO;
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"searchText = %@", searchText);
    [self.searchView.unawardLab setHidden:YES];
    [self.searchView.numberLab setHidden:YES];
    
    if (searchText.length == 3) {
        [searchBar setText:nil];
        
//        NSString *invoYm = [self currentInvoYm];
//        Award *award = [AwardDao selectAwardWithInvoYm:invoYm];
        
        // clear
        for (UILabel *label in noLabelList) {
            [label setBackgroundColor:[UIColor clearColor]];
        }
        
        BOOL isMatch = NO;
        for (UILabel *label in noLabelList) {
            BOOL _isMatch = [self matchSearchText:searchText label:label];
            if (_isMatch) {
                isMatch = YES;
            }
        }
        
        if (isMatch) {
            _searchBar.showsCancelButton = NO;
            [_searchBar resignFirstResponder];
            return;
        } else {
            [self.searchView.unawardLab setHidden:NO];
            [self.searchView.numberLab setHidden:NO];
            [self.searchView.numberLab setText:searchText];
        }
        
    }
   
}

/*
- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSLog(@"======%d , %@ , %@",range.location,text,searchBar.text);
    if (range.location == 3) {
        searchBar.text = nil;
        [self.searchView.unawardLab setHidden:NO];
        [self.searchView.numberLab setHidden:NO];
        self.searchView.numberLab.text = searchBar.text;
        return NO;
    }
    return YES;
}*/

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [_firstPrizeNo1Lab setBackgroundColor:[UIColor clearColor]];
    _searchBar.showsCancelButton = YES;
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    CGRect windFrame = [_searchBar.superview convertRect:_searchBar.frame toView:window];
    self.searchView.frame = CGRectMake(windFrame.origin.x, windFrame.origin.y+windFrame.size.height, windFrame.size.width, window.frame.size.height - windFrame.origin.y+windFrame.size.height);
    self.searchView.alpha = 0;
    [window addSubview:self.searchView];
    [UIView animateWithDuration:0.3 animations:^{
        self.searchView.alpha = 1;
    }];
 //   NSLog(@"11111");
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    _searchBar.showsCancelButton = NO;
    searchBar.text = nil;
    [UIView animateWithDuration:0.3 animations:^{
        self.searchView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.searchView removeFromSuperview];
        [self.searchView.unawardLab setHidden:YES];
        [self.searchView.numberLab setHidden:YES];
    }];

//    NSLog(@"1234");
}

/*
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
 //   NSLog(@"1234");
}*/

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
//    _searchBar.showsCancelButton = NO;
    [_searchBar resignFirstResponder];
//    searchBar.text = nil;
/*    [UIView animateWithDuration:0.3 animations:^{
        self.searchView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.searchView removeFromSuperview];
    }];*/

//    _searchBar.text re
//    NSLog(@"12345");
}

/*
- (BOOL) canBecomeFirstResponder{
    return YES;
}
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if (motion == UIEventSubtypeMotionShake) {
        NSLog(@"1");
    }
}
- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if (motion == UIEventSubtypeMotionShake) {
        NSLog(@"2");
    }
}
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if (motion == UIEventSubtypeMotionShake) {
        NSLog(@"3");
    }
}

- (IBAction)tapInvAward:(id)sender {
 //   self.mm_drawerController.openDrawerGestureModeMask ^=  MMOpenDrawerGestureModeAll;
 //   [self.mm_drawerController setLeftDrawerViewController:nil];
//    self.mm_drawerController
    AwardListViewController *awardListVC = [[AwardListViewController alloc]init];
    [self.mm_drawerController closeDrawerAnimated:NO completion:nil];
    [self.navigationController pushViewController:awardListVC animated:YES];
//    [self.mm_drawerController closeDrawerAnimated:NO completion:nil];
//    NSLog(@"12345");
}*/

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
    [self displayAwardWithInvoYm:invoYm1];
}

-(void) receiveError:(NSString*)errStr errCode:(int) errCode
{
    debugLog(@"errStr = %@", errStr);
}

#pragma mark - Actions

- (void) controlEventValueChanged:(UISegmentedControl*)segmentedControl
{
//    NSString *title = [segmentedControl titleForSegmentAtIndex:segmentedControl.selectedSegmentIndex];
//    debugLog(@"title = %@", title);
//    
//    long month = [self convertMonthFromString:title];
//    debugLog(@"month = %ld", month);
    
    for (UILabel *label in noLabelList) {
        [label setBackgroundColor:[UIColor clearColor]];
    }
    
    NSString *invoYm = [self currentInvoYm];
    [self displayAwardWithInvoYm:invoYm];
    
    NSString *tackMoneyZone = [self currentTackMoneyZone];
    self.tackMoneyZoneLabel.text = tackMoneyZone;
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
//    if ([[url scheme] hasPrefix:@"action"]) {
//        if ([[url host] hasPrefix:@"show-help"]) {
//            /* load help screen */
//        } else if ([[url host] hasPrefix:@"show-settings"]) {
//            /* load settings screen */
//        }
//    } else {
//        /* deal with http links here */
//    }
    
    debugLog(@"url = %@", url);
//    [[UIApplication sharedApplication] openURL:url];ß
    
    SafariViewController *safariViewController = [[SafariViewController alloc] initWithNibName:@"SafariViewController" bundle:nil];
    [self presentViewController:safariViewController animated:YES completion:nil];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    debugLog(@"跳至首頁");
    
    HomeViewController *mainVC = [[HomeViewController alloc] init];
    UINavigationController *ncVC = [[UINavigationController alloc] initWithRootViewController:mainVC ];
    [self.mm_drawerController setCenterViewController:ncVC withCloseAnimation:YES completion:nil];
}

@end
