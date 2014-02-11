//
//  TSTheming.h
//  ToSavour
//
//  Created by Jason Wan on 5/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSTheming : NSObject

+ (UIViewController *)viewControllerWithStoryboardIdentifier:(NSString *)identifier;
+ (UIViewController *)viewControllerWithStoryboardIdentifier:(NSString *)identifier storyboard:(NSString *)aStoryBoard;
+ (UIView *)viewWithNibName:(NSString *)identifier;
+ (UIView *)viewWithNibName:(NSString *)identifier owner:(id)owner;
+ (NSURL *)URLWithImageAssetNamed:(NSString *)assetName;
+ (UIView *)navigationBrandNameTitleView;
+ (UIView *)navigationTitleViewWithString:(NSString *)titleString;
+ (UIView *)navigationBrandImageTitleView;

+ (UIColor *)defaultThemeColor;
+ (UIColor *)defaultAccentColor;
+ (UIColor *)defaultContrastColor;
+ (UIColor *)defaultBackgroundTransparentColor;
+ (UIColor *)defaultBadgeBackgroundColor;

@end
