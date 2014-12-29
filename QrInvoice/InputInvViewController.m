//
//  InputInvViewController.m
//  QrInvoice
//
//  Created by Yen on 2014/7/3.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import "InputInvViewController.h"
#import "FMDatabase.h"
#import "DetailViewController.h"
#import "invData.h"


@interface InputInvViewController ()<UITextFieldDelegate,UIAlertViewDelegate>
{
    UIDatePicker *datePicker;
    NSLocale *datelocale;
    invData *sendData;
}
@end

@implementation InputInvViewController
@synthesize numHead,numBody,randomNumber,boughtTime,spent;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.navigationItem.title = @"手動輸入發票";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
         NSFontAttributeName:[UIFont fontWithName:@"AmericanTypewriter" size:22.0f]}];
    UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc]initWithTitle:@"儲存" style:UIBarButtonItemStyleBordered target:self action:@selector(SaveAction)];
        UIBarButtonItem *backBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navbar_icon_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(pop)];
    [self.navigationItem setRightBarButtonItem:saveBtn];
    [self.navigationItem setLeftBarButtonItem:backBtn];
    [self setTextField];
}
-(void)pop
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)SaveAction {
    
    if(![self checkInput]){
        return;
    }
    sendData = [[invData alloc]init];
    FMDatabase *db = [FMDatabase databaseWithPath:DB_PATH];
    NSString *numString = [NSString stringWithFormat:@"%@%@",[numHead.maskedTextField.text uppercaseString],numBody.maskedTextField.text];
    NSString *dateString = [boughtTime.text stringByReplacingOccurrencesOfString:@"/" withString:@""];
    int invType = 0;
    if([randomNumber isFieldComplete]){
        invType = 1;
    }else{
        randomNumber.maskedTextField.text = @"NULL";
    }    
    sendData.invNum = numString;
    sendData.randomNum = randomNumber.maskedTextField.text;
    sendData.invDate = dateString;
    sendData.invPeriod = [self getPeriod:boughtTime.text];
    sendData.invspent = [spent.text length]==0?0:[spent.text intValue];
    sendData.invType = invType;
    sendData.gotData = 0;
    sendData.lottery = 0;
    sendData.invID = [sendData.invPeriod stringByAppendingString:numString];
    
    if([db open]){
        BOOL isExist;
        NSString *sql = [NSString stringWithFormat:@"select count(*) as row_count from receipt where invid = '%@'",sendData.invID];
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            isExist = [rs boolForColumn:@"row_count"];
        }
        [db close];
        if(isExist){
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"訊息" message:@"這張發票已存在!!" delegate:nil cancelButtonTitle:@"確定" otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
    }
    
    if([db open]){
        NSString * sql =[NSString stringWithFormat:@"insert into Receipt (invID,invNum,randomNumber,invDate,invPeriod,invSpent,invType,gotData,invLottery,reward) values('%@','%@',%@,%@,%@,%@,%d,%d,%d,%@)",sendData.invID,numString,randomNumber.maskedTextField.text,dateString,[self getPeriod:boughtTime.text],[spent.text length]==0?0:spent.text,invType,0,0,@"0"];
        BOOL res = [db executeUpdate:sql];
        if(!res){
            NSLog(@"error to insert new records");
        }else{
            NSLog(@"succ to insert a new data");
            [self clearView];
            [self showSuccessAlertView:invType];
        }
        [db close];
    }
}

#pragma UITextField Delegate
-(NSString*)getPeriod:(NSString*)string
{
    NSRange range1 = NSMakeRange(0,4);
    NSRange range2 = NSMakeRange(5,2);
    int year = [[string substringWithRange:range1]intValue];
    int month = [[string substringWithRange:range2]intValue];
    year = year -1911;
    if( month%2 == 1 ){
        month += 1;
    }
    NSString *periodStr;
    if([[NSString stringWithFormat:@"%li",(long)month] length] == 1){
        periodStr = [[NSString stringWithFormat:@"%li",(long)year] stringByAppendingString:[NSString stringWithFormat:@"0%li",(long)month]];
    }else{
        periodStr = [[NSString stringWithFormat:@"%li",(long)year] stringByAppendingString:[NSString stringWithFormat:@"%li",(long)month]];
    }
    
    return periodStr;
}
-(void)clearView
{
    //numHead.maskedTextField.text = EMPTY_STRING;
    //numBody.maskedTextField.text = EMPTY_STRING;
    //randomNumber.maskedTextField.text = EMPTY_STRING;
    [numHead showMask];
    [numBody showMask];
    [randomNumber showMask];
    boughtTime.text = EMPTY_STRING;
    spent.text = EMPTY_STRING;
    [numHead becomeFirstResponder];
}
-(void) showSuccessAlertView:(int)type
{
    if(type == 1){
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"儲存成功" message:@"商品明細將自動帶入" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        [alertView show];
        [self performSelector:@selector(close:) withObject:alertView afterDelay:1];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"儲存成功" message:@"是否需要編輯商品明細" delegate:self cancelButtonTitle:@"是" otherButtonTitles:@"否", nil];
        [alertView show];
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:{
            DetailViewController *vc = [[DetailViewController alloc]init];
            vc.gotData = sendData;
            [vc setDateChanged:^(void){
                NSLog(@"EditFromNewInv");
            }];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 1:{
            break;
        }
        default:
            break;
    }
}
-(void)close:(UIAlertView*)alertView
{
    [alertView dismissWithClickedButtonIndex:-1 animated:YES];
}
-(void) setTextField
{
    
    numHead = [[OCMaskedTextFieldView alloc]initWithFrame:CGRectMake(120 , 10, 50, 30) andMask:@"??" showMask:NO];
    [[numHead maskedTextField] setBorderStyle:UITextBorderStyleLine];
    [[numHead maskedTextField] setFont:MEDIUM_FONT];
    [[numHead maskedTextField] setTintColor:KILL_LA_KILL_RED_COLOR];
    [[numHead maskedTextField] setKeyboardAppearance:UIKeyboardAppearanceDark];
    numHead.maskedTextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    [self setupTextField:[numHead maskedTextField]];
    numHead.maskedTextField.tag = 0;
    [self.view addSubview:numHead];
    
    numBody = [[OCMaskedTextFieldView alloc]initWithFrame:CGRectMake(170, 10, 130, 30) andMask:@"########" showMask:NO];
    [[numBody maskedTextField] setBorderStyle:UITextBorderStyleLine];
    [[numBody maskedTextField] setFont:MEDIUM_FONT];
    [[numBody maskedTextField] setTintColor:KILL_LA_KILL_RED_COLOR];
    [[numBody maskedTextField] setKeyboardAppearance:UIKeyboardAppearanceDark];
    numBody.maskedTextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    [self setupTextField:[numBody maskedTextField]];
    numBody.maskedTextField.tag = 1;
    [self.view addSubview:numBody];
    
    randomNumber = [[OCMaskedTextFieldView alloc]initWithFrame:CGRectMake(120, 60, 180, 30) andMask:@"####" showMask:NO];
    [[randomNumber maskedTextField] setBorderStyle:UITextBorderStyleLine];
    [[randomNumber maskedTextField] setFont:MEDIUM_FONT];
    [[randomNumber maskedTextField] setTintColor:KILL_LA_KILL_RED_COLOR];
    [[randomNumber maskedTextField] setKeyboardAppearance:UIKeyboardAppearanceDark];
    randomNumber.maskedTextField.placeholder = @"*辨識是否為電子發票";
    randomNumber.maskedTextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    [self setupTextField:[randomNumber maskedTextField]];
    [self.view addSubview:randomNumber];
    
    boughtTime = [[UITextField alloc] initWithFrame:CGRectMake(120, 110, 180, 30)];
    boughtTime.borderStyle = UITextBorderStyleLine;
    boughtTime.delegate = self;
    [self.view addSubview:boughtTime];
    datePicker = [[UIDatePicker alloc]init];
    datelocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_TW"];
    datePicker.locale = datelocale;
    datePicker.timeZone = [NSTimeZone timeZoneWithName:@"GMT+8"];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.backgroundColor = [UIColor lightTextColor];
    boughtTime.inputView = datePicker;
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithTitle:@"確定" style:UIBarButtonItemStyleBordered target:self action:@selector(donePicker)];
    toolBar.items = [NSArray arrayWithObjects:flexibleSpace,rightBtn,nil];
    boughtTime.inputAccessoryView = toolBar;
    toolBar.barTintColor = [UIColor colorWithRed:248.0/255.0f green:205.0/255.0f blue:54.0/255.0f alpha:1.0];
    toolBar.tintColor = [UIColor blackColor];
    
    spent = [[UITextField alloc]initWithFrame:CGRectMake(120, 160, 180, 30)];
    [spent setBorderStyle:UITextBorderStyleLine];
    [spent setKeyboardType:UIKeyboardTypeNumberPad];
    [spent setKeyboardAppearance:UIKeyboardAppearanceDark];
    spent.delegate = self;
    [self.view addSubview:spent];
    
    [numHead becomeFirstResponder];

}
- (void)setupTextField:(UITextField*)textField
{
    textField.backgroundColor    = [UIColor whiteColor];
    textField.layer.borderColor  = [UIColor whiteColor].CGColor;
    textField.layer.borderWidth  = 0.0;
    textField.layer.cornerRadius = 1.0;
    if (textField.textAlignment != NSTextAlignmentCenter)
    {
        textField.layer.sublayerTransform = CATransform3DMakeTranslation(8, 0, 0);
    }
}
-(void) donePicker {
    if ([self.view endEditing:NO]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"yyyy-MM-dd" options:0 locale:datelocale];
        [formatter setDateFormat:dateFormat];
        [formatter setLocale:datelocale];
        boughtTime.text = [datePicker.date timeIntervalSince1970] > [[NSDate date] timeIntervalSince1970]?[NSString stringWithFormat:@"%@",[formatter stringFromDate:[NSDate date]]]:[NSString stringWithFormat:@"%@",[formatter stringFromDate:datePicker.date]];
    }
}
-(BOOL)checkInput
{
    UIAlertView *alertMessage = [[UIAlertView alloc]initWithTitle:@"提醒" message:@"資料輸入不完整" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [self performSelector:@selector(close:) withObject:alertMessage afterDelay:1];
    if(![numHead isFieldComplete]){
        [alertMessage show];
        return NO;
    }
    if(![numBody isFieldComplete]){
        [alertMessage show];
        return NO;
    }
    if([boughtTime.text length] == 0){
       [alertMessage show];
        return NO;
    }
    if(!spent.text){
        spent.text = @"0";
        return NO;
    }
    return YES;
    
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 9) ? NO : YES;
}
@end
