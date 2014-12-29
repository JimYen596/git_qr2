//
//  LeftMenuViewController.m
//  QrInvoice
//
//  Created by ChaLin LEE on 2014/7/1.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "HomeViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "InvListViewController.h"
#import "InvoiceAwardViewController.h"
#import "ScanViewController.h"
#import "SettingViewController.h"

@interface LeftMenuViewController ()

@end

@implementation LeftMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            self.view.bounds = CGRectMake(0, -20, self.view.frame.size.width, self.view.frame.size.height );
        }
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    [self.view setBackgroundColor:[UIColor blackColor]];
    _menuTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [_menuTableView setBackgroundColor:[UIColor clearColor]];
    [_menuTableView setDelegate:self];
    [_menuTableView setDataSource:self];
    _menuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_menuTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.view addSubview:_menuTableView];
    
    self.menuItems = [[NSMutableArray alloc] initWithCapacity:20];
    
    [self.menuItems addObject:NSLocalizedString(@"首頁", nil)];
    [self.menuItems addObject:NSLocalizedString(@"發票清單", nil)];
    [self.menuItems addObject:NSLocalizedString(@"掃描新增", nil)];
    [self.menuItems addObject:NSLocalizedString(@"發票對獎", nil)];
    [self.menuItems addObject:NSLocalizedString(@"設定", nil)];
    
    
    UIImage *image = [UIImage imageNamed:@"icon_menu_index"];
    UIImage *image1 = [UIImage imageNamed:@"icon_menu_list"];
    UIImage *image2 = [UIImage imageNamed:@"icon_menu_screen"];
    UIImage *image3 = [UIImage imageNamed:@"icon_menu_shake"];
    UIImage *image4 = [UIImage imageNamed:@"icon_menu_settingng"];
    
    
    self.mutableArray = [[NSMutableArray alloc] initWithObjects:image,image1, image2, image3, image4, nil];
}
#pragma mark -
#pragma mark Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 90.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 5;
    
    
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellStation = @"LeftMenuCell";
    UITableViewCell *cell = (LeftMenuCell *)[tableView dequeueReusableCellWithIdentifier:cellStation];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"LeftMenuCell" owner:self options:nil] lastObject];

        cell.backgroundColor = [UIColor clearColor];
        
//        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    [((LeftMenuCell *)cell).menuImgView setImage:[self.mutableArray objectAtIndex:indexPath.row]];
    ((LeftMenuCell *)cell).menuTitleLab.text = [self.menuItems objectAtIndex:indexPath.row];
    
    return cell;
    
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
	UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 5)];
	footer.backgroundColor = [UIColor clearColor];
	return footer;
}
#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
        {
            HomeViewController *mainVC = [[HomeViewController alloc]init];
            UINavigationController *ncVC = [[UINavigationController alloc]initWithRootViewController:mainVC ];
            
            [self.mm_drawerController
             setCenterViewController:ncVC
             withCloseAnimation:YES
             completion:nil];
            
            break;
        }
        case 1:
        {
            InvListViewController *InvListVC = [[InvListViewController alloc]init];
            UINavigationController *ncVC = [[UINavigationController alloc]initWithRootViewController:InvListVC ];
            
            [self.mm_drawerController
             setCenterViewController:ncVC
             withCloseAnimation:YES
             completion:nil];

            break;
        }
        case 2:
        {
            UINavigationController *nowNC = (UINavigationController*)self.mm_drawerController.centerViewController;
            //避免重複載入相機
            if(nowNC.topViewController.class == [ScanViewController class]){
                [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
                nowNC = nil;
                break;
            }
             ScanViewController *ScanVC = [[ScanViewController alloc]init];
            UINavigationController *ncVC = [[UINavigationController alloc]initWithRootViewController:ScanVC];
            
            [self.mm_drawerController
             setCenterViewController:ncVC
             withCloseAnimation:YES
             completion:nil];
            break;
        }
        case 3:
        {
            InvoiceAwardViewController *InvoiceAwardVC = [[InvoiceAwardViewController alloc]init];
            UINavigationController *ncVC = [[UINavigationController alloc]initWithRootViewController:InvoiceAwardVC ];
            
            [self.mm_drawerController
             setCenterViewController:ncVC
             withCloseAnimation:YES
             completion:nil];
            break;
        }
        case 4:
        {
            SettingViewController *settingVC = [[SettingViewController alloc]init];
            UINavigationController *ncVC = [[UINavigationController alloc]initWithRootViewController:settingVC ];
            
            [self.mm_drawerController
             setCenterViewController:ncVC
             withCloseAnimation:YES
             completion:nil];
            break;
        }
        default:
        break;
    }
    
}

- (void) setCenterViewController:(UIViewController *)newCenterViewController withCloseAnimation:(BOOL)animated completion:(void(^)(BOOL finished))completion
{
    [self.mm_drawerController
     setCenterViewController:newCenterViewController
     withCloseAnimation:animated
     completion:completion];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
