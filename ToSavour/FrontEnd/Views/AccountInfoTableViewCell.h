//
//  AccountInfoTableViewCell.h
//  ToSavour
//
//  Created by Jason Wan on 14/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountInfoTableViewCell : UITableViewCell

@property (nonatomic, strong)   IBOutlet UIImageView *imageView;
@property (nonatomic, strong)   IBOutlet UILabel *titleLabel;
@property (nonatomic, strong)   IBOutlet UIView *customView;

@end
