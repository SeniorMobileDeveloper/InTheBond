//
//  Setting.h
//  InTheBond
//
//  Created by Nala on 6/28/15.
//  Copyright (c) 2015 Nala. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProfileInformation.h"

@interface Setting : NSObject

@property (retain, nonatomic) ProfileInformation *myProfile;

+ (Setting*) sharedSetting;

@end
