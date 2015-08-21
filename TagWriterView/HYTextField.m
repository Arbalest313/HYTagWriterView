//
//  DeleteTextField.m
//  TagWriterView
//
//  Created by huangyuan on 8/17/15.
//  Copyright (c) 2015 huangyuan. All rights reserved.
//

#import "HYTextField.h"

@implementation HYTextField

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
//    NSLog(@"123删除");
//    if (self.text.length <= 0) {
//        if ([_myDelegate respondsToSelector:@selector(textFieldDidDelete)]){
//            [_myDelegate textFieldDidDelete];
//         }
//    }
//    
//    [super deleteBackward];

    BOOL shouldDismiss = [self.text length] == 0;
    
    [super deleteBackward];
    
    if (shouldDismiss) {
        if ([self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
            [self.delegate textField:self shouldChangeCharactersInRange:NSMakeRange(0, 0) replacementString:@""];
        }
    }
}

@end