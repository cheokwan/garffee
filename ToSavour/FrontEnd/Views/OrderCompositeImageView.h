//
//  OrderCompositeImageView.h
//  ToSavour
//
//  Created by Jason Wan on 28/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOrderInfo.h"

@interface OrderCompositeImageView : UIImageView

@property (nonatomic, strong)   MOrderInfo *order;

- (id)initWithFrame:(CGRect)frame order:(MOrderInfo *)order;

@end
