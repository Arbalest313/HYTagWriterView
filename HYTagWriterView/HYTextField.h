//
//  DeleteTextField.h
//  TagWriterView
//
//  Created by huangyuan on 8/17/15.
//  Copyright (c) 2015 huangyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HYTextFieldDelegate <NSObject>
@optional
- (void)textFieldDidDelete;
@end

@interface HYTextField : UITextField<UIKeyInput>


@end

//Implementation

