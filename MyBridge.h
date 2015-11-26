//
//  MyBridge.m
//  CustomKB
//
//  Created by jijo pulikkottil on 12/8/14.
//  Copyright (c) 2014 test. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Toast+UIView.h"

@interface MyBridge : NSObject{
    
}
- (void) makeToast:(NSString *)mesage onView:(UIView *)selfee;
- (NSString *)getConvertedText:(NSString *)inputStr;

@end