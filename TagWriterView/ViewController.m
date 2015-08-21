//
//  ViewController.m
//  TagWriterView
//
//  Created by huangyuan on 7/30/15.
//  Copyright (c) 2015 huangyuan. All rights reserved.
//

#import "ViewController.h"
#import "HYTagWriterView.h"
@interface ViewController () <HYTagWriterViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray * tmp = [[NSArray alloc] initWithObjects:@"1===========", @"2=========的",@"啊水电费啊安师大发生的",@"4==========的",nil];
    self.automaticallyAdjustsScrollViewInsets = NO;
    HYTagWriterView * view1 = [[HYTagWriterView alloc] initWithFrame:CGRectMake(0, 40, 320, 100)];
    view1.viewMaxHeight = 250;
    
    view1.tagBackgroundColor = [UIColor greenColor];
    view1.tagGap =15;
    view1.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor redColor];
    
    [view1 addTags:tmp];
    view1.delegate=self;
    [view1 addTagToLast:@"5============" animated:YES];
    [self.view addSubview:view1];
    NSLog(@"%@", NSStringFromCGRect(view1.inputView.frame));
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)tagWriteView:(HYTagWriterView *)view exceedMaxWdith:(BOOL)exceedMaxWdith{

    CALayer *lbl = [ view.inputView layer];
    CGPoint posLbl = [lbl position];
    CGPoint y_point = CGPointMake(posLbl.x-10, posLbl.y);
    CGPoint x_point = CGPointMake(posLbl.x+10, posLbl.y);
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setTimingFunction:[CAMediaTimingFunction
                                  functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setFromValue:[NSValue valueWithCGPoint:x_point]];
    [animation setToValue:[NSValue valueWithCGPoint:y_point]];
    [animation setAutoreverses:YES];
    [animation setDuration:0.08];
    [animation setRepeatCount:3];
    [lbl addAnimation:animation forKey:nil];

    
}
@end
