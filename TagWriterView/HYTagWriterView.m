//
//  HYTagWriterView.m
//  TagWriterView
//
//  Created by huangyuan on 7/30/15.
//  Copyright (c) 2015 huangyuan. All rights reserved.
//

#import "HYTagWriterView.h"
static CGFloat IPHONE5_WIDTH = 640/2;
@interface HYTagWriterView  ()< HYTextFieldDelegate,UITextFieldDelegate>
@property (nonatomic, strong) NSMutableArray *tagsMade;
@property (nonatomic, assign) BOOL readyToDelete;
@property (nonatomic, assign) BOOL readyToFinishMaking;
@property (nonatomic, assign) BOOL exceedMaxWidth;
@property (nonatomic, assign) BOOL addOneMoreRow;

@property (nonatomic, assign) CGFloat accumX;
@property (nonatomic, assign) CGFloat accumY;

@property (nonatomic, strong) CAShapeLayer* border;

@end

@implementation HYTagWriterView

{
    int numberOfRows;
    CGFloat inset;
}

#pragma mark - setter 、getter 、 initializtion
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
    
    _inputView = [[HYTextField alloc] initWithFrame:CGRectMake(_tagGap, _tagGap, _textViewWidth, _textViewHeight)];//CGRectInset(self.bounds, 0, _tagGap)];
    _inputView.placeholder=@"请输入";

    _inputView.autocorrectionType = UITextAutocorrectionTypeNo;
    _inputView.delegate = self;
    _inputView.returnKeyType = UIReturnKeyDone;
    
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
    _tagBackgroundColor = [UIColor clearColor];
    _tagForegroundColor = [UIColor grayColor];
    _tagBorderColor = [UIColor clearColor];
    _maxTagLength = 16;
    // _tagGap = 4.0f;
    
    _tagsMade = [NSMutableArray array];
    _tagViews = [NSMutableArray array];
    
    _readyToDelete = NO;
    
    _exceedMaxWidth = NO;
 
    _frameWithInputView = YES;
    
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
    
}

- (void)setTagBorderColor:(UIColor *)tagBorderColor {
    _tagBorderColor = tagBorderColor;
    for (UIButton *btn in _tagViews)
    {
        [self showBorderForView:btn color:_tagBorderColor];
    }

}

- (void)setTagForegroundColor:(UIColor *)tagForegroundColor
{
    _tagForegroundColor = tagForegroundColor;
    for (UIButton *btn in _tagViews)
    {
        [btn setTitleColor:_tagForegroundColor forState:UIControlStateNormal];
    }
        _inputView.textColor = _tagForegroundColor;

}

- (void)setMaxTagLength:(NSInteger)maxTagLength
{
    _maxTagLength = maxTagLength;
}

- (NSArray *)tags
{
    return _tagsMade;
}


-(void)setTagViewsColor:(UIColor *)color forTag:(NSString*)tag{
    [self setTagViewsColor:color borderColor:color forTag:tag];
}
-(void)setTagViewsColor:(UIColor *)color borderColor:(UIColor *)borderColor forTag:(NSString*)tag{
    for (UIButton *btn in _tagViews)
    {
        if ([[btn.titleLabel.text uppercaseString] isEqualToString:[tag uppercaseString]]) {
            [btn setTitleColor:color forState:UIControlStateNormal];
            //            [btn showBorder:color];
            [self showBorderForView:btn color:borderColor];
        }
    }
    
}

#pragma mark - Actions && UI Interaction
- (void)clear
{
    _inputView.text = @"";
    [_tagsMade removeAllObjects];
    [self reArrangeSubviews];
}

- (void)addTags:(NSArray *)tags
{
    for (NSString *tag in tags)
    {
        NSArray *result = [_tagsMade filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF == %@", tag]];
        if (result.count == 0)
        {
            //[_tagsMade addObject:tag];
            [self addTagToLast:tag animated:YES];
        }
    }

}

- (void)addTagToLast:(NSString *)tag animated:(BOOL)animated
{
    if ([_delegate respondsToSelector:@selector(tagWriteView:willAddTag:)]) {
        if ([_delegate tagWriteView:self willAddTag:tag] == NO) {
            return;
        }
    }
    
    tag=[NSString stringWithFormat:@"%@", tag];
    tag = [tag stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString * tagUpper = [ tag uppercaseString];
    for (NSString *t in _tagsMade)
    {
        NSString * tUpper = [t uppercaseString];
        if ([tagUpper isEqualToString:tUpper])
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

- (void)removeTags:(NSArray *)tags
{
    for (NSString *tag in tags)
    {
        NSArray *result = [_tagsMade filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF == %@", tag]];
        if (result)
        {
            [_tagsMade removeObjectsInArray:result];
        }
    }
    
    [self reArrangeSubviews];
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
        if ( _inputView.frame.origin.y <= _viewMaxHeight) {
            _readyToDelete = YES;
        }

        [UIView animateWithDuration:0.25 animations:^{
            [self layoutInputAndScroll];
           // [self setScrollOffsetToShowInputView];

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


- (void)tagButtonDidPushed:(id)sender
{
    UIButton *btn = sender;
    
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


#pragma mark - interfaces

-(void)increaseViewHeight{
  //  CGFloat inputViewY = _inputView.frame.origin.y;
    CGRect rect =self.frame;
    if (_frameWithInputView) {
        rect.size.height = _inputView.frame.origin.y + _textViewHeight+_tagGap;
    }else {
        UIView * view = [_tagViews lastObject];
        rect.size.height = view.frame.origin.y + _textViewHeight+_tagGap;
    }
    if (rect.size.height <= _viewMaxHeight) {
        [UIView animateWithDuration:0.25 animations:^{
            self.frame = rect;
            
        }];
        if ([_delegate respondsToSelector:@selector(tagWriteView:increaseViewHeigt:)]) {
            [_delegate tagWriteView:self increaseViewHeigt:_textViewHeight+_tagGap];
        }
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
    
    [self layoutInputAndScroll];

    
}

- (UIButton *)tagButtonWithTag:(NSString *)tag posX:(CGFloat)posX posY:(CGFloat)posY
{
    UIButton *tagBtn = [[UIButton alloc] init];
    [tagBtn.titleLabel setFont:_font];
    [tagBtn setBackgroundColor:_tagBackgroundColor];
    [tagBtn setTitleColor:_tagForegroundColor forState:UIControlStateNormal];
    [self showBorderForView:tagBtn color:_tagBorderColor];
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

    _exceedMaxWidth = NO;
    HYTextField *textField = (HYTextField *)obj.object;
    
    UITextRange *selectedRange = [textField markedTextRange];
    NSString * selectedString = @"";
    NSString* noneSelected = @"";
    
    if (!selectedRange && textField.text.length > _maxTagLength) {
        textField.text = [textField.text substringToIndex:_maxTagLength];
        noneSelected = textField.text;
    } else {
        selectedString = [textField textInRange:selectedRange];
        noneSelected = [textField.text stringByReplacingOccurrencesOfString:selectedString withString:@""];
    }
    
    [self setinputRectWidth:[self zhHansTextFieldWidth:selectedString noneSelected:noneSelected]];
    
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
    
    
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _inputView.frame.size.height * 0.5f, 10)];
    [_inputView setLeftViewMode :UITextFieldViewModeAlways];
    [_inputView setLeftView:spacerView];

    
    
    
    CGFloat view_y = _textViewHeight + _inputView.frame.origin.y;
    if (_frameWithInputView) {
        if (view_y >= _scrollView.contentSize.height- _textViewHeight - _tagGap) {
            CGSize contentSize = _scrollView.contentSize;
            contentSize.height = inputRect.origin.y + _textViewHeight+_tagGap;
            _scrollView.contentSize = contentSize;
        }
    }else {
        UIView * lastTagView = [_tagViews lastObject];
        CGSize contentSize = _scrollView.contentSize;
        contentSize.height = lastTagView.frame.origin.y + _textViewHeight+_tagGap;
        _scrollView.contentSize = contentSize;
    }

    
    
    [_border removeFromSuperlayer];

    
    [self setScrollOffsetToShowInputView];

}

- (void)setScrollOffsetToShowInputView
{
    if (_frameWithInputView) {
        if ((_inputView.frame.origin.y + _textViewHeight >= self.frame.size.height && _viewMaxHeight >= self.frame.size.height + _textViewHeight + _tagGap )||_readyToDelete ) {
            
            [self increaseViewHeight];
        }
        
        
        CGPoint scrollOffset = _scrollView.contentOffset;
        scrollOffset.y = _inputView.frame.origin.y +_textViewHeight +_tagGap - self.frame.size.height;
        if (scrollOffset.y >= 0) {
            _scrollView.contentOffset = scrollOffset;
        }
    }else {
        UIView * view =[_tagViews lastObject];
        if ((view.frame.origin.y + _textViewHeight >= self.frame.size.height && _viewMaxHeight >= self.frame.size.height + _textViewHeight + _tagGap )||_readyToDelete ) {
        
            [self increaseViewHeight];
        }
        
        CGPoint scrollOffset = _scrollView.contentOffset;
        scrollOffset.y = view.frame.origin.y +_textViewHeight +_tagGap - self.frame.size.height;
        if (scrollOffset.y >= 0) {
            _scrollView.contentOffset = scrollOffset;
        }

    
    }
    
    
}



# pragma mark - tools
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


-(void) setinputRectWidth:(int)newWidth{
    CGFloat maxWidth = (self.frame.size.width > IPHONE5_WIDTH) ? IPHONE5_WIDTH : self.frame.size.width;
    if (newWidth >= maxWidth - 2*_tagGap) {
        _exceedMaxWidth=YES;
        return;
    }
    CGRect inputRect = _inputView.frame;
    inputRect.size.width = newWidth;
    
    _inputView.frame = inputRect;
    
    [_border removeFromSuperlayer];
    _border = [CAShapeLayer layer];
    _border.strokeColor = [UIColor colorWithRed:226 / 255.0 green:226 / 255.0 blue:226 / 255.0 alpha:1].CGColor;
    _border.fillColor = nil;
    _border.lineDashPattern = @[@1, @1];
    _border.path = [UIBezierPath bezierPathWithRoundedRect:_inputView.bounds cornerRadius:_inputView.frame.size.height*0.5f].CGPath;
    _border.frame =_inputView.bounds;
    [_inputView.layer addSublayer:_border];
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


#pragma mark - HYTextFieldDelegate
-(BOOL)textField:(HYTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)text{
    
    [_deleteButton removeFromSuperview];
    
    if ([self isFinishLetter:text])
    {
        NSLog(@"done-----");
        if (_exceedMaxWidth) {
            if ([_delegate respondsToSelector:@selector(tagWriteView:exceedMaxWidth:)])
            {
                [_delegate tagWriteView:self exceedMaxWidth:_exceedMaxWidth];
            }
            return NO;
        }
        
        if ([textField.text stringByTrimmingCharactersInSet:[NSCharacterSet  whitespaceAndNewlineCharacterSet]].length > 0)
        {
            
                [self addTagToLast:textField.text animated:YES];
                textField.text = @"";
            
            
        }
        return NO;
    }
    
    if (text.length == 0)
    {
        // delete
        if (textField.text.length)
        {
        }
        else
        {
            NSLog(@"删除");
            [_deleteButton removeFromSuperview];
            [self detectBackspace];
            return NO;
        }
    }
    else
    {
        
        
    }
    
    
    return YES;

}

- (void)textViewDidChange:(UITextView *)textView
{
    if ([_delegate respondsToSelector:@selector(tagWriteView:didChangeText:)])
    {
        [_delegate tagWriteView:self didChangeText:textView.text];
    }
    
    if (_deleteButton.hidden == NO)
    {
        _deleteButton.hidden = YES;
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
    
    _border = [CAShapeLayer layer];
    _border.strokeColor = [UIColor colorWithRed:67/255.0f green:37/255.0f blue:83/255.0f alpha:1].CGColor;
    _border.fillColor = nil;
    _border.lineDashPattern = @[@1, @1];
    _border.path = [UIBezierPath bezierPathWithRoundedRect:_inputView.bounds cornerRadius:_inputView.frame.size.height*0.5f].CGPath;
    _border.frame = _inputView.bounds;
    [_inputView.layer addSublayer:_border];

    if ([_delegate respondsToSelector:@selector(tagWriteViewDidBeginEditing:)])
    {
        [_delegate tagWriteViewDidBeginEditing:self];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
 
    [_border removeFromSuperlayer];
    
    if ([_delegate respondsToSelector:@selector(tagWriteViewDidEndEditing:)])
    {
        [_delegate tagWriteViewDidEndEditing:self];
    }
}



@end
