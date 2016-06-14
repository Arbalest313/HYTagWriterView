//
//  ViewController.m
//  TagWriterView
//
//  Created by huangyuan on 7/30/15.
//  Copyright (c) 2015 huangyuan. All rights reserved.
//

#import "ViewController.h"
#import "HYTagWriterView.h"
#define BACKGROUND_COLOR ([UIColor colorWithRed:(float)239 / 255.0 green:(float)239 / 255.0 blue:(float)239 / 255.0 alpha:1])
#define kSCREEN_WIDTH [[UIScreen mainScreen]bounds].size.width
#define kSCREEN_HEIGHT [[UIScreen mainScreen]bounds].size.height
#define WHITE_COLOR ([UIColor whiteColor])
#define BLACK_COLOR ([UIColor blackColor])
#define GRAY_COLOR ([UIColor grayColor])
#define LINE_COLOR RGBA(226,226,226,1)
#define BACKGROUND_COLOR ([UIColor colorWithRed:(float)239 / 255.0 green:(float)239 / 255.0 blue:(float)239 / 255.0 alpha:1])
#define BASE_COLOR ([UIColor colorWithRed:229/255.0 green:98/255.0 blue:92/255.0 alpha:1])
#define BASE_COLOR_WIHTE kUIColorFromRGB(0xFF938E)

@interface ViewController () <HYTagWriterViewDelegate>
@property (nonatomic, strong) HYTagWriterView *view1;
@property (nonatomic, strong) HYTagWriterView *view2;
@property (nonatomic, strong) UILabel * usedTagLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self initView];
    [self initData];
    
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //    [_view1.inputView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





#pragma mark - HKKTagWriteViewDelegate
- (void)tagWriteView:(HYTagWriterView *)view didMakeTag:(NSString *)tag

{
    
    if (view == _view1) {
        [_view2 addTagToLast:tag animated:YES];
        
        [_view2 setTagViewsColor:BASE_COLOR forTag:tag];
    }
    
}

- (void)tagWriteView:(HYTagWriterView *)view didRemoveTag:(NSString *)tag
{
    if (view==_view1) {
        [_view2 setTagViewsColor:GRAY_COLOR forTag:tag];
    }
    
    NSLog(@"removed tag = %@", tag);
}
- (void)tagWriteView:(HYTagWriterView *)view didSelect:(NSString *)tag;
{
    NSLog(@"Selected tag = %@",tag);
    if (view == _view2) {
        [_view1 addTagToLast:tag animated:YES];
        [_view2 setTagViewsColor:BASE_COLOR forTag:tag];
        
        
    }else{
        [_view2 setTagViewsColor:BASE_COLOR forTag:tag];
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
    
    UILabel *notice = [UILabel new];
    notice.font = [UIFont systemFontOfSize:14];
    notice.textColor = GRAY_COLOR;
    notice.text = @"不能超过16个字";
    
}

-(void)tagWriteView:(HYTagWriterView *)view increaseViewHeigt:(CGFloat)height{
    
    CGRect rect = _usedTagLabel.frame;
    rect.origin.y = view.frame.origin.y + view.frame.size.height + 10 ;
    
    CGRect rect2 = _view2.frame;
    rect2.origin.y= view.frame.origin.y + view.frame.size.height  + 20+14;
    rect2.size.height = kSCREEN_HEIGHT-64-rect2.origin.y;
    
    [UIView animateWithDuration:0.25 animations:^{
        _usedTagLabel.frame = rect;
        _view2.frame = rect2;
    }];
}





#pragma mark - view setup
//MARK: -  view setup
-(void)initData{
    NSArray * tmp = [[NSArray alloc] initWithObjects:@"Hello", @"initWithObjects",@"TAG",@"美好的一天从这里开始",nil];
    NSArray * tmp2 = [[NSArray alloc] initWithObjects:@"WeChat",@"TAG",nil];
    [self.view1 addTags:tmp2];
    [self.view2 addTags:tmp];
}
-(void)initView{
    self.view.backgroundColor=BACKGROUND_COLOR;
    
    
    self.view1=[[HYTagWriterView alloc] initWithFrame:CGRectMake(0, 17+ 64, kSCREEN_WIDTH, 45)];
    _view1.viewMaxHeight = 178;
    _view1.backgroundColor=WHITE_COLOR;
    
    self.usedTagLabel=[UILabel new];
    _usedTagLabel.frame=CGRectMake(17, _view1.frame.origin.y + _view1.frame.size.height +10, kSCREEN_WIDTH, 14);
    _usedTagLabel.text=@"所有标签";
    _usedTagLabel.textColor=[UIColor lightGrayColor];
    _usedTagLabel.font=[UIFont systemFontOfSize:14];
    
    
    self.view2=[[HYTagWriterView alloc] initWithFrame:CGRectMake(0, _usedTagLabel.frame.origin.y + _usedTagLabel.frame.size.height +10, kSCREEN_WIDTH, kSCREEN_HEIGHT- _usedTagLabel.frame.origin.y - _usedTagLabel.frame.size.height)];
    
    
    _view1.tagGap =10;
    _view2.tagGap=10;
    
    _view1.delegate = self;
    _view1.scrollView.showsVerticalScrollIndicator =YES;
    _view1.tagForegroundColor=BASE_COLOR;
    _view1.tagBorderColor = BASE_COLOR;
    
    _view2.delegate = self;
    _view2.inputView.hidden = YES;
    _view2.inputView.enabled=NO;
    _view2.deleteButton.hidden = YES;
    _view2.deleteHiden = YES;
    _view2.deleteButton.enabled = NO;
    _view2.tagForegroundColor=GRAY_COLOR;
    _view2.tagBorderColor = GRAY_COLOR;
    [_view2 clear];
    [_view1 clear];
    
    
    [self.view addSubview:_view2];
    [self.view addSubview:_view1];
    [self.view addSubview:_usedTagLabel];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(becomeEditing)];
    [_view1 addGestureRecognizer:tap];
}


#pragma mark - notification
- (void) keyboardWillHide :(id*) recognizer{
    
    if (_view1.inputView.text.length>0) {
        
        [_view1.inputView.delegate textField:_view1.inputView shouldChangeCharactersInRange:NSMakeRange(0, 0) replacementString:@"\n"];
        
    }
    
}
- (void)becomeEditing{
    [_view1.inputView becomeFirstResponder];
}


@end
