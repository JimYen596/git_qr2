//
//  InvListViewController.m
//  QrInvoice
//
//  Created by Yen on 2014/7/1.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import "InvListViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"
#import "QrNetAPIManager.h"
#import "ACUtility.h"

@interface InvListViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UISearchBarDelegate>
{
    NSInteger pointer;
    BOOL searchInv;
    NSString *searchWord;
    NSString *msg;
    UILabel *msgLab;
    int failUpdate;
    int succUpdate;
}
@property (strong,nonatomic) UIBarButtonItem *btnEdit;
@property (strong,nonatomic) UIBarButtonItem *btnAdd;
@property (strong,nonatomic) UIBarButtonItem *btnCancel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnDelete;
@property (weak, nonatomic) IBOutlet UILabel *periodLab;
@property (nonatomic) NSMutableArray *periodArr;
@property (strong,nonatomic) UITextField *serachTexyField;
@property (strong, nonatomic) UILabel *infoLab;
@property (strong, nonatomic) UILabel *costLab;
@property (strong,nonatomic) UIAlertView *updateAlert;
@end

@implementation InvListViewController
@synthesize dataArray;
@synthesize periodArr;
@synthesize btnAdd;
@synthesize btnCancel;
@synthesize btnDelete;
@synthesize btnEdit;
@synthesize serachTexyField;
@synthesize infoLab,costLab;
@synthesize periodNavi;
@synthesize invSearchBar,updateAlert;
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
    
    dataArray = [@[] mutableCopy];
    periodArr = [@[] mutableCopy];
//設定介面
    [self setupInterface];
//更新商品
    [self updateReceiptInDetails];
//讀取當期發票
    [self queryData:[self getPeriodStrNow]];
//取得現有發票期別
    [self getAllPeriodsArray];
//設定畫面
    [self setupViews];
    
    [self setConsTrants];

}
-(void)setConsTrants
{
    [self.toolBar setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *myConstraint;
    //toolbar constrant
    myConstraint = [NSLayoutConstraint constraintWithItem:self.toolBar
                                       attribute:NSLayoutAttributeBottom
                                       relatedBy:NSLayoutRelationGreaterThanOrEqual
                                        toItem:[self.toolBar superview]
                                        attribute:NSLayoutAttributeBottom
                                        multiplier:1.0f constant:0.0f];
    [self.view addConstraint:myConstraint];

}
-(void)setupInterface
{
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
//navigationbar
    self.navigationItem.title = @"發票清單";
    self.navigationController.navigationBar.translucent = NO;
    periodNavi.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"AmericanTypewriter" size:22.0f]}];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:255.0/255.0f green:118.0/255.0f blue:89.0/255.0f alpha:1.0]];
    [periodNavi setBarTintColor:[UIColor colorWithRed:255.0/255.0f green:118.0/255.0f blue:89.0/255.0f alpha:1.0]];
    
//tableView
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
//searchBar
    searchInv = NO;
    invSearchBar.delegate = self;
    invSearchBar.placeholder = @"請輸入商品名稱";
    [self searchBarChangeKey];
//buttons    
    btnEdit = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navbar_icon_edit"] style:UIBarButtonItemStyleBordered target:self action:@selector(editAction)];
    btnCancel = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelAction)];
    btnDelete.enabled = NO;
    btnDelete.title = @"";
    [self.navigationItem setRightBarButtonItem:btnEdit];
    [self setupLeftMenuButton];
}
-(void)setupViews
{
    infoLab = [[UILabel alloc]initWithFrame:self.toolBar.bounds];
    costLab = [[UILabel alloc]initWithFrame:CGRectMake(infoLab.bounds.origin.x+self.toolBar.bounds.size.width/2, infoLab.bounds.origin.y, infoLab.bounds.size.width/2-10, infoLab.bounds.size.height)];
    [costLab setFont:[UIFont systemFontOfSize:24]];
    infoLab.text = [NSString stringWithFormat:@"  消費金額合計:"];
    costLab.text = [NSString stringWithFormat:@"$%d",[self totalCost]];
    infoLab.backgroundColor = [UIColor groupTableViewBackgroundColor];
    costLab.backgroundColor = infoLab.backgroundColor;
    infoLab.textAlignment = NSTextAlignmentLeft;
    costLab.textAlignment = NSTextAlignmentRight;
    [self.toolBar addSubview:infoLab];
    [infoLab addSubview:costLab];
    [self.toolBar bringSubviewToFront:infoLab];
}
-(void)viewWillAppear:(BOOL)animated
{
    [self updateButtonsToMatchTableState];
    
    [dataArray removeAllObjects];
    if(pointer > periodArr.count - 1){
       pointer = 0;
    }
    [self queryData:periodArr[pointer]];
    [self.tableView reloadData];
    costLab.text = [NSString stringWithFormat:@"$%d",[self totalCost]];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma tableView Datasource&Delegate
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateDeleteButtonTitle];
    ReceiptCell *cell = (ReceiptCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell changeSelectedMark:cell.selected];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.tableView.editing){
        [self updateButtonsToMatchTableState];
        ReceiptCell *cell = (ReceiptCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell changeSelectedMark:cell.selected];
    }else{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        DetailViewController *edVC = [[DetailViewController alloc]init];
        edVC.gotData = dataArray[indexPath.row];
        [edVC setDateChanged:^(void){
            
            [self getAllPeriodsArray];
        }];
        [self.navigationController pushViewController:edVC animated:YES];
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return dataArray.count;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellID";
    ReceiptCell *cell = (ReceiptCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"ReceiptCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    invData *data = nil;
        data = [dataArray objectAtIndex:indexPath.row];
    
    switch (data.lottery) {
        case 0:
            cell.imgView.image = [UIImage imageNamed:@"icon_list_no"];
            break;
        case 1:
            cell.imgView.image = [UIImage imageNamed:@"icon_list_none"];
            break;
        case 2:
            cell.imgView.image = [UIImage imageNamed:@"icon_list_win"];
            break;
        default:
            break;
    }
    NSString *monthStr = [data.invDate substringWithRange:NSMakeRange(4, 2)];
    NSString *dayStr = [data.invDate substringFromIndex:6];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.periodLab.text = [NSString stringWithFormat:@"%@/%@",monthStr,dayStr];
    cell.numberLab.text = data.invNum;
    if(data.invType == 0){
        cell.typeLab.text = @"傳統發票";
    }else{
        cell.typeLab.text = @"電子發票";
    }
    if(data.invType == 1 && data.gotData == 0){
        cell.typeLab.text = @"電子發票(未)";
    }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.costLab.text = [NSString stringWithFormat:@"$%d",data.invspent];
    return cell;
}

-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
        [(ReceiptCell*)cell changeSelectedMark:cell.selected];
}
#pragma FMDB methods
-(void)updateReceiptInDetails
{
    FMDatabase *db = [FMDatabase databaseWithPath:DB_PATH];
    if([db open]){
        int notYetToUpdate = 0;
        NSString *sql = @"select * from receipt where invtype = 1 and gotdata = 0 ";
        NSString *sqlUpdate = @"insert into Details(invID,invNum, description, quantity, unitPrice, amount, productType) values(?,?,?,?,?,?,?)";
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            ++notYetToUpdate;
            invData *Data = [[invData alloc]init];
            Data.invID = [rs stringForColumn:@"invID"];
            Data.invNum = [rs stringForColumn:@"invNum"];
            Data.randomNum = [rs stringForColumn:@"randomNumber"];
            Data.invDate = [rs stringForColumn:@"invDate"];
            Data.invPeriod = [rs stringForColumn:@"invPeriod"];
            Data.invspent = [rs intForColumn:@"invSpent"];
            Data.invType = [rs intForColumn:@"invType"];
            Data.gotData = [rs intForColumn:@"gotData"];
            Data.lottery = [rs intForColumn:@"invLottery"];
            Data.reward = [rs intForColumn:@"reward"];
            NSDictionary *dateDic = [self getPeriod:Data.invDate];
            
            [[QrNetAPIManager requestWithFinishBlock:^(NSObject *object) {
                NSDictionary*itemDic = (NSDictionary*)object;
                NSArray *detailArr = itemDic[@"details"];
                if([itemDic[@"invStatus"] isEqualToString:@"已確認"]){
                    succUpdate++;
                }else{
                    ++failUpdate;
                }
                debugLog(@"status = %@",itemDic[@"invStatus"]);
                //debugLog(@"details == %@",detailArr);
                for(int i = 0 ; i < [detailArr count] ; i++){
                    [db open];
                    BOOL res = [db executeUpdate:sqlUpdate,Data.invID,Data.invNum,detailArr[i][@"description"],detailArr[i][@"quantity"],detailArr[i][@"unitPrice"],detailArr[i][@"amount"],@(7)];
                    if(res){
                        NSLog(@"Success to insert item%d",i);
                        if([db executeUpdate:[NSString stringWithFormat:@"update receipt set gotdata = 1 where invID = '%@'",Data.invID]]){
                            NSLog(@"succ update%d",i);
                        }
                    }else{
                        NSLog(@"Error to insert item");
                    }
                }
                if(succUpdate == notYetToUpdate){
                    [self showUpdateState];
                }
            } failBlock:^(NSString *errStr, int errCode) {
                NSLog(@"errStr: %@", errStr);
            }] fetchQryInvDetailWithInvNum:Data.invNum InvDate:dateDic[@"date"] InvTerm:dateDic[@"period"] Encypt:@"w2EpCZGeuTvQX+C7MI7Nea==" SellerID:@"54379043" type:Barcode randNum:Data.randomNum];
        }
        [db close];
    }
}
-(void)showUpdateState
{
    msg = [NSString stringWithFormat:@"全部更新完成"];
            if(succUpdate>0){
                updateAlert = [[UIAlertView alloc]initWithTitle:@"通知" message:msg delegate:nil cancelButtonTitle:@"確定" otherButtonTitles:nil, nil];
                [updateAlert show];
            }
}
-(void)queryData:(NSString*)perString
{
    FMDatabase * db = [FMDatabase databaseWithPath:DB_PATH];
    if ([db open]) {
        NSString *sql = @"select * from Receipt where invPeriod = ? ORDER BY invLottery DESC ,invDate DESC";
        NSString *sql3 = [NSString stringWithFormat:@"select * from Receipt where invPeriod = ? AND invID in (select distinct invID from Details where description like '%%%@%%' ) ORDER BY invLottery and invDate DESC",searchWord];
        if(searchInv == YES){
            FMResultSet * rs = [db executeQuery:sql3,perString];
            while ([rs next]) {
                invData *Data = [[invData alloc]init];
                Data.invID = [rs stringForColumn:@"invID"];
                Data.invNum = [rs stringForColumn:@"invNum"];
                Data.randomNum = [rs stringForColumn:@"randomNumber"];
                Data.invDate = [rs stringForColumn:@"invDate"];
                Data.invPeriod = [rs stringForColumn:@"invPeriod"];
                Data.invspent = [rs intForColumn:@"invSpent"];
                Data.invType = [rs intForColumn:@"invType"];
                Data.gotData = [rs intForColumn:@"gotData"];
                Data.lottery = [rs intForColumn:@"invLottery"];
                Data.reward = [rs intForColumn:@"reward"];
                [dataArray addObject:Data];
            }
        }else{
            FMResultSet * rs = [db executeQuery:sql,perString];
            while ([rs next]) {
                invData *Data = [[invData alloc]init];
                Data.invID = [rs stringForColumn:@"invID"];
                Data.invNum = [rs stringForColumn:@"invNum"];
                Data.randomNum = [rs stringForColumn:@"randomNumber"];
                Data.invDate = [rs stringForColumn:@"invDate"];
                Data.invPeriod = [rs stringForColumn:@"invPeriod"];
                Data.invspent = [rs intForColumn:@"invSpent"];
                Data.invType = [rs intForColumn:@"invType"];
                Data.gotData = [rs intForColumn:@"gotData"];
                Data.lottery = [rs intForColumn:@"invLottery"];
                Data.reward = [rs intForColumn:@"reward"];
                [dataArray addObject:Data];
            }
        }
        [db close];
    }
}
-(void)deleteData:(NSString*)string
{
    FMDatabase * db = [FMDatabase databaseWithPath:DB_PATH];
    if ([db open]) {
        NSString *sql1 = [NSString stringWithFormat:@"delete from Receipt WHERE invID in (%@)",string];
        NSString *sql2 = [NSString stringWithFormat:@"delete from Details WHERE invID in (%@)",string];
        BOOL res = [db executeUpdate:sql1];
        if (!res) {
            debugLog(@"error to delete data");
        } else {
            debugLog(@"succ to delete inv data");
            if([db executeUpdate:sql2]){
                debugLog(@"succ to delete item data");
            }
        }
        [db close];
    }
    [self removeCheckMarks];
}


#pragma mutiSelect

- (void)editAction
{
    [self.tableView setEditing:YES animated:YES];
    [infoLab removeFromSuperview];
    [costLab removeFromSuperview];
    btnDelete.enabled = YES;
    [self updateButtonsToMatchTableState];
}
- (void)cancelAction
{
    if(searchInv == YES){
        [self.navigationItem setRightBarButtonItem:btnEdit];
        searchInv = NO;
        searchWord = EMPTY_STRING;
        self.navigationItem.title = @"發票清單";
        [dataArray removeAllObjects];
        [self queryData:periodArr[pointer]];
        [self.tableView reloadData];
        
    }
    [self removeCheckMarks];
    [self.tableView setEditing:NO animated:YES];
    [self.toolBar addSubview:infoLab];
    [infoLab addSubview:costLab];
    btnDelete.enabled = NO;
    [self updateButtonsToMatchTableState];
}
- (IBAction)deleteAction:(id)sender {
	NSString *actionTitle;
    if (([[self.tableView indexPathsForSelectedRows] count] == 1)) {
        actionTitle = NSLocalizedString(@"你確定要刪除這張發票嗎?", @"");
    }
    else
    {
        actionTitle = NSLocalizedString(@"你確定要刪除這些發票嗎?", @"");
    }
    
    NSString *cancelTitle = NSLocalizedString(@"取消", @"Cancel title for item removal action");
    NSString *okTitle = NSLocalizedString(@"確定", @"OK title for item removal action");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionTitle
                                                             delegate:self
                                                    cancelButtonTitle:cancelTitle
                                               destructiveButtonTitle:okTitle
                                                    otherButtonTitles:nil];
    
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    
	[actionSheet showInView:self.view];
    
}

- (void)updateButtonsToMatchTableState
{
    if (self.tableView.editing)
    {
        [self.navigationItem setRightBarButtonItem:btnCancel];
        [self updateDeleteButtonTitle];
        
    }
    else
    {
        if (self.dataArray.count > 0)
        {
            self.btnEdit.enabled = YES;
        }
        else
        {
            self.btnEdit.enabled = NO;
        }
        [self.navigationItem setRightBarButtonItem:btnEdit];
    }
}
- (void)updateDeleteButtonTitle
{
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    
    BOOL allItemsAreSelected = selectedRows.count == dataArray.count;
    BOOL noItemsAreSelected = selectedRows.count == 0;
    
    if (allItemsAreSelected || noItemsAreSelected)
    {
        btnDelete.title = NSLocalizedString(@"刪除全部", @"");
    }
    else
    {
        NSString *titleFormatString =
        NSLocalizedString(@"刪除 (%d)", @"Title for delete button with placeholder for number");
        btnDelete.title = [NSString stringWithFormat:titleFormatString, selectedRows.count];
    }
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *deleteNumsString;
	if (buttonIndex == 0)
	{
        NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
        BOOL deleteSpecificRows = selectedRows.count > 0;
        if (deleteSpecificRows)
        {
            NSMutableIndexSet *indicesOfItemsToDelete = [NSMutableIndexSet new];
            for (NSIndexPath *selectionIndex in selectedRows)
            {
                invData *Data = dataArray[selectionIndex.row];
                if(deleteNumsString.length == 0)
                {
                    deleteNumsString =[ NSString stringWithFormat:@"'%@'", Data.invID];
                }
                else
                {
                    deleteNumsString = [deleteNumsString stringByAppendingString:[NSString stringWithFormat: @",'%@'",Data.invID]];
                }
                [indicesOfItemsToDelete addIndex:selectionIndex.row];
            }
            [dataArray removeObjectsAtIndexes:indicesOfItemsToDelete];
            [self deleteData:deleteNumsString];
            
            [self.tableView deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView reloadData];
        }
        else
        {
            for(invData *Data in dataArray){
                if(deleteNumsString.length == 0)
                {
                    deleteNumsString =[ NSString stringWithFormat:@"'%@'", Data.invID];
                }
                else
                {
                    deleteNumsString = [deleteNumsString stringByAppendingString:[NSString stringWithFormat: @",'%@'",Data.invID]];
                }
            }
            [self deleteData:deleteNumsString];
            [dataArray removeAllObjects];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView reloadData];
        }
        
        [self.tableView setEditing:NO animated:YES];
        [self updateButtonsToMatchTableState];
        [self removeCheckMarks];
        btnDelete.enabled = NO;
        costLab.text = [NSString stringWithFormat:@"$%d",[self totalCost]];
        [self.toolBar addSubview:infoLab];
        [infoLab addSubview:costLab];
        
	}
}
#pragma UISearchBar delegate

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    searchWord = searchText;
    [dataArray removeAllObjects];
    [self queryData:periodArr[pointer]];
    [self.tableView reloadData];
    costLab.text = [NSString stringWithFormat:@"$%d",[self totalCost]];
}
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchInv = YES;
    invSearchBar.showsCancelButton = YES;
}
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    invSearchBar.showsCancelButton = NO;
    [dataArray removeAllObjects];
    [self queryData:periodArr[pointer]];
    [self.tableView reloadData];
    costLab.text = [NSString stringWithFormat:@"$%d",[self totalCost]];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    if([periodArr count] == 0){
        return;
    }
    searchInv = NO;
    [dataArray removeAllObjects];
    [self queryData:periodArr[pointer]];
    [self.tableView reloadData];
    costLab.text = [NSString stringWithFormat:@"$%d",[self totalCost]];
    searchBar.text = @"";
    [invSearchBar resignFirstResponder];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}
-(void)searchBarChangeKey
{
    for (UIView *subview in invSearchBar.subviews)
    {
        for (UIView *subSubview in subview.subviews)
        {
            if ([subSubview conformsToProtocol:@protocol(UITextInputTraits)])
            {
                UITextField *textField = (UITextField *)subSubview;
                [textField setKeyboardAppearance: UIKeyboardAppearanceDark];
                textField.returnKeyType = UIReturnKeyDone;
                break;
            }
        }
    }
}
#pragma other methods
//取得api所需日期格式
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

-(NSString*)getPeriodStrNow
{
    NSDate *today = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:today];
    NSInteger thisYear = [components year];
    NSInteger thisMonth = [components month];
    thisYear = thisYear -1911;
    if( thisMonth%2 == 1 ){
        thisMonth += 1;
    }
    NSString *periodStr;
    if([[NSString stringWithFormat:@"%li",(long)thisMonth] length] == 1){
        periodStr = [[NSString stringWithFormat:@"%li",(long)thisYear] stringByAppendingString:[NSString stringWithFormat:@"0%li",(long)thisMonth]];
    }else{
        periodStr = [[NSString stringWithFormat:@"%li",(long)thisYear] stringByAppendingString:[NSString stringWithFormat:@"%li",(long)thisMonth]];
    }
    
    return periodStr;
}
-(void)getAllPeriodsArray
{
    [periodArr removeAllObjects];
    FMDatabase *db = [FMDatabase databaseWithPath:DB_PATH];
    if([db open]){
        NSString *sql = @"select distinct invPeriod from receipt ORDER BY invDate DESC";
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]){
            NSString *ps = [rs stringForColumn:@"invPeriod"];
            [periodArr addObject:ps];
        }
    }
    [db close];
    if([periodArr count] == 0){
        [periodArr addObject:[self getPeriodStrNow]];
    }
    pointer = [periodArr indexOfObject:[self getPeriodStrNow]];
    self.periodLab.text = [self periodStr:periodArr[0]];
    
}
-(int)totalCost
{
    int sumValue = 0;
    for(invData *data in dataArray){
        sumValue += data.invspent;
    }
    return sumValue;
}
- (IBAction)nextPeriod:(id)sender {
    if([periodArr count] <= 1){
        return;
    }
    if( pointer > 0 ){
        [self removeCheckMarks];
        self.periodLab.text = [self periodStr:periodArr[--pointer]];
        [dataArray removeAllObjects];
        [self queryData:periodArr[pointer]];
        [self.tableView reloadData];
        [self updateDeleteButtonTitle];
        btnDelete.title = @"";
        costLab.text = [NSString stringWithFormat:@"$%d",[self totalCost]];
    }else{
        
    }
    if (self.dataArray.count > 0)
    {
        self.btnEdit.enabled = YES;
    }
}
- (IBAction)previousPeriod:(id)sender {
    if([periodArr count] <= 1){
        return;
    }
    if( pointer < [periodArr count]-1 ){
        [self removeCheckMarks];
        self.periodLab.text = [self periodStr:periodArr[++pointer]];
        [dataArray removeAllObjects];
        [self queryData:periodArr[pointer]];
        [self.tableView reloadData];
        [self updateDeleteButtonTitle];
        btnDelete.title = @"";
        costLab.text = [NSString stringWithFormat:@"$%d",[self totalCost]];
    }else{
        
    }
    if (self.dataArray.count > 0)
    {
        self.btnEdit.enabled = YES;
    }
}
-(NSString*)periodStr:(NSString*)string
{
    NSDictionary *period = @{@"02":@"0102",@"04":@"0304",@"06":@"0506",@"08":@"0708",@"10":@"0910",@"12":@"1112"};
    if(string.length >= 5){
        NSString *year = [string substringToIndex:3];
        NSString *month = [string substringFromIndex:3];
        NSString *perStr = [NSString stringWithFormat:@"%@年%@期",year,period[month]];
        return perStr;
    }else{
        NSString *year = [string substringToIndex:2];
        NSString *month = [string substringFromIndex:2];
        NSString *perStr = [NSString stringWithFormat:@"%@年%@期",year,period[month]];
        return perStr;
    }

}


- (void)setupLeftMenuButton{
    MMDrawerBarButtonItem *leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    leftDrawerButton.image = [UIImage imageNamed:@"navbar_icon_menu"];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    self.mm_drawerController.openDrawerGestureModeMask = MMCloseDrawerGestureModeNone;
}
- (void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    [invSearchBar resignFirstResponder];
}

-(void)removeCheckMarks
{
    NSArray *indexArr = [self.tableView indexPathsForSelectedRows];
    for (int i = 0 ; i < [indexArr count]; i++) {
        ReceiptCell *cell = (ReceiptCell*)[self.tableView cellForRowAtIndexPath:[indexArr objectAtIndex:i]];
        cell.selected = NO;
        [cell changeSelectedMark:cell.selected];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}



@end
