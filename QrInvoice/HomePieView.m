//
//  HomePieView.m
//  QrInvoice
//
//  Created by ChaLin LEE on 2014/7/2.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import "HomePieView.h"
#import "MagicPieLayer.h"

@interface HomePieView ()
{
    float sum;
}
@end

@implementation HomePieView

+ (Class)layerClass
{
    return [PieLayer class];
}

- (id)init
{
    self = [super init];
    if(self){
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self setup];
    }
    return self;
}

- (void)setup
{
    CGRect fullScreenBounds = [[UIScreen mainScreen] bounds];
    if((int)fullScreenBounds.size.height == 480){
        self.layer.maxRadius = 64;
        self.layer.minRadius = 45;
        self.layer.animationDuration = 0.6;
        self.layer.showTitles = ShowTitlesIfEnable;
        
        [self setFrame:CGRectMake(-20 , self.frame.origin.y+10, self.frame.size.width, self.frame.size.height)];
//        NSLog(@"x == %f",self.frame.origin.x);
//        NSLog(@"w == %f",self.frame.size.width);
        
        if ([self.layer.self respondsToSelector:@selector(setContentsScale:)])
        {
            self.layer.contentsScale = [[UIScreen mainScreen] scale];
        }

    }else{
        self.layer.maxRadius = 90;
        self.layer.minRadius = 65;
        self.layer.animationDuration = 0.6;
        self.layer.showTitles = ShowTitlesIfEnable;
        
        if ([self.layer.self respondsToSelector:@selector(setContentsScale:)])
        {
            self.layer.contentsScale = [[UIScreen mainScreen] scale];
        }
    }
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tap];
}

- (void)handleTap:(UITapGestureRecognizer*)tap
{
    CGRect fullScreenBounds = [[UIScreen mainScreen] bounds];
    sum = 0;
    if(tap.state != UIGestureRecognizerStateEnded)
        return;
    
    CGPoint pos = [tap locationInView:tap.view];
    PieElement* tappedElem = [self.layer pieElemInPoint:pos];
    if(tappedElem && _elemTapped)
        _elemTapped(tappedElem);

    if(!tappedElem)
        return;
    
    if(tappedElem.centrOffset > 0)
        tappedElem = nil;
    for(PieElement *elem in self.layer.values){
        sum += elem.val;
    }
    [PieElement animateChanges:^{
        for(PieElement* elem in self.layer.values){
            if(elem.val == sum){
                return ;
            }else{
                if(fullScreenBounds.size.height !=480){
                    elem.centrOffset = tappedElem==elem? 15 : 0;
                }else{
                    elem.centrOffset = tappedElem==elem? 5 : 0;
                }
                
            }
        }
    }];
}
@end
