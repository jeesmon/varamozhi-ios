//
//  MyBridge.m
//  CustomKB
//
//  Created by jijo pulikkottil on 12/8/14.
//  Copyright (c) 2014 test. All rights reserved.
//


#import "MyBridge.h"

#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include "mal_api.h"
#include "txt2html.h"
#import "mozhi_unicode_default.h"



@implementation MyBridge

- (NSString *)getConvertedText:(NSString *)inputStr{
    
    long flags = FL_DEFAULT;
    char *output = mozhi_unicode_parse([inputStr UTF8String], flags);
    NSString *outputStr = [NSString stringWithUTF8String:output];
    
    return outputStr;
    return nil;
}

- (void) makeToast:(NSString *)mesage onView:(UIView *)selfee{
    
    [selfee makeToast:mesage duration:2.0 position:@"top"];
}

@end