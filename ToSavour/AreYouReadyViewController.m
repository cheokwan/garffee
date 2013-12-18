//
//  AreYouReadyViewController.m
//  ToSavour
//
//  Created by LAU Leung Yan on 9/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "AreYouReadyViewController.h"

#import "TSTheming.h"

@interface AreYouReadyViewController ()
@property (nonatomic, strong) NSMutableDictionary *buttonDict;
@end

@implementation AreYouReadyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.titleView = [TSTheming navigationTitleViewWithString:LS_DAILY_AWARD_GAME];
    _areYouReadyStrLabel.text = [NSString stringWithFormat:@"%@?", LS_ARE_YOU_READY];
    _num1Button.userInteractionEnabled = NO;
    _num2Button.userInteractionEnabled = NO;
    _num3Button.userInteractionEnabled = NO;
    _num1Button.fillColor = [UIColor grayColor];
    _num2Button.fillColor = [UIColor grayColor];
    _num3Button.fillColor = [UIColor grayColor];
    [_num1Button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_num2Button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_num3Button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.buttonDict = [NSMutableDictionary dictionary];
    _buttonDict[@(3)] = _num3Button;
    _buttonDict[@(2)] = _num2Button;
    _buttonDict[@(1)] = _num1Button;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)startCountDown {
//    float interval = 0.5f;
//    [self performSelector:@selector(countDown:) withObject:@(3) afterDelay:interval];
//    interval += COUNT_DOWN_INTERVAL;
//    [self performSelector:@selector(countDown:) withObject:@(2) afterDelay:interval];
//    interval += COUNT_DOWN_INTERVAL;
//    [self performSelector:@selector(countDown:) withObject:@(1) afterDelay:interval];
//    interval += COUNT_DOWN_INTERVAL;
//    [self performSelector:@selector(proceed) withObject:nil afterDelay:interval];
}

- (void)countDown:(NSNumber *)countStr {
    for (NSString *key in _buttonDict.allKeys) {
        if ([key intValue] == [countStr intValue]) {
            ((CountDownButton *)_buttonDict[key]).fillColor = [UIColor blackColor];
            ((CountDownButton *)_buttonDict[key]).titleLabel.textColor = [UIColor whiteColor];
        } else {
            ((CountDownButton *)_buttonDict[key]).fillColor = [UIColor grayColor];
            ((CountDownButton *)_buttonDict[key]).titleLabel.textColor = [UIColor blackColor];
        }
        [(CountDownButton *)_buttonDict[key] setNeedsDisplay];
    }
}

- (void)proceed {
    [self dismissViewControllerAnimated:NO completion:nil];
    if ([_delegate respondsToSelector:@selector(areYouReadyViewControllerDidFinishCountDown:)]) {
        [_delegate areYouReadyViewControllerDidFinishCountDown:self];
    }
}

@end
