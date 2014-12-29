//
//  HomePieView.h
//  QrInvoice
//
//  Created by ChaLin LEE on 2014/7/2.
//  Copyright (c) 2014年 ChaLin LEE. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PieLayer , PieElement;

@interface HomePieView : UIView
@property (nonatomic, copy) void(^elemTapped)(PieElement*);
@end

@interface HomePieView (ex)
@property(nonatomic,readonly,retain) PieLayer *layer;
@end

