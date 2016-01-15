//
//  SignupViewController.h
//  InTHeBond
//
//  Created by Nala on 6/23/15.
//  Copyright (c) 2015 Nala. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyViewController.h"

@interface SignupViewController : MyViewController


- (NSString*) validateWithFullName:(NSString*) fullName kroww : (NSString*) kross chapter : (NSString*) chapter occupation : (NSString*) occupation email : (NSString*) email password : (NSString*) password;
- (BOOL) isValidEmail:(NSString*) email;
@end
