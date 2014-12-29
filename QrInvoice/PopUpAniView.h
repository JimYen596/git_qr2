//
//  PopUpAniView.h
//  QrInvoice
//
//  Created by ChaLin LEE on 2014/7/8.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//
@class PopUpAniView;

@protocol PopUpAniViewDelegate <NSObject>

@optional

- (void)popUpAniViewCancel:(PopUpAniView *)popUpAniView;

@end

#define POP_UP_ANI_VIEW_TIME_OUT 30

#import <UIKit/UIKit.h>
#import "PulsingHaloLayer.h"

@interface PopUpAniView : UIView{
    
    id<PopUpAniViewDelegate>   delegate;
    BOOL isRunning;
}
@property (nonatomic, assign) id<PopUpAniViewDelegate>   delegate;
@property (nonatomic, strong) PulsingHaloLayer *halo;
@property (weak, nonatomic) IBOutlet UIImageView *centerImgView;

//- (void)setImage:(NSString *)imageName;
//- (void)setTip:(NSString *)tip;
- (void)dismiss;
+(PopUpAniView *)view;
- (void)pulsingHalo;

@end
