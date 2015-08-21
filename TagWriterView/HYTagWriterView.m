//
//  HYTagWriterView.m
//  TagWriterView
//
//  Created by huangyuan on 7/30/15.
//  Copyright (c) 2015 huangyuan. All rights reserved.
//

#import "HYTagWriterView.h"
static CGFloat IPHONE5_WIDTH = 640/2;
@interface HYTagWriterView  ()< HYTextFieldDelegate>
@property (nonatomic, strong) NSMutableArray *tagsMade;
@property (nonatomic, assign) BOOL readyToDelete;
@property (nonatomic, assign) BOOL readyToFinishMaking;
@property (nonatomic, assign) BOOL exceedMaxLenth;
@property (nonatomic, assign) BOOL addOneMoreRow;

@property (nonatomic, assign) CGFloat accumX;
@property (nonatomic, assign) CGFloat accumY;


@end

@implementation HYTagWriterView

{
    int numberOfRows;
    CGFloat inset;
}
- (id)initWithFrame:(CGRect)frame
{
    numberOfRows =0;
    inset = 20.0f;
    _deleteHiden = NO;
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initProperties];
        [self initControls];
//        [self reArrangeSubViews];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                    name:@"UITextFieldTextDidChangeNotification"
                                                  object:_inputView];

    }
    return self;
}

- (void)awakeFromNib
{
    inset = 20.0f;
    numberOfRows =0;
    _deleteHiden = NO;

    [self initProperties];
    [self initControls];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:_inputView];
//    [self reArrangeSubViews];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:@"UITextFieldTextDidChangeNotification"
                                                 object:_inputView];
}


- (void)initControls
{
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.scrollsToTop = YES;
    _scrollView.showsVerticalScrollIndicator = YES;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_scrollView];
    
    _inputView = [[HYTextField alloc] initWithFrame:CGRectMake(0, 0, _textViewWidth, _textViewHeight)];//CGRectInset(self.bounds, 0, _tagGap)];
    _inputView.placeholder=@"请输入";
//    [_inputView showBorder:WHITE_COLOR];
    _inputView.autocorrectionType = UITextAutocorrectionTypeNo;
    _inputView.delegate = self;
    _inputView.returnKeyType = UIReturnKeyDone;
    
//    _inputView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    [_scrollView addSubview:_inputView];
    
    _deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(30, 0, 20, 20)];
    [_deleteButton setBackgroundImage:[UIImage imageNamed:@"Delete.png"] forState:UIControlStateNormal];
    [_deleteButton addTarget:self action:@selector(deleteTagDidPush:) forControlEvents:UIControlEventTouchUpInside];
    _deleteButton.hidden = YES;
    
    
    _scrollView.contentSize=CGSizeMake(0, (_inputView.frame.origin.y + _inputView.frame.size.height));//inputview Height + is； postion
}



- (void)initProperties
{
    _font = [UIFont systemFontOfSize:14.0f];
    _tagBackgroundColor = [UIColor grayColor];
    _tagForegroundColor = [UIColor grayColor];
    _maxTagLength = 16;
    // _tagGap = 4.0f;
    
    _tagsMade = [NSMutableArray array];
    _tagViews = [NSMutableArray array];
    
    _readyToDelete = NO;
    
    _exceedMaxLenth = NO;
    
    _textViewHeight=25;
    _textViewWidth = 75;
    
    _viewMaxHeight = self.bounds.size.height;
}



- (void)setFont:(UIFont *)font
{
    _font = font;
    for (UIButton *btn in _tagViews)
    {
        [btn.titleLabel setFont:_font];
    }
}

- (void)setTagBackgroundColor:(UIColor *)tagBackgroundColor
{
    _tagBackgroundColor = tagBackgroundColor;
    for (UIButton *btn in _tagViews)
    {
        [btn setBackgroundColor:_tagBackgroundColor];
    }
    
    //    _inputView.layer.borderColor = _tagBackgroundColor.CGColor;
    
    _inputView.textColor = _tagBackgroundColor;
}

- (void)setTagForegroundColor:(UIColor *)tagForegroundColor
{
    _tagForegroundColor = tagForegroundColor;
    for (UIButton *btn in _tagViews)
    {
        [btn setTitleColor:_tagForegroundColor forState:UIControlStateNormal];
    }
}

- (void)setMaxTagLength:(int)maxTagLength
{
    _maxTagLength = maxTagLength;
}

- (NSArray *)tags
{
    return _tagsMade;
}

- (void)setFocusOnAddTag:(BOOL)focusOnAddTag
{
    _focusOnAddTag = focusOnAddTag;
    if (_focusOnAddTag)
    {
        [_inputView becomeFirstResponder];
    }
    else
    {
        [_inputView resignFirstResponder];
    }
}

- (CGFloat)posXForObjectNextToLastTagView
{
    CGFloat accumX = _tagGap;
    if (_tagViews.count)
    {
        UIView *last = _tagViews.lastObject;
        accumX = last.frame.origin.x + last.frame.size.width + _tagGap;
    }
    return accumX;
}
- (CGFloat)posYForObjectNextToLastTagView
{
    CGFloat accumY = _tagGap;
    if (_tagViews.count)
    {
        UIView *last = _tagViews.lastObject;
        accumY = last.frame.origin.y ;
    }
    return accumY;
}

- (CGFloat)widthForInputViewWithText:(NSString *)text
{
    //DDLogDebug(@"current: width:%f",MAX(75, [text sizeWithAttributes:@{NSFontAttributeName:_font}].width + 25.0f));
    return MAX(75, [text sizeWithAttributes:@{NSFontAttributeName:_font}].width + inset);
}


//mark : - tagview的btn 添加与删除
- (void)addTags:(NSArray *)tags
{
//    for (NSString *tag in tags)
//    {
//        NSArray *result = [_tagsMade filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF == %@", tag]];
//        if (result.count == 0)
//        {
//            //[_tagsMade addObject:tag];
//            [self addTagToLast:tag animated:YES];
//        }
//    }
    //        for (NSString* tag in _tagsMade) {
    //            [self addTagToLast:tag animated:YES];
    //        }
    _tagsMade = [NSMutableArray arrayWithArray:tags];
     [self reArrangeSubviews];
}

- (void)addTagToLast:(NSString *)tag animated:(BOOL)animated
{
    tag=[NSString stringWithFormat:@"%@", tag];
    tag = [tag stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    for (NSString *t in _tagsMade)
    {
        if ([tag isEqualToString:t])
        {
            NSLog(@"DUPLICATED!");
            return;
        }
    }
    
    [_tagsMade addObject:tag];
    _inputView.text = @"";
    
    [self addTagViewToLast:tag animated:animated];
    [self layoutInputAndScroll];
    
    if ([_delegate respondsToSelector:@selector(tagWriteView:didMakeTag:)])
    {
        [_delegate tagWriteView:self didMakeTag:tag];
    }
}

- (void)removeTag:(NSString *)tag animated:(BOOL)animated
{
    NSInteger foundedIndex = -1;
    for (NSString *t in _tagsMade)
    {
        if ([tag isEqualToString:t])
        {
            NSLog(@"FOUND!");
            foundedIndex = (NSInteger)[_tagsMade indexOfObject:t];
            break;
        }
    }
    
    if (foundedIndex == -1)
    {
        return;
    }
    
    [_tagsMade removeObjectAtIndex:foundedIndex];
    
    [self removeTagViewWithIndex:foundedIndex animated:animated completion:^(BOOL finished){
        _readyToDelete = YES;
        [UIView animateWithDuration:0.25 animations:^{
            [self layoutInputAndScroll];
            [self setScrollOffsetToShowInputView];

        }completion:^(BOOL finished) {
            _readyToDelete = NO;
        }];
    }];
//    [self increaseViewHeight];
    if ([_delegate respondsToSelector:@selector(tagWriteView:didRemoveTag:)])
    {
        [_delegate tagWriteView:self didRemoveTag:tag];
    }
}

- (void)removeTagViewWithIndex:(NSUInteger)index animated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    NSAssert(index < _tagViews.count, @"incorrected index");
    if (index >= _tagViews.count)
    {
        return;
    }
    
    UIView *deletedView = [_tagViews objectAtIndex:index];
    [deletedView removeFromSuperview];
    [_tagViews removeObject:deletedView];
    void (^layoutBlock)(void) = ^{
        CGFloat posX = _tagGap;
        CGFloat posY = _tagGap;
        for (int idx = 0; idx < _tagViews.count; ++idx)
        {
            
            UIView *view = [_tagViews objectAtIndex:idx];
            CGRect viewFrame = view.frame;
            if ((viewFrame.size.width +posX)>  self.frame.size.width-2*_tagGap) {
                posX =_tagGap;
                numberOfRows++;
                _addOneMoreRow = YES;
                
                NSLog(@"++++%d", numberOfRows);
                posY += (_textViewHeight+_tagGap);
                NSLog(@"++++%f", posY);
            }
            
            viewFrame.origin.x = posX;
            viewFrame.origin.y = posY;
            NSLog(@"here2%f",posY);
            view.frame = viewFrame;
            
            posX += viewFrame.size.width + _tagGap;
            
            
            view.tag = idx;
        }
    };
    
    if (animated)
    {
        numberOfRows =0;
        [UIView animateWithDuration:0.25 animations:layoutBlock completion:completion];
    }
    else
    {
        numberOfRows=0;
        layoutBlock();
        completion(YES);
    }
    
    
}



// MARK: -  interfaces
-(void)increaseViewHeight{
    CGFloat inputViewY = _inputView.frame.origin.y;
    CGRect rect =self.frame;
    rect.size.height = _inputView.frame.origin.y + _textViewHeight+_tagGap;
    NSLog(@"----inputView y3.0: %f", _inputView.frame.origin.y);

    NSLog(@"----self frame H3.1.1: %f", self.frame.origin.y);
    NSLog(@"----self bounds H3.1.2: %f", self.bounds.origin.y);
    //    _scrollView.frame = self.bounds;
    
    NSLog(@"----_scrollview frame H3.2.1: %f", _scrollView.frame.origin.y);
    NSLog(@"----_scrollview contentsize H3.2.2: %f", _scrollView.contentSize.height);
//    rect = _scrollView.frame;
//    rect.size.height = _inputView.frame.origin.y + _textViewHeight+_tagGap;
//    _scrollView.frame = rect;

    [UIView animateWithDuration:0.25 animations:^{
        self.frame = rect;
        
    }];
    
    rect = _inputView.frame;
    
    rect.origin.y = inputViewY;
    _inputView.frame = rect;
    NSLog(@"++++inputView y3.1: %f", _inputView.frame.origin.y);
    NSLog(@"++++self frame H3.1.1: %f", self.frame.origin.y);
    NSLog(@"++++self bounds H3.1.2: %f", self.bounds.origin.y);
    //    _scrollView.frame = self.bounds;

    NSLog(@"++++_scrollview frame H3.2.1: %f", _scrollView.frame.origin.y);
    NSLog(@"++++_scrollview contentsize H3.2.2: %f", _scrollView.contentSize.height);

    NSLog(@"inputView y3.2: %f", _inputView.frame.origin.y);

    if ([_delegate respondsToSelector:@selector(tagWriteView:increaseViewHeigt:)]) {
        [_delegate tagWriteView:self increaseViewHeigt:_textViewHeight+_tagGap];
    }

    
}


- (void)addTagViewToLast:(NSString *)newTag animated:(BOOL)animated
{
    CGFloat posX = [self posXForObjectNextToLastTagView];
    CGFloat posY = [self posYForObjectNextToLastTagView];

    UIButton *tagBtn = [self tagButtonWithTag:newTag posX:posX posY:posY];
    [_tagViews addObject:tagBtn];
    tagBtn.tag = [_tagViews indexOfObject:tagBtn];
    [_scrollView addSubview:tagBtn];
    
    
    if (animated)
    {
        tagBtn.alpha = 0.0f;
        [UIView animateWithDuration:0.25 animations:^{
            tagBtn.alpha = 1.0f;
        }];
    }
    
}


-(void)reArrangeSubviews{
    _accumX = _tagGap ;//init position
    _accumY = _tagGap ;
    numberOfRows = 0;
    NSMutableArray *newTagBtns = [[NSMutableArray alloc] initWithCapacity:_tagsMade.count];
    for (NSString *tag in _tagsMade) {
        UIButton * tagBtn =[self tagButtonWithTag:tag posX:_accumX posY:_accumY];
        [newTagBtns addObject:tagBtn];
        tagBtn.tag = [newTagBtns indexOfObject:tagBtn];
        _accumX += tagBtn.frame.size.width + _tagGap;
        [_scrollView addSubview:tagBtn];
    }
    
    [_tagViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
     _tagViews = newTagBtns;
    
    
}

- (UIButton *)tagButtonWithTag:(NSString *)tag posX:(CGFloat)posX posY:(CGFloat)posY
{
    UIButton *tagBtn = [[UIButton alloc] init];
    [tagBtn.titleLabel setFont:_font];
    //    [tagBtn setBackgroundColor:_tagBackgroundColor];
    [tagBtn setTitleColor:_tagForegroundColor forState:UIControlStateNormal];
//    [tagBtn showBorder:_tagForegroundColor];
    [self showBorderForView:tagBtn color:_tagBackgroundColor];
    [tagBtn addTarget:self action:@selector(tagButtonDidPushed:) forControlEvents:UIControlEventTouchUpInside];
    [tagBtn setTitle:tag forState:UIControlStateNormal];
    
    CGRect btnFrame = tagBtn.frame;
    
    btnFrame.origin.x = posX;
    btnFrame.origin.y = posY;
    btnFrame.size.width = [tagBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:_font}].width + (tagBtn.layer.cornerRadius * 2.0f) +inset;
    
    if ((btnFrame.size.width+posX) > self.frame.size.width-2*_tagGap) {
        numberOfRows++;

        posX =_tagGap;
        posY =  _tagGap+ numberOfRows*(_textViewHeight+_tagGap);
        
        _accumY = posY;
        _accumX = posX;
        
        _addOneMoreRow = YES;
        
        
        btnFrame.origin.x = posX;
        btnFrame.origin.y = posY;
    }
    
    btnFrame.size.height = _textViewHeight;//self.frame.size.height - 13.0f;
    tagBtn.layer.cornerRadius = btnFrame.size.height * 0.5f;
    tagBtn.frame = CGRectIntegral(btnFrame);
    
    NSLog(@"btn frame [%@] = %@", tag, NSStringFromCGRect(tagBtn.frame));
    return tagBtn;
}

-(void)textFiledEditChanged:(NSNotification *)obj{
     NSLog(@"|=====2");
    _exceedMaxLenth = NO;
    HYTextField *textField = (HYTextField *)obj.object;
    
    NSString *toBeString = textField.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    
    
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        NSString* selectedString = [textField textInRange:selectedRange];
        NSString* noneSelected = [textField.text stringByReplacingOccurrencesOfString:selectedString withString:@""];
        
        [selectedString sizeWithAttributes:@{NSFontAttributeName:_font}];
        NSLog(@"%@ the width : %f ",selectedString, [selectedString sizeWithAttributes:@{NSFontAttributeName:_font}].width + inset);
        if (!position) {
            if (toBeString.length > _maxTagLength) {
//                textField.text = [toBeString substringToIndex:_maxTagLength];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            if (toBeString.length > _maxTagLength) {
//                textField.text = [toBeString substringToIndex:_maxTagLength];

            }
        }
        [self setinputRectWidth:[self zhHansTextFieldWidth:selectedString noneSelected:noneSelected]];
        
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > _maxTagLength) {
//            textField.text = [toBeString substringToIndex:_maxTagLength];
        }else{
        }
        [self setinputRectWidth:+[self zhHansTextFieldWidth:@"" noneSelected:toBeString]];
    }
    // 当输入框需要更长的宽时，把输入框转到下一行
    if (_inputView.frame.origin.x+_inputView.frame.size.width > self.frame.size.width) {
        [self reLayoutInputView];
    }
    
}
-(CGFloat)zhHansTextFieldWidth:(NSString*)zhHans noneSelected:(NSString*)noneSelected{

    return MAX(75, [zhHans sizeWithAttributes:@{NSFontAttributeName:_font}].width + [noneSelected sizeWithAttributes:@{NSFontAttributeName:_font}].width +inset);

}
-(void)reLayoutInputView{

    CGRect inputRect = _inputView.frame;
    inputRect.origin.y +=  _textViewHeight +_tagGap;
    inputRect.origin.x = _tagGap;
    
    _inputView.frame = inputRect;
    [self setScrollOffsetToShowInputView];
    
    
    


}

-(void)layoutInputAndScroll{
    CGFloat accumX = [self posXForObjectNextToLastTagView];
    CGFloat accumY = [self posYForObjectNextToLastTagView];

    CGRect inputRect = _inputView.frame;
    inputRect.origin.x = accumX;
    inputRect.origin.y = accumY;
    inputRect.size.width = [self widthForInputViewWithText:_inputView.text];
    inputRect.size.height = _textViewHeight;
    if ((inputRect.size.width+accumX) > self.frame.size.width-2*_tagGap) {
//        numberOfRows++;
        
        accumX =_tagGap;
        accumY =  accumY + _textViewHeight +_tagGap;
        
//        _addOneMoreRow = YES;
        
        inputRect.origin.x = accumX;
        inputRect.origin.y = accumY;
    }

    _inputView.frame = inputRect;
    _inputView.font = _font;
    
    NSLog(@"inputView y: %f", _inputView.frame.origin.y);
    
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _inputView.frame.size.height * 0.5f, 10)];
    [_inputView setLeftViewMode :UITextFieldViewModeAlways];
    [_inputView setLeftView:spacerView];

    
    _inputView.layer.borderWidth = 1.0f;
    _inputView.layer.cornerRadius = _inputView.frame.size.height * 0.5f;
    _inputView.backgroundColor = [UIColor clearColor];
    _inputView.textColor = _tagBackgroundColor;
    
    
    
    
    CGFloat view_y = _textViewHeight + _inputView.frame.origin.y;
    if (view_y >= _scrollView.contentSize.height- _textViewHeight - _tagGap) {
        CGSize contentSize = _scrollView.contentSize;
        contentSize.height = inputRect.origin.y + _textViewHeight+_tagGap;
        _scrollView.contentSize = contentSize;
    }
    NSLog(@"_scrollview contentsize H9.2.2: %f", _scrollView.contentSize.height);

//    CGSize contentSize = _scrollView.contentSize;
    
    

    
    [self setScrollOffsetToShowInputView];

}

- (void)setScrollOffsetToShowInputView
{

//    NSLog(@"%@---|---%@",NSStringFromCGSize(_scrollView.contentSize),NSStringFromCGSize(self.frame.size));
//    
//    CGRect inputRect = _inputView.frame;
//    CGFloat scrollingDelta = (inputRect.origin.x + inputRect.size.width) -self.frame.size.width* 0.8;
//    
//    if (scrollingDelta > 0 && (_scrollView.contentSize.height>self.frame.size.height) ) {
//        CGPoint scrollOffset = _scrollView.contentOffset;
//        scrollOffset.y = inputRect.origin.y + _textViewHeight *2;
//        _scrollView.contentOffset = scrollOffset;
//
//    }
//
    if ((_inputView.frame.origin.y + _textViewHeight >= self.frame.size.height && _viewMaxHeight >= self.frame.size.height + _textViewHeight + _tagGap )||_readyToDelete ) {
        NSLog(@"inputView y3: %f", _inputView.frame.origin.y);

        [self increaseViewHeight];
        
    }
    NSLog(@"inputView y4: %f", _inputView.frame.origin.y);

    CGPoint scrollOffset = _scrollView.contentOffset;
    scrollOffset.y = _inputView.frame.origin.y +_textViewHeight +_tagGap - self.frame.size.height;
    _scrollView.contentOffset = scrollOffset;
    
}



// MARK: - tools
-(void) setinputRectWidth:(int)newWidth{
    CGFloat maxWidth = (self.frame.size.width > IPHONE5_WIDTH) ? IPHONE5_WIDTH : self.frame.size.width;
    if (newWidth >= maxWidth - 2*_tagGap) {
        _exceedMaxLenth=YES;
        return;
    }
    CGRect inputRect = _inputView.frame;
    inputRect.size.width = newWidth;
    
    _inputView.frame = inputRect;
    
    NSLog(@"inputView y2: %f", _inputView.frame.origin.y);


}

-(void)showBorderForView:(UIView*) view color:(UIColor*) color{
    view.layer.borderColor=color.CGColor;
    view.layer.borderWidth=1.0f;

}

- (BOOL)isFinishLetter:(NSString *)letter
{
    if ([letter isEqualToString:@"\n"])
    {
        return YES;
    }
    
    if ([letter isEqualToString:@" "])
    {
        if ( _readyToFinishMaking == NO)
        {
            _readyToFinishMaking = YES;
            return NO;
        }
        else
        {
            _readyToFinishMaking = NO;
            return YES;
        }
    }
    else
    {
        _readyToFinishMaking = NO;
    }
    
    return NO;
}

- (void)detectBackspace
{
    if (_inputView.text.length == 0)
    {
        if (_readyToDelete)
        {
            // remove lastest tag
            if (_tagsMade.count > 0)
            {
                NSString *deletedTag = _tagsMade.lastObject;
                [self removeTag:deletedTag animated:YES];
                _readyToDelete = NO;
            }
        }
        else
        {
            _readyToDelete = YES;
        }
    }
}

#pragma mark - UI Actions
- (void)tagButtonDidPushed:(id)sender
{
    UIButton *btn = sender;
    NSLog(@"tagButton pushed: %@, idx = %ld", btn.titleLabel.text, (long)btn.tag);
    
    if (_deleteButton.hidden == NO && btn.tag == _deleteButton.tag)
    {
        // hide delete button
        _deleteButton.hidden = YES;
        [_deleteButton removeFromSuperview];
    }
    else
    {
        // show delete button
        CGRect newRect = _deleteButton.frame;
        newRect.origin.x = btn.frame.origin.x + btn.frame.size.width - (newRect.size.width * 0.5f);
        newRect.origin.y = btn.frame.origin.y - 10.0f;
        _deleteButton.frame = newRect;
        _deleteButton.tag = btn.tag;
        
        if (_deleteButton.superview == nil)
        {
            [_scrollView addSubview:_deleteButton];
        }
        
        _deleteButton.hidden = NO;
        if (_deleteHiden) {
            _deleteButton.hidden = YES;
        }
    }
    
    if ([_delegate respondsToSelector:@selector(tagWriteView:didSelect:)])
    {
        [_delegate tagWriteView:self didSelect:btn.titleLabel.text];
    }
    
}

- (void)deleteTagDidPush:(id)sender
{
    NSLog(@"tag count = %lu,  button tag = %ld", (unsigned long)_tagsMade.count, (long)_deleteButton.tag);
    NSAssert(_tagsMade.count > _deleteButton.tag, @"out of range");
    if (_tagsMade.count <= _deleteButton.tag)
    {
        return;
    }
    
    _deleteButton.hidden = YES;
    [_deleteButton removeFromSuperview];
    
    NSString *tag = [_tagsMade objectAtIndex:_deleteButton.tag];
    [self removeTag:tag animated:YES];
    
}


#pragma mark - HYTextFieldDelegate
-(BOOL)textField:(HYTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)text{
    NSLog(@"|=====1");
    if ([self isFinishLetter:text])
    {
        if (_exceedMaxLenth) {
            if ([_delegate respondsToSelector:@selector(tagWriteView:exceedMaxLength:)])
            {
                [_delegate tagWriteView:self exceedMaxLength:_exceedMaxLenth];
            }
            return NO;
        }
        if (textField.text.length > 0)
        {
            if ( textField.text.length <= _maxTagLength) {
                
            }
            [self addTagToLast:textField.text animated:YES];
            textField.text = @"";
        }
        
        if ([text isEqualToString:@"\n"])
        {
            [textField resignFirstResponder];
        }
        
        return NO;
    }
    
    if (text.length == 0)
    {
        // delete
        if (textField.text.length)
        {
//              newText = [textField.text substringWithRange:NSMakeRange(0, textField.text.length - range.length)];
        }
        else
        {
            NSLog(@"删除");
            [self detectBackspace];
            return NO;
        }
    }
    else
    {
        
        
    }
    
//    if (_inputView.frame.size.width+_inputView.frame.origin.x >= self.frame.size.width-2*_tagGap) {
//        NSLog(@"|+===3");
//        return NO;
//    }
    
    return YES;

}


@end
