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
@property (nonatomic, strong) HYTagWriterView *view1;
@property (nonatomic, strong) HYTagWriterView *view2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSArray * tmp = [[NSArray alloc] initWithObjects:@"1===========", @"2=========的",@"啊水电费啊安师大发生的",@"4==========的",nil];
    NSArray * tmp2 = [[NSArray alloc] initWithObjects:@"1===========",nil];

    self.automaticallyAdjustsScrollViewInsets = NO;
    _view1 = [[HYTagWriterView alloc] initWithFrame:CGRectMake(0, 40, 320, 100)];
    _view1.viewMaxHeight = 250;
    
    _view1.tagBackgroundColor = [UIColor redColor];
    _view1.tagForegroundColor = [UIColor redColor];
    _view1.tagGap =15;
    _view1.backgroundColor = [UIColor whiteColor];
    _view1.scrollView.backgroundColor = [UIColor greenColor];
    self.view.backgroundColor = [UIColor grayColor];
    
    [_view1 addTags:tmp2];
    _view1.delegate=self;
    [self.view addSubview:_view1];
    NSLog(@"%@", NSStringFromCGRect(_view1.inputView.frame));
    
    _view2 = [[HYTagWriterView alloc] initWithFrame:CGRectMake(0, 250, 320, 250)];
    _view2.tagGap = 15.0f;
    _view2.delegate = self;
    _view2.tagBackgroundColor = [UIColor lightGrayColor];
    _view2.tagForegroundColor = [UIColor lightGrayColor];

    _view2.inputView.hidden = YES;
    _view2.inputView.userInteractionEnabled = NO;
    _view2.deleteButton.enabled = NO;
    _view2.deleteHiden = YES;
    [_view2 addTags:tmp];
    _view2.backgroundColor = [UIColor greenColor];
    _view2.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:_view2];
    
    

    
    
    [_view1 addTagToLast:@"5============" animated:YES];

    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//Mark:- HYTagWriterView delegate
- (void)tagWriteView:(HYTagWriterView *)view didMakeTag:(NSString *)tag

{
    if (view == _view1) {
        [_view2 addTagToLast:tag animated:YES];
        [_view2 setTagViewsColor:[UIColor redColor] forTag:tag];
    }
    
}

- (void)tagWriteView:(HYTagWriterView *)view didRemoveTag:(NSString *)tag
{
    if (view==_view1) {
        [_view2 setTagViewsColor:[UIColor lightGrayColor] forTag:tag];
    }
    
    NSLog(@"removed tag = %@", tag);
}
- (void)tagWriteView:(HYTagWriterView *)view didSelect:(NSString *)tag;
{
    NSLog(@"Selected tag = %@",tag);
    if (view == _view2) {
        [_view1 addTagToLast:tag animated:YES];
        //        _customerTag.inputView
        [_view2 setTagViewsColor:[UIColor redColor] forTag:tag];
        
        
    }else{
        [_view1 setTagViewsColor:[UIColor redColor] forTag:tag];
    }
}
-(void)tagWriteViewDidBeginEditing:(HYTagWriterView *)view{
}



-(void)tagWriteView:(HYTagWriterView *)view exceedMaxWidth:(BOOL)exceedMaxWdith{

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

-(void)tagWriteView:(HYTagWriterView *)view increaseViewHeigt:(CGFloat)height{
    
    CGRect rect = _view2.frame;
    rect.origin.y = _view1.frame.origin.y+_view1.frame.size.height + 10 ;
    
    rect.size.height = [[UIScreen mainScreen] bounds].size.height - rect.origin.y;

    
    [UIView animateWithDuration:0.25 animations:^{
        _view2.frame = rect;
    }];
}
@end
