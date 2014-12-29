//
//  DetailViewController.m
//  QrInvoice
//
//  Created by Yen on 2014/7/2.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()<UITableViewDataSource,UITableViewDelegate,SWTableViewCellDelegate,UITextFieldDelegate>
{
    UIDatePicker *datePicker;
    NSLocale *datelocale;
}
@property (strong,nonatomic) UIBarButtonItem* editBtn;
@property (strong,nonatomic) UIBarButtonItem* saveBtn;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@end

@implementation DetailViewController
@synthesize numHead;
@synthesize numBody;
@synthesize randNum;
@synthesize boughtTime;
@synthesize spent;
@synthesize itemDataArr;
@synthesize editBtn,saveBtn;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.canEditing=NO;
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navbar_icon_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(pop)];
    self.navigationItem.leftBarButtonItem = backBtn;
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 292, 320, 276)];
    [self.view addSubview:self.tableView];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.navigationItem.title = @"發票明細";
    itemDataArr =[ @[] mutableCopy];
    NSString *headStr = [self.gotData.invNum substringToIndex:2];
    NSString *bodyStr = [self.gotData.invNum substringFromIndex:2];
    numHead.text = headStr;
    numBody.text = bodyStr;
    boughtTime.delegate = self;
    boughtTime.text = [self switchString:self.gotData.invDate];
    [self setDatePicker];
    spent.delegate = self;
    spent.text = [NSString stringWithFormat:@"%d", self.gotData.invspent];
    editBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navbar_icon_edit"] style:UIBarButtonItemStyleBordered target:self action:@selector(editSwitch)];
    saveBtn = [[UIBarButtonItem alloc]initWithTitle:@"儲存" style:UIBarButtonItemStyleBordered target:self action:@selector(saveAction)];
    self.navigationItem.rightBarButtonItem = editBtn;
   
    
    [self queryData];
}
-(NSString*)switchString:(NSString*)stringIn
{
    NSMutableString *muStr = [stringIn mutableCopy];
    if([muStr length] == 10){
        NSString *strOut = [muStr stringByReplacingOccurrencesOfString:@"/" withString:@""];
        return strOut;
    }
    [muStr insertString:@"/" atIndex:4];
    [muStr insertString:@"/" atIndex:7];
    return muStr;
}
-(void)pop
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)setDatePicker
{
    datePicker = [[UIDatePicker alloc]init];
    datelocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_TW"];
    datePicker.locale = datelocale;
    datePicker.timeZone = [NSTimeZone timeZoneWithName:@"GMT+8"];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.backgroundColor = [UIColor lightTextColor];
    boughtTime.inputView = datePicker;
    UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithTitle:@"確定" style:UIBarButtonItemStyleBordered target:self action:@selector(donePicker)];
    toolBar.items = [NSArray arrayWithObjects:flexibleSpace,right,nil];
    boughtTime.inputAccessoryView = toolBar;
    toolBar.barTintColor = [UIColor colorWithRed:248.0/255.0f green:205.0/255.0f blue:54.0/255.0f alpha:1.0];
    toolBar.tintColor = [UIColor blackColor];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.gotData.invType == 1){
        [self lockEdit];
        [self.tableView setFrame:CGRectMake(0, 220, 320, 348)];
    }
    [itemDataArr removeAllObjects];
    [self queryData];
    int allItemSpent = [self modifyCurrectSpent];
    if([spent.text intValue] != allItemSpent){
        spent.text = [NSString stringWithFormat:@"%d",allItemSpent];
        [self modifySpent:allItemSpent];
    }
    [self.tableView reloadData];
}
-(int)modifyCurrectSpent
{
    int sum = 0;
    for(int i = 0 ; i < [itemDataArr count] ; i++){
        detailData *data = [itemDataArr objectAtIndex:i];
        sum += [data.amount integerValue];
    }
    if(sum == 0){
        sum = [spent.text intValue];
    }
    return sum;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma tableView Delegate&Datasourece
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return itemDataArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"itemCell";
    ItemCell *cell = (ItemCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"ItemCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
        detailData *data = itemDataArr[indexPath.row];
        //cell.rightUtilityButtons = rightUtilityButtons;
        //cell.delegate = self;
        cell.imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",[self pickIcon:data.productType]]];
        cell.itemName.text = data.description;
        cell.cost.text = [NSString stringWithFormat:@"$%d",[data.amount intValue]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //[cell.itemName setFont:[UIFont systemFontOfSize:20]];
        cell.itemName.numberOfLines = 0;
        [cell.itemName sizeToFit];
    if(self.gotData.invType == 1){
        //cell.userInteractionEnabled = NO;
    }
        return cell;
}
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
    switch (index) {
        case 0:{
            ItemViewController *edVC = [[ItemViewController alloc]init];
            edVC.gotItem = itemDataArr[cellIndexPath.row];
            edVC.isNew = 0;
            edVC.gotData = self.gotData;
            [self.navigationController pushViewController:edVC animated:YES];
            break;}
        case 1:{
            detailData *data = itemDataArr[cellIndexPath.row];
            FMDatabase *db = [FMDatabase databaseWithPath:DB_PATH];
            if([db open]){
                NSString *sql = @"delete from details where id = ?";
                BOOL res = [db executeUpdate:sql,@(data.itemID)];
                if(!res){
                    NSLog(@"error to delete data");
                }else{
                    NSLog(@"succ to delete data");
                }
                [db close];
            }
            [itemDataArr removeObjectAtIndex:cellIndexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;}
        default:
            break;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ItemViewController *edVC = [[ItemViewController alloc]init];
    edVC.gotItem = itemDataArr[indexPath.row];
    edVC.isNew = 0;
    edVC.gotData = self.gotData;
    [self.navigationController pushViewController:edVC animated:YES];
    
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        detailData *data = itemDataArr[indexPath.row];
        FMDatabase *db = [FMDatabase databaseWithPath:DB_PATH];
        if([db open]){
            NSString *sql = @"delete from details where id = ?";
            NSString *updateSpent = [NSString stringWithFormat:@"update receipt set invspent=(select sum(amount) from details where invid = '%@') where invID = '%@'",self.gotData.invID,self.gotData.invID];
            BOOL res = [db executeUpdate:sql,@(data.itemID)];
            if(!res){
                NSLog(@"error to delete data");
            }else{
                NSLog(@"succ to delete data");
                [db executeUpdate:updateSpent];
            }
            [db close];
            
        }
        [itemDataArr removeObjectAtIndex:indexPath.row];
        if(itemDataArr.count == 0){
            spent.text = @"0";
            //select sum(amount) from details where invid = '10308WF12341234'
        }
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (IBAction)addOne:(id)sender {
    NSString *invStr = self.gotData.invNum;
    ItemViewController *edVC = [[ItemViewController alloc]init];
    edVC.gotData = self.gotData;
    edVC.invNumStr = invStr;
    edVC.isNew = 1;
    [self.navigationController pushViewController:edVC animated:YES];
}

-(void)editSwitch
{
    self.navigationItem.rightBarButtonItem = saveBtn;
    self.canEditing = YES;
    [numHead setBorderStyle:UITextBorderStyleRoundedRect];
    [numBody setBorderStyle:UITextBorderStyleRoundedRect];
    [randNum setBorderStyle:UITextBorderStyleRoundedRect];
    [boughtTime setBorderStyle:UITextBorderStyleRoundedRect];
    [spent setBorderStyle:UITextBorderStyleRoundedRect];
    [numHead setEnabled:YES];
    [numBody setEnabled:YES];
    [randNum setEnabled:YES];
    [boughtTime setEnabled:YES];
    [spent setEnabled:YES];
}

#pragma FMDB
-(void)queryData
{
    NSString *numStr = self.gotData.invID;
    FMDatabase * db = [FMDatabase databaseWithPath:DB_PATH];
    if ([db open]) {
        NSString * sql = @"select * from Details where invID = ?";
        FMResultSet * rs = [db executeQuery:sql,numStr];
        while ([rs next]) {
            detailData *Data = [[detailData alloc]init];
            Data.invID = [rs stringForColumn:@"invID"];
            Data.invNum = [rs stringForColumn:@"invNum"];
            Data.description = [rs stringForColumn:@"description"];
            Data.quantity = [rs stringForColumn:@"quantity"];
            Data.unitPrice = [rs stringForColumn:@"unitPrice"];
            Data.amount = [rs stringForColumn:@"amount"];
            Data.productType = [rs intForColumn:@"productType"];
            Data.itemID = [rs intForColumn:@"id"];
            [itemDataArr addObject:Data];
        }
        [db close];
    }
}

- (void)saveAction{
    
    if(![self checkInvNumber:numHead.text :numBody.text]){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"注意!" message:@"資料格式有誤" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    NSDictionary *dateDic = [self getPeriod:[self switchString:boughtTime.text]];
    FMDatabase *db = [FMDatabase databaseWithPath:DB_PATH];
    NSString *invString = [NSString stringWithFormat:@"%@%@",[numHead.text uppercaseString],numBody.text];
    NSString *sql = [NSString stringWithFormat:@"update receipt set invNum='%@', invdate=%@,invPeriod=%@,invspent=%@,invlottery = 0 , reward = '0' where invID = '%@'",invString,[self switchString:boughtTime.text],dateDic[@"period"],spent.text,self.gotData.invID];
    NSLog(@"sql == %@",sql);
    if([db open]){
      BOOL res = [db executeUpdate:sql];
        if(!res){
            NSLog(@"error to save receipt data");
        }else{
            NSLog(@"success to save receipt data");
            [self modifyItemInvNum:invString];
            
            self.dateChanged();
        }
        [db close];
    }
    self.navigationItem.rightBarButtonItem = editBtn;
    self.canEditing = NO;
    [numHead setEnabled:NO];
    [numBody setEnabled:NO];
    [randNum setEnabled:NO];
    [boughtTime setEnabled:NO];
    [spent setEnabled:NO];
    [numHead setBorderStyle:UITextBorderStyleNone];
    [numBody setBorderStyle:UITextBorderStyleNone];
    [randNum setBorderStyle:UITextBorderStyleNone];
    [boughtTime setBorderStyle:UITextBorderStyleNone];
    [spent setBorderStyle:UITextBorderStyleNone];

}
-(void)modifyItemInvNum:(NSString*)invStr
{
    FMDatabase *db = [FMDatabase databaseWithPath:DB_PATH];
    detailData *data = [[detailData alloc]init];
    NSString *sql = nil;
    if([db open]){
        for(int i = 0 ; i < itemDataArr.count ; i++){
            data = itemDataArr[i];
            sql = [NSString stringWithFormat:@"update details set invNum = '%@' where id = %d",invStr,data.itemID];
            [db executeUpdate:sql];
        }
        [db close];
    }
    
}
-(void)modifySpent:(int)newSpentValue
{
    FMDatabase *db = [FMDatabase databaseWithPath:DB_PATH];
    NSString *sql = [NSString stringWithFormat:@"update receipt set invspent=%@ where invID = '%@'",spent.text,self.gotData.invID];
    if([db open]){
        BOOL res = [db executeUpdate:sql];
        if(!res){
            NSLog(@"error to to modify spent");
        }else{
            NSLog(@"success to modify spent");
        }
        [db close];
    }
}

-(NSDictionary*)getPeriod:(NSString*)string
{
    NSRange range1 = NSMakeRange(0,4);
    NSRange range2 = NSMakeRange(4,2);
    int year = [[string substringWithRange:range1]intValue];
    int month = [[string substringWithRange:range2]intValue];
    NSString *dayStr = [string substringFromIndex:6];
    NSString *monthStr = [string substringWithRange:range2];
    if( month%2 == 1 ){
        month += 1;
    }
    NSString *periodStr;
    if([[NSString stringWithFormat:@"%li",(long)month] length] == 1){
        periodStr = [[NSString stringWithFormat:@"%li",(long)year-1911] stringByAppendingString:[NSString stringWithFormat:@"0%li",(long)month]];
    }else{
        periodStr = [[NSString stringWithFormat:@"%li",(long)year-1911] stringByAppendingString:[NSString stringWithFormat:@"%li",(long)month]];
    }
    NSString *dateStr = [NSString stringWithFormat:@"%d/%@/%@",year,monthStr,dayStr];
    NSDictionary *dic = @{@"date":dateStr,@"period":periodStr};
    return dic;
}

-(BOOL) checkInvNumber:(NSString*)headStr :(NSString*)bodyStr
{
    BOOL match = NO;
    NSString *regex = @"[a-zA-Z]{2}";
    NSString *regex2 = @"[0-9]{8}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex2];
    if([predicate evaluateWithObject:headStr] && [predicate2 evaluateWithObject:bodyStr]){
        match = YES;
    }
    
    return match;
}
-(void)lockEdit
{
    self.addBtn.enabled = NO;
    self.addBtn.alpha = 0.5;
    self.navigationItem.rightBarButtonItem = nil;
}

-(NSString*)pickIcon:(NSInteger)index
{
    NSArray *iconName = @[@"icon_life07",@"icon_life01",@"icon_life02",@"icon_life03",@"icon_life04",@"icon_life05",@"icon_life06",@"icon_life08"];
    NSString *string = [iconName objectAtIndex:index];
    return string;
}
-(void) donePicker {
    if ([self.view endEditing:NO]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"yyyy-MM-dd" options:0 locale:datelocale];
        [formatter setDateFormat:dateFormat];
        [formatter setLocale:datelocale];
        boughtTime.text = [NSString stringWithFormat:@"%@",[formatter stringFromDate:datePicker.date]];
    }
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
