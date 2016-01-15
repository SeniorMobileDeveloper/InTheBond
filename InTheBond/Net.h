//
//  Net.h
//  InTheBond
//
//  Created by Nala on 6/24/15.
//  Copyright (c) 2015 Nala. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostParams.h"

#define SERVER_DOMAIN @"http://thedatapp.co/aaa/"

#define NETWORK_CONNECTION_ERROR  -2222
#define SERVER_RESPONSE_ERROR  -1111
#define SERVER_RESPONSE_SUCCESS  1111
#define SIGN_UP_ALREADY_EXIST  2222
#define LOGIN_INVALID  3333

@interface Net:NSObject

+ (void) requestLoginWithFullName:(NSString*) fullName password:(NSString*) password delegate: (id) delegate;

+ (void) requestSignupWithFullName:(NSString *)fullName kross:(NSString *)kross chapter:(NSString *)chapter occupation:(NSString *)occupation email:(NSString *)email password:(NSString*)password delegate:(id)delegate;

+ (void) requestToServerURL:(NSString*) url params:(PostParams*) params delegate:(id) delegate;

+ (void) requestGetFriendInformation:(NSString*) fullName latitude:(double) lat longitude:(double) lng delegate:(id)delegate;

@end
