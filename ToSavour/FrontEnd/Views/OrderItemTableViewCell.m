//
//  OrderItemTableViewCell.m
//  ToSavour
//
//  Created by Jason Wan on 17/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "OrderItemTableViewCell.h"
#import "TSFrontEndIncludes.h"
#import "MProductInfo.h"

@interface OrderItemTableViewCell()
@property (nonatomic, assign) UITableViewCellStateMask currentState;
@property (nonatomic, assign) BOOL isKeyboardShowing;
@end

@implementation OrderItemTableViewCell

static UIEdgeInsets tableViewContentInsets;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureWithItem:(MItemInfo *)item {
    self.item = item;
    
    __weak OrderItemTableViewCell *weakSelf = self;
    [self.itemImageView setImageWithURL:item.product.URLForImageRepresentation placeholderImage:nil options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        if (image) {
            weakSelf.itemImageView.image = [image resizedImageToSize:weakSelf.itemImageView.frame.size];
        } else {
            DDLogWarn(@"cannot set image for item: %@ - error %@", weakSelf.itemNameLabel.text, error);
        }
    }];
    
    self.itemNameLabel.text = item.product.name;
    self.itemDetailsLabel.text = item.detailString;
    [self updateQuantity:[item.quantity intValue]];
    
    self.quantityTextField.alpha = 0.0;
    self.quantityTextField.delegate = self;
    self.quantityTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    self.keyboardBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.bounds.size.width, 44.0)];
    _keyboardBar.backgroundColor = [TSTheming defaultBackgroundTransparentColor];
    self.keyboardDoneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(buttonPressed:)];
    _keyboardDoneButton.tintColor = [TSTheming defaultThemeColor];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [self.keyboardBar setItems:@[flexibleSpace, _keyboardDoneButton]];
    
    self.quantityTextField.inputAccessoryView = self.keyboardBar;
}

- (void)updateQuantity:(NSInteger)quantity {
    self.item.quantity = @(quantity);
    self.quantityLabel.text = [NSString stringWithFormat:@"%@: %d", LS_QUANTITY, [_item.quantity intValue]];
    self.quantityTextField.text = [_item.quantity stringValue];
    self.priceLabel.text = [NSString stringWithPrice:[_item.price floatValue] showFree:YES];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.currentState & UITableViewCellStateShowingEditControlMask
        && self.isEditing) {
        [UIView animateWithDuration:0.2 animations:^{
            self.priceLabel.alpha = 0.0;
            self.quantityTextField.alpha = 1.0;
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.quantityTextField.alpha = 0.0;
            self.priceLabel.alpha = 1.0;
        }];
    }
}

- (void)willTransitionToState:(UITableViewCellStateMask)state {
    [super willTransitionToState:state];
    self.currentState = state;
    if (self.currentState == UITableViewCellStateDefaultMask && self.isKeyboardShowing) {
        [self commitEditAndReturn];
    }
    [self setNeedsLayout];
}

- (void)buttonPressed:(id)sender {
    if (sender == _keyboardDoneButton) {
        [self commitEditAndReturn];
    }
}

- (void)dealloc {
    [self deregisterKeyboardNotifications];
}

#pragma mark - UIKeyboardNotifications related

- (void)registerKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)deregisterKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    self.isKeyboardShowing = YES;
    
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    if ([self.superview.superview isKindOfClass:UITableView.class]) {
        UITableView *tableView = (UITableView *)self.superview.superview;
        
        if (UIEdgeInsetsEqualToEdgeInsets(tableViewContentInsets, UIEdgeInsetsZero)) {
            // if never cached the parent tableview's inset, do it now
            tableViewContentInsets = tableView.contentInset;
        }
        UIEdgeInsets newContentInsets = tableViewContentInsets;
        newContentInsets.bottom += keyboardSize.height - 49.0;  // minus the tab bar height
        
        [UIView animateWithDuration:0.5 animations:^{
            tableView.contentInset = newContentInsets;
            tableView.scrollIndicatorInsets = newContentInsets;
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if ([self.superview.superview isKindOfClass:UITableView.class]) {
        UITableView *tableView = (UITableView *)self.superview.superview;
        
        if (!UIEdgeInsetsEqualToEdgeInsets(tableViewContentInsets, UIEdgeInsetsZero)) {
            // if there's cached parent tableview's inset, restore it
            [UIView animateWithDuration:0.5 animations:^{
                tableView.contentInset = tableViewContentInsets;
                tableView.scrollIndicatorInsets = tableViewContentInsets;
            }];
        }
        tableViewContentInsets = UIEdgeInsetsZero;
    }
    [self deregisterKeyboardNotifications];
    self.isKeyboardShowing = NO;
}

#pragma mark - UITextFieldDelegate

- (void)commitEditAndReturn {
    if (_quantityTextField.text.length > 0) {
        [self updateQuantity:[self.quantityTextField.text intValue]];
        if ([_delegate respondsToSelector:@selector(orderItemTableViewCell:didEditOrderItem:)]) {
            [_delegate orderItemTableViewCell:self didEditOrderItem:_item];
        }
    } else {
        _quantityTextField.text = [_item.quantity stringValue];
    }
    [_quantityTextField resignFirstResponder];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (!self.showingDeleteConfirmation) {
        [self registerKeyboardNotifications];
        return YES;
    }
    return NO;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^([1-9][0-9]{0,1})?$" options:0 error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:newString options:0 range:NSMakeRange(0, newString.length)];
    return match != nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self commitEditAndReturn];
    return NO;
}


@end
