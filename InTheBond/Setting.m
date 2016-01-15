//
//  Setting.m
//  InTheBond
//
//  Created by Nala on 6/28/15.
//  Copyright (c) 2015 Nala. All rights reserved.
//

#import "Setting.h"
#define TEST

@implementation Setting

static Setting* _sharedSetting;

+ (Setting*) sharedSetting
{
    if (_sharedSetting == nil){
        _sharedSetting = [[Setting alloc] init];
    }
    return _sharedSetting;
}

@end
