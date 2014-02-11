//
//  TSTheming.m
//  ToSavour
//
//  Created by Jason Wan on 5/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "TSTheming.h"
#import "TSFrontEndIncludes.h"

@implementation TSTheming

+ (UIViewController *)viewControllerWithStoryboardIdentifier:(NSString *)identifier {
    UIStoryboard *storyBoard = nil;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    } else {
        NSString *errorMessage = @"iPad is not supported currently";
        DDLogError(@"%@", errorMessage);
        NSAssert(NO, @"%s - %@", __FUNCTION__, errorMessage);
    }
    UIViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:identifier];
    return viewController;
}

+ (UIViewController *)viewControllerWithStoryboardIdentifier:(NSString *)identifier storyboard:(NSString *)aStoryBoard {
    UIStoryboard *storyBoard = nil;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        storyBoard = [UIStoryboard storyboardWithName:aStoryBoard bundle:nil];
    } else {
        NSString *errorMessage = @"iPad is not supported currently";
        DDLogError(@"%@", errorMessage);
        NSAssert(NO, @"%s - %@", __FUNCTION__, errorMessage);
    }
    UIViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:identifier];
    return viewController;
}

+ (UIView *)viewWithNibName:(NSString *)identifier {
    return [self viewWithNibName:identifier owner:nil];
}

+ (UIView *)viewWithNibName:(NSString *)identifier owner:(id)owner {
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:identifier owner:owner options:nil];
    return views.count > 0 ? views[0] : nil;
}

+ (NSURL *)URLWithImageAssetNamed:(NSString *)assetName {
    NSString *assetPath = [[NSBundle mainBundle] pathForResource:assetName ofType:@"png"];
    return assetPath ? [NSURL fileURLWithPath:assetPath] : nil;
}

+ (UIColor *)defaultThemeColor {
//    return [UIColor colorWithHexString:@"E74C3C"];  // alizarin red
    return [UIColor colorWithHexString:@"D41325"];
}

+ (UIColor *)defaultAccentColor {
    return [UIColor whiteColor];
}

+ (UIColor *)defaultContrastColor {
    return [UIColor blackColor];
}

+ (UIColor *)defaultBackgroundTransparentColor {
    return [UIColor colorWithHexString:@"EEF1F1F1"];
}

+ (UIColor *)defaultBadgeBackgroundColor {
    return [UIColor colorWithHexString:@"FF3B30"];
}

+ (UIView *)navigationBrandNameTitleView {
    return [TSTheming navigationTitleViewWithString:BRAND_NAME];
}

+ (UIView *)navigationBrandImageTitleView {
    UIImageView *titleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 36.0)];
    titleImageView.contentMode = UIViewContentModeScaleAspectFit;
    titleImageView.image = [UIImage imageNamed:@"logo_title"];
    return titleImageView;
}

+ (UIView *)navigationTitleViewWithString:(NSString *)titleString {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = titleString;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [TSTheming defaultAccentColor];
//    titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    titleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleLabel sizeToFit];
    return titleLabel;
}

@end
