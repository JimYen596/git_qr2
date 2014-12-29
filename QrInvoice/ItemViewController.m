//
//  ItemViewController.m
//  QrInvoice
//
//  Created by Yen on 2014/7/2.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import "ItemViewController.h"

@interface ItemViewController ()<UITextFieldDelegate>
{
    NSInteger typeIndex;
    NSString *curBtnName;
}
@property (strong, nonatomic) IBOutlet UIButton *btnFood;
@property (strong, nonatomic) IBOutlet UIButton *btnCloth;
@property (strong, nonatomic) IBOutlet UIButton *btnLive;
@property (strong, nonatomic) IBOutlet UIButton *btnTraffic;
@property (strong, nonatomic) IBOutlet UIButton *btnEdg;
@property (strong, nonatomic) IBOutlet UIButton *btnFun;
@property (weak, nonatomic) IBOutlet UIButton *btnOther;
@property (weak,nonatomic) UIButton *currentBtn;

@end

@implementation ItemViewController
@synthesize itemName;
@synthesize quantity;
@synthesize amount;
@synthesize unitPrice;
@synthesize gotItem;
@synthesize isNew;
@synthesize invNumStr;
@synthesize btnCloth,btnEdg,btnFood,btnFun,btnLive,btnTraffic,btnOther;
@synthesize currentBtn;

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
    self.edgesForExtendedLayout = UIRectEdgeNone;
    typeIndex = 7;
    if(isNew == 0){
        itemName.text = gotItem.description;
        unitPrice.text = gotItem.unitPrice;
        quantity.text = gotItem.quantity;
        amount.text = [NSString stringWithFormat:@"$%d",[gotItem.amount intValue]];
        typeIndex = gotItem.productType;
    }
    [self updateSegBtn];
    if(isNew == 1){
        UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navbar_icon_edit"] style:UIBarButtonItemStyleBordered target:self action:@selector(saveAction)];
        self.navigationItem.rightBarButtonItem = saveBtn;
    }
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navbar_icon_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(pop)];
    self.navigationItem.leftBarButtonItem = backBtn;
    [unitPrice addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    [quantity addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    unitPrice.delegate = self;
    quantity.delegate = self;
    [btnFood addTarget:self action:@selector(foodBtnPress) forControlEvents:UIControlEventTouchUpInside];
    [btnCloth addTarget:self action:@selector(clothBtnPress) forControlEvents:UIControlEventTouchUpInside];
    [btnLive addTarget:self action:@selector(liveBtnPress) forControlEvents:UIControlEventTouchUpInside];
    [btnTraffic addTarget:self action:@selector(trafficBtnPress) forControlEvents:UIControlEventTouchUpInside];
    [btnEdg addTarget:self action:@selector(edgBtnPress) forControlEvents:UIControlEventTouchUpInside];
    [btnFun addTarget:self action:@selector(funBtnPress) forControlEvents:UIControlEventTouchUpInside];
    [btnOther addTarget:self action:@selector(otherBtnPress) forControlEvents:UIControlEventTouchUpInside];
    NSLog(@"%@",self.gotData.invID);
    //itemName.rightViewMode = UITextFieldViewModeAlways;
}
-(void)pop
{
    if(isNew == 0){
        [self saveAction];
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
     }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
//- (IBAction)addQuantity:(id)sender {
//    quantity.text = [NSString stringWithFormat:@"%d",[quantity.text intValue]+1];
//    [self textFieldDidChange];
//}
//- (IBAction)decQuantity:(id)sender {
//    if([quantity.text intValue] > 0){
//        quantity.text = [NSString stringWithFormat:@"%d",[quantity.text intValue]-1];
//    }
//    [self textFieldDidChange];
//}
- (void)saveAction
{
    FMDatabase *db = [FMDatabase databaseWithPath:DB_PATH];
    if([db open]){
        if(isNew == 1){
            
            NSString * sql = @"insert into Details(invID,invNum, description, quantity, unitPrice, amount, productType) values(?,?,?,?,?,?,?)";
            BOOL res = [db executeUpdate:sql,self.gotData.invID,invNumStr,itemName.text,quantity.text,unitPrice.text,amount.text,@(typeIndex)];
            if (!res) {
                debugLog(@"error to insert data");
            } else {
                debugLog(@"succ to insert data");
            }
        }else{
            //NSString *amountString = [[amount.text componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]]componentsJoinedByString:@""];
            NSString *amountString = [amount.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
            NSString * sql = [NSString stringWithFormat:@"update Details set description='%@', quantity='%@', unitPrice='%@', amount='%@', productType=%ld WHERE id = %d",itemName.text,quantity.text,unitPrice.text,amountString,(long)typeIndex,gotItem.itemID];
            BOOL res = [db executeUpdate:sql];
            if (!res) {
                debugLog(@"error to update data");
            } else {
                debugLog(@"succ to update data");
            }
        }
    }
    [db close];
    [self.navigationController popViewControllerAnimated:YES];
    
}
-(void)textFieldDidChange
{
    int quan = [quantity.text intValue];
    int price = [unitPrice.text intValue];
    int sum = quan * price;
    amount.text = [NSString stringWithFormat:@"%d",sum];
}
-(void)foodBtnPress
{
    if(typeIndex != 7){
        [currentBtn setImage:[UIImage imageNamed:curBtnName] forState:UIControlStateNormal];
    }
    typeIndex = 1;
    [btnFood setImage:[UIImage imageNamed:@"btn_life01"] forState:UIControlStateNormal];
    curBtnName = @"btn_life01_dis";
    currentBtn = btnFood;
}
-(void)clothBtnPress
{
    if(typeIndex != 7){
        [currentBtn setImage:[UIImage imageNamed:curBtnName] forState:UIControlStateNormal];
    }
    typeIndex = 2;
    [btnCloth setImage:[UIImage imageNamed:@"btn_life02"] forState:UIControlStateNormal];
    curBtnName = @"btn_life02_dis";
    currentBtn = btnCloth;
}
-(void)liveBtnPress
{
    if(typeIndex != 7){
        [currentBtn setImage:[UIImage imageNamed:curBtnName] forState:UIControlStateNormal];
    }
    typeIndex = 3;
    [btnLive setImage:[UIImage imageNamed:@"btn_life03"] forState:UIControlStateNormal];
    curBtnName = @"btn_life03_dis";
    currentBtn = btnLive;
}
-(void)trafficBtnPress
{
    if(typeIndex != 7){
        [currentBtn setImage:[UIImage imageNamed:curBtnName] forState:UIControlStateNormal];
    }
    typeIndex = 4;
    [btnTraffic setImage:[UIImage imageNamed:@"btn_life04"] forState:UIControlStateNormal];
    curBtnName = @"btn_life04_dis";
    currentBtn = btnTraffic;
}
-(void)edgBtnPress
{
    if(typeIndex != 7){
        [currentBtn setImage:[UIImage imageNamed:curBtnName] forState:UIControlStateNormal];
    }
    typeIndex = 5;
    [btnEdg setImage:[UIImage imageNamed:@"btn_life05"] forState:UIControlStateNormal];
    curBtnName = @"btn_life05_dis";
    currentBtn = btnEdg;
}
-(void)funBtnPress
{
    if(typeIndex != 7){
        [currentBtn setImage:[UIImage imageNamed:curBtnName] forState:UIControlStateNormal];
    }
    typeIndex = 6;
    [btnFun setImage:[UIImage imageNamed:@"btn_life06"] forState:UIControlStateNormal];
    curBtnName = @"btn_life06_dis";
    currentBtn = btnFun;
}
-(void)otherBtnPress
{
    if(typeIndex != 7){
        [currentBtn setImage:[UIImage imageNamed:curBtnName] forState:UIControlStateNormal];
    }
    typeIndex = 0;
    [btnOther setImage:[UIImage imageNamed:@"btn_life00"] forState:UIControlStateNormal];
    curBtnName = @"btn_life00_dis";
    currentBtn = btnOther;
}
-(void)updateSegBtn
{
    switch (typeIndex) {
        case 0:
            [btnOther setImage:[UIImage imageNamed:@"btn_life00"] forState:UIControlStateNormal];
            curBtnName = @"btn_life00_dis";
            currentBtn = btnOther;
            break;
        case 1:
            [btnFood setImage:[UIImage imageNamed:@"btn_life01"] forState:UIControlStateNormal];
            curBtnName = @"btn_life01_dis";
            currentBtn = btnFood;
            break;
        case 2:
            [btnCloth setImage:[UIImage imageNamed:@"btn_life02"] forState:UIControlStateNormal];
            curBtnName = @"btn_life02_dis";
            currentBtn = btnCloth;
            break;
        case 3:
            [btnLive setImage:[UIImage imageNamed:@"btn_life03"] forState:UIControlStateNormal];
            curBtnName = @"btn_life03_dis";
            currentBtn = btnLive;
            break;
        case 4:
            [btnTraffic setImage:[UIImage imageNamed:@"btn_life04"] forState:UIControlStateNormal];
            curBtnName = @"btn_life04_dis";
            currentBtn = btnTraffic;
            break;
        case 5:
            [btnEdg setImage:[UIImage imageNamed:@"btn_life05"] forState:UIControlStateNormal];
            curBtnName = @"btn_life05_dis";
            currentBtn = btnEdg;
            break;
        case 6:
            [btnFun setImage:[UIImage imageNamed:@"btn_life06"] forState:UIControlStateNormal];
            curBtnName = @"btn_life06_dis";
            currentBtn = btnFun;
            break;
        default:
            break;
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
