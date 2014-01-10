//
//  TSBadgeView.m
//  ToSavour
//
//  Created by Jason Wan on 9/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "TSBadgeView.h"

@implementation TSBadgeView

#if  __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0
#define JSBadgeViewSilenceDeprecatedMethodStart()   _Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wdeprecated-declarations\"")
#define JSBadgeViewSilenceDeprecatedMethodEnd()     _Pragma("clang diagnostic pop")
#else
#define JSBadgeViewSilenceDeprecatedMethodStart()
#define JSBadgeViewSilenceDeprecatedMethodEnd()
#endif

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (CGSize)sizeOfTextForCurrentSettings {
    JSBadgeViewSilenceDeprecatedMethodStart();
    if ([self.badgeText respondsToSelector:@selector(sizeWithAttributes:)]) {
        return [self.badgeText sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:UIFont.systemFontSize]}];
    } else {
        return [self.badgeText sizeWithFont:self.badgeTextFont];
    }
    JSBadgeViewSilenceDeprecatedMethodEnd();
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
