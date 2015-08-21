//
//  HYTagWriterView.h
//  TagWriterView
//
//  Created by huangyuan on 7/30/15.
//  Copyright (c) 2015 huangyuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYTextField.h"
@protocol HYTagWriterViewDelegate;


@interface HYTagWriterView : UIView

//
// appearance
//
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *tagBackgroundColor;
@property (nonatomic, strong) UIColor *tagForegroundColor;
@property (nonatomic, assign) int maxTagLength;
@property (nonatomic, assign) CGFloat textViewHeight;
@property (nonatomic, assign) CGFloat textViewWidth;
//if not set, viewMaHeight is equal to bounds height
@property (nonatomic, assign) CGFloat viewMaxHeight;

@property (nonatomic, assign) CGFloat tagGap;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) HYTextField *inputView;
@property (nonatomic, assign) BOOL deleteHiden;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *tagViews;

@property (nonatomic, assign) BOOL focusOnAddTag;

//
// data
//
@property (nonatomic, readonly) NSArray *tags;



// delegate
@property (nonatomic, weak) id<HYTagWriterViewDelegate> delegate;

 
//
//
//
- (void)clear;
- (void)setTextToInputSlot:(NSString *)text;

- (void)addTags:(NSArray *)tags;
- (void)removeTags:(NSArray *)tags;
- (void)addTagToLast:(NSString *)tag animated:(BOOL)animated;
- (void)removeTag:(NSString *)tag animated:(BOOL)animated;
-(void)setTagViewsColor:(UIColor *)color forTag:(NSString*)tag;
-(void)addObserverForInput;


@end


@protocol HYTagWriterViewDelegate <NSObject>
@optional

/**
 *  user start to type tag in the textfield
 *
 *  @param view self
 */

- (void)tagWriteViewDidBeginEditing:(HYTagWriterView *)view;

/**
 *  user end eddinting
 *
 *  @param view self;
 */
- (void)tagWriteViewDidEndEditing:(HYTagWriterView *)view;


/**
 *  if the input textfield text changed
 *
 *  @param view self
 *  @param text the changed text
 */
- (void)tagWriteView:(HYTagWriterView *)view didChangeText:(NSString *)text;
/**
 *  if the retrun key is pressed by user
 *
 *  @param view self
 *  @param tag  the tag that user inputed
 */
- (void)tagWriteView:(HYTagWriterView *)view didMakeTag:(NSString *)tag;

/**
 *  if a tag is removed, this func is called
 *
 *  @param view  self
 *  @param tag  the removed tag
 */
- (void)tagWriteView:(HYTagWriterView *)view didRemoveTag:(NSString *)tag;

/**
 *  if a tag button is selected
 *
 *  @param view self
 *  @param tag  the selected tag
 */
- (void)tagWriteView:(HYTagWriterView *)view didSelect:(NSString *)tag;


/**
 *  if exceed maxlength of the input textField
 *
 *  @param view            self
 *  @param exceedMaxLength the maximum width of textField
 */
- (void)tagWriteView:(HYTagWriterView *)view exceedMaxWidth:(BOOL)exceedMaxWidth;

/**
 *  increase the HYTagView height by height
 *
 *  @param view   self
 *  @param height the heigth increased
 */
- (void)tagWriteView:(HYTagWriterView *)view increaseViewHeigt:(CGFloat)height;


@end







