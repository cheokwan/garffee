//
//  ItemGridView.h
//  ToSavour
//
//  Created by Jason Wan on 27/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ItemGridView;

@protocol ItemGridViewDelegate <NSObject>
- (void)itemGridViewButtonDidPressed:(ItemGridView *)itemGridView;
@end


static NSString *ItemGridViewDragTransitionNotificationStart = @"ItemGridViewDragTransitionNotificationStart";
static NSString *ItemGridViewDragTransitionNotificationStop = @"ItemGridViewDragTransitionNotificationStop";

@interface ItemGridView : UIView
@property (nonatomic, strong)   UILabel *textLabel;
@property (nonatomic, strong)   UIImageView *imageView;
@property (nonatomic, strong)   UIButton *button;

@property (nonatomic, weak)     id<ItemGridViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame text:(NSString *)text imageURL:(NSURL *)imageURL interactable:(BOOL)interactable shouldReceiveNotification:(BOOL)shouldReceiveNotification;
- (void)notificationReceived:(NSNotification *)notification;

@end

