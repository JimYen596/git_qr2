//
//  TutorialViewController.h
//  QrInvoice
//
//  Created by Yen on 2014/8/6.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TutorialViewController : UIViewController <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) NSArray *pageImages;
@property (strong, nonatomic) NSMutableArray *pageViews;

-(void) loadVisiblePages;
-(void) loadPage:(NSInteger)page;
-(void) purgePage:(NSInteger)page;
@end
