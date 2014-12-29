//
//  ResultViewController.m
//  QrInvoice
//
//  Created by Yen on 2014/7/16.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import "ResultViewController.h"
#import "ItemCell.h"

@interface ResultViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation ResultViewController
@synthesize gotData;
@synthesize itemDataArr;
@synthesize invNumLab,invDateLab,randNumLab,invSpentLab;
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
    self.navigationItem.title = @"發票明細";
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:248.0/255.0f green:205.0/255.0f blue:54.0/255.0f alpha:1.0]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName :[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"AmericanTypewriter" size:22.0f]}];
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navbar_icon_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(pop)];
    self.navigationItem.leftBarButtonItem = backBtn;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    //NSLog(@"gotDAta ===%@",gotData);
    //NSLog(@"invoice == %@",self.gotInv);
}
-(void)viewWillAppear:(BOOL)animated
{
    //NSLog(@"gotDAta ===%@",gotData);
    NSLog(@"invoice == %@",self.gotInv.invDate);
    
    invNumLab.text = gotData[@"invNum"];
    invDateLab.text = self.gotInv.invDate;    
    randNumLab.text = self.gotInv.randomNum;
    int allItemSpent = [self modifyCurrectSpent];
    invSpentLab.text = [NSString stringWithFormat:@"%d",allItemSpent];
}
-(void)pop
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma TableVewDataSource & Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [gotData[@"details"] count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"itemCell";
    ItemCell *cell = (ItemCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"ItemCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    cell.imageView.image = [UIImage imageNamed:@"icon_life_gary"];
    cell.itemName.text = gotData[@"details"][indexPath.row][@"description"];
    cell.cost.text = gotData[@"details"][indexPath.row][@"amount"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(int)modifyCurrectSpent
{
    NSArray *array = gotData[@"details"];
    int sum = 0;
    for(int i = 0 ; i < [array count] ; i++){
        NSString *amountStr = array[i][@"amount"];
        sum += [amountStr integerValue];
    }
    if(sum == 0){
        return 0;
    }
    return sum;
}

@end
