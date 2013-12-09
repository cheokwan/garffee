//
//  ItemPickerTableViewCell.h
//  ToSavour
//
//  Created by Jason Wan on 7/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemPickerScrollView.h"

@interface ItemPickerTableViewCell : UITableViewCell

@property (nonatomic, strong)   IBOutlet ItemPickerScrollView *pickerScrollView;

@end
