//
//  DeleteTextField.m
//  TagWriterView
//
//  Created by huangyuan on 8/17/15.
//  Copyright (c) 2015 huangyuan. All rights reserved.
//

#import "HYTextField.h"

@implementation HYTextField


/**
 *  iOS 8.1到8.2 存在BUG，textFile 在 empty的情况下，使用删除见无法触发事件。 
 *
 *  @param textField
 *
 *  @return
 */
- (BOOL)keyboardInputShouldDelete:(UITextField *)textField {
    BOOL shouldDelete = YES;
    
    if ([UITextField instancesRespondToSelector:_cmd]) {
        BOOL (*keyboardInputShouldDelete)(id, SEL, UITextField *) = (BOOL (*)(id, SEL, UITextField *))[UITextField instanceMethodForSelector:_cmd];
        
        if (keyboardInputShouldDelete) {
            shouldDelete = keyboardInputShouldDelete(self, _cmd, textField);
        }
    }
    
    BOOL isIos8 = ([[[UIDevice currentDevice] systemVersion] intValue] == 8);
    BOOL isLessThanIos8_3 = ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.3f);
    
    if (![textField.text length] && isIos8 && isLessThanIos8_3) {
        [self deleteBackward];
    }
    
    return shouldDelete;
}



- (void)deleteBackward {

    BOOL shouldDismiss = [self.text length] == 0;
    
    [super deleteBackward];
    
    if (shouldDismiss) {
        if ([self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
            [self.delegate textField:self shouldChangeCharactersInRange:NSMakeRange(0, 0) replacementString:@""];
        }
    }
}

@end