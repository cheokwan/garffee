//
//  OrderProgressView.m
//  ToSavour
//
//  Created by Jason Wan on 8/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "OrderProgressView.h"
#import "TSFrontEndIncludes.h"
#import "MOrderInfo.h"

@implementation OrderProgressView

- (void)initialize {
    static const CGFloat separatorWidth = 20.0;
    CGFloat maxLabelWidth = (self.frame.size.width - (separatorWidth * 2)) / 3.0;
    CGSize maxLabelSize = CGSizeMake(maxLabelWidth, self.frame.size.height);
    
    CGSize expectedPendingLabelSize = [LS_PENDING sizeWithFont:[UIFont systemFontOfSize:13.0] constrainedToSize:maxLabelSize lineBreakMode:NSLineBreakByWordWrapping];
    CGSize expectedInProgressLabelSize = [LS_IN_PROGRESS sizeWithFont:[UIFont systemFontOfSize:13.0] constrainedToSize:maxLabelSize lineBreakMode:NSLineBreakByWordWrapping];
    CGSize expectedFinishedLabelSize = [LS_FINISHED sizeWithFont:[UIFont systemFontOfSize:13.0] constrainedToSize:maxLabelSize lineBreakMode:NSLineBreakByWordWrapping];
    
    self.pendingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, expectedPendingLabelSize.width, expectedPendingLabelSize.height)];
    self.inProgressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, expectedInProgressLabelSize.width, expectedInProgressLabelSize.height)];
    self.finishedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, expectedFinishedLabelSize.width, expectedFinishedLabelSize.height)];
    
    _pendingLabel.text = LS_PENDING;
    _inProgressLabel.text = LS_IN_PROGRESS;
    _finishedLabel.text = LS_FINISHED;
    
    _pendingLabel.font = [UIFont systemFontOfSize:13.0];
    _inProgressLabel.font = [UIFont systemFontOfSize:13.0];
    _finishedLabel.font = [UIFont systemFontOfSize:13.0];
    
    _pendingLabel.center = CGPointMake(maxLabelWidth / 2.0, self.frame.size.height / 2.0);
    _inProgressLabel.center = CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0);
    _finishedLabel.center = CGPointMake(self.frame.size.width - (maxLabelWidth / 2.0), self.frame.size.height / 2.0);
    
    _pendingLabel.textColor = [UIColor grayColor];
    _inProgressLabel.textColor = [UIColor grayColor];
    _finishedLabel.textColor = [UIColor grayColor];
    
    [self addSubview:_pendingLabel];
    [self addSubview:_inProgressLabel];
    [self addSubview:_finishedLabel];
    
    self.backgroundColor = [UIColor colorWithHexString:@"EEEEEE"];  // TODO: why is the gray background disappear when tapped on
    self.layer.cornerRadius = 3.5;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)updateStatus:(NSString *)newStatus {
    _pendingLabel.textColor = [UIColor grayColor];
    _inProgressLabel.textColor = [UIColor grayColor];
    _finishedLabel.textColor = [UIColor grayColor];
    if ([newStatus isCaseInsensitiveEqual:MOrderInfoStatusPending]) {
        _pendingLabel.textColor = [TSTheming defaultThemeColor];
    } else if ([newStatus isCaseInsensitiveEqual:MOrderInfoStatusInProgress]) {
        _inProgressLabel.textColor = [TSTheming defaultThemeColor];
    } else if ([newStatus isCaseInsensitiveEqual:MOrderInfoStatusFinished]) {
        _finishedLabel.textColor = [TSTheming defaultThemeColor];
    }
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
