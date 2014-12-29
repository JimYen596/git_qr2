//
//  PopUpAniView.m
//  QrInvoice
//
//  Created by ChaLin LEE on 2014/7/8.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import "PopUpAniView.h"
#import "PulsingHaloLayer.h"
#import <QuartzCore/QuartzCore.h>
@interface PopUpAniView ()

@end
@implementation PopUpAniView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

+(PopUpAniView *)view
{
    return ( PopUpAniView *)[[[NSBundle mainBundle] loadNibNamed:@"PopUpAniView" owner:nil options:nil]objectAtIndex:0];
}

- (void)pulsingHalo
{
    isRunning = YES;
    self.halo = [PulsingHaloLayer layer];
    self.halo.position = self.centerImgView.center;

    [self.layer insertSublayer:self.halo below:self.centerImgView.layer];
    [self performSelector:@selector(timeout) withObject:nil afterDelay:POP_UP_ANI_VIEW_TIME_OUT];
}

- (void)fadeOut
{
    [UIView animateWithDuration:.35 animations:^{
//        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self.halo removeFromSuperlayer];
            [self removeFromSuperview];
        }
    }];
}

- (void)dismiss
{
    if (isRunning) {
        isRunning = NO;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(popUpAniViewCancel:)]) {
            [self.delegate popUpAniViewCancel:self];
        }
        
        [self fadeOut];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // tell the delegate the cancellation
    
    // dismiss self
//    NSLog(@"12345");
    [self dismiss];
}

- (void) timeout
{
    debugLog(@"timeout");
    
    [self dismiss];
}

@end
