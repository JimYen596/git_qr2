//
//  TutorialViewController.m
//  QrInvoice
//
//  Created by Yen on 2014/8/6.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import "TutorialViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"

@interface TutorialViewController ()
{
    NSInteger currentIndex;
    CGSize screenSize;
}
@end

@implementation TutorialViewController
@synthesize scrollView;
@synthesize pageControl;
@synthesize pageImages,pageViews;
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
    screenSize = [[UIScreen mainScreen] bounds].size;
    self.mm_drawerController.openDrawerGestureModeMask = MMDrawerOpenCenterInteractionModeNone;
    scrollView.delegate = self;
    [scrollView setPagingEnabled:YES];
    CGRect fullScreenBounds = [[UIScreen mainScreen] bounds];
    if((int)fullScreenBounds.size.height == 480){
        pageImages = @[[UIImage imageNamed:@"tutorial01_i4"],[UIImage imageNamed:@"tutorial02_i4"],[UIImage imageNamed:@"tutorial03_i4"],[UIImage imageNamed:@"tutorial04_i4"]];
    }else{
        pageImages = @[[UIImage imageNamed:@"tutorial01_i5"],[UIImage imageNamed:@"tutorial02_i5"],[UIImage imageNamed:@"tutorial03_i5"],[UIImage imageNamed:@"tutorial04_i5"]];
    }
    NSInteger pageCount = pageImages.count;
    pageControl.currentPage = 0;
    pageControl.numberOfPages = pageCount;
    currentIndex = 0;
    
    pageViews = [[NSMutableArray alloc]init];
    for(NSInteger i = 0 ; i < pageCount ; i++){
        [pageViews addObject:[NSNull null]];
    }
    [self.view bringSubviewToFront:pageControl];
}
-(void)viewWillAppear:(BOOL)animated
{
    [self setupFrame];
    CGSize pageScrollSize = scrollView.frame.size;
    scrollView.contentSize = CGSizeMake(pageScrollSize.width * pageImages.count, pageScrollSize.height);
    [self loadVisiblePages];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self loadVisiblePages];
}
-(void) loadVisiblePages
{
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger page = (NSInteger)floor((scrollView.contentOffset.x *2.0f +pageWidth)/(pageWidth *2.0f));
    currentIndex = page;
    pageControl.currentPage = page;
    NSInteger firstPage = page - 1;
    NSInteger lastPage = page +1;
    if(pageControl.currentPage == pageImages.count -1 ){
        lastPage = page;
    }
    if(firstPage == pageImages.count - 1){
        return;
    }
    for(NSInteger i = 0 ; i < firstPage ; i++){
        [self purgePage:i];
    }
    for(NSInteger i = firstPage ; i <= lastPage ; i++){
        [self loadPage:i];
    }
    for(NSInteger i = lastPage+1 ; i < pageImages.count ; i++){
        [self purgePage:i];
    }
    
}
-(void) loadPage:(NSInteger)page
{
    if(page < 0 || page > pageImages.count){
        return;
    }
    
    UIView *pageView = [pageViews objectAtIndex:page];
    if((NSNull*)pageView == [NSNull null]){
        CGRect pageFrame = scrollView.bounds;
        pageFrame.origin.x = pageFrame.size.width * page;
        if(screenSize.height == 568){
            pageFrame.origin.y = 0.0f;
        }else{
            pageFrame.origin.y = 0.0f;
        }
        
        UIImageView *pageImageView = [[UIImageView alloc]initWithImage:[pageImages objectAtIndex:page]];
        pageImageView.contentMode = UIViewContentModeScaleToFill;
        pageImageView.userInteractionEnabled = YES;

        [pageImageView setFrame:pageFrame];
        
        UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [menuBtn setFrame:CGRectMake(10, 10, 44, 44)];
        [menuBtn setImage:[UIImage imageNamed:@"navbar_icon_menu"] forState:UIControlStateNormal];
        [menuBtn addTarget:self action:@selector(leftDrawerButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        [pageImageView addSubview:menuBtn];
        [scrollView addSubview:pageImageView];
        
        [pageViews replaceObjectAtIndex:page withObject:pageImageView];
    }
}
-(void) purgePage:(NSInteger)page
{
    if(page < 0 || page > pageImages.count){
        return;
    }
    UIView *pageView = [pageViews objectAtIndex:page];
    if((NSNull*)pageView != [NSNull null]){
        [pageView removeFromSuperview];
        [pageViews replaceObjectAtIndex:page withObject:[NSNull null]];
    }
}

- (void)setupLeftMenuButton{
    for(int i = 0 ; i < pageImages.count ; i++){
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(10 + scrollView.contentSize.width / pageImages.count * i, 10, 50, 50)];
        btn.backgroundColor = [UIColor blackColor];
        btn.imageView.image = [UIImage imageNamed:@"navbar_icon_menu"];
        [btn addTarget:self action:@selector(leftDrawerButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:btn];
        [scrollView bringSubviewToFront:btn];
    }
}
- (void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)setupFrame
{
    if(screenSize.height == 480){
        NSLog(@"x == %f",scrollView.frame.origin.x);
        NSLog(@"y == %f",scrollView.frame.origin.y);
        NSLog(@"w == %f",scrollView.frame.size.width);
        NSLog(@"h == %f",scrollView.frame.size.height);
        [scrollView setFrame:CGRectMake(0, 0, 320, 480)];
        [pageControl setFrame:CGRectMake(0, 0, pageControl.frame.size.width, pageControl.frame.size.height)];
    }
    if (screenSize.height == 568) {
        NSLog(@"x == %f",scrollView.frame.origin.x);
        NSLog(@"y == %f",scrollView.frame.origin.y);
        NSLog(@"w == %f",scrollView.frame.size.width);
        NSLog(@"h == %f",scrollView.frame.size.height);
    }
}
@end
