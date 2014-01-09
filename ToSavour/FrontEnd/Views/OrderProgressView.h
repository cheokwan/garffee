//
//  OrderProgressView.h
//  ToSavour
//
//  Created by Jason Wan on 8/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderProgressView : UIView

@property (nonatomic, strong)   UILabel *pendingLabel;
@property (nonatomic, strong)   UILabel *inProgressLabel;
@property (nonatomic, strong)   UILabel *finishedLabel;

- (void)updateStatus:(NSString *)newStatus;

@end
