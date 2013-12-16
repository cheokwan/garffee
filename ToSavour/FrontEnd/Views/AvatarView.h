//
//  AvatarView.h
//  ToSavour
//
//  Created by Jason Wan on 13/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AvatarView;

@protocol AvatarViewDelegate <NSObject>
- (void)avatarButtonPressedInAvatarView:(AvatarView *)avatarView;
- (void)accessoryButtonPressedInAvatarView:(AvatarView *)avatarView;
@end

@interface AvatarView : UIView

@property (nonatomic, strong)   UIButton *avatarButton;
@property (nonatomic, strong)   UIButton *accessoryButton;
@property (nonatomic, strong)   NSURL *avatarImageURL;
@property (nonatomic, strong)   NSURL *accessoryImageURL;
@property (nonatomic, assign)   BOOL isInteractable;
@property (nonatomic, weak)     id<AvatarViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame avatarImageURL:(NSURL *)avatarImageURL accessoryImageURL:(NSURL *)accessoryImageURL interactable:(BOOL)interactable;

@end
