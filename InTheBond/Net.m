//
//  Net.m
//  InTheBond
//
//  Created by Nala on 6/24/15.
//  Copyright (c) 2015 Nala. All rights reserved.
//

#import "Net.h"
#import "Setting.h"

@implementation Net

+ (void) requestToServerURL:(NSString *)url params:(PostParams *)params delegate:(id)delegate
{
    NSData *postData = [params getData];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    url = [NSString stringWithFormat:@"%@%@", SERVER_DOMAIN, url];
    NSLog(@"%@", url);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    [NSURLConnection connectionWithRequest:request delegate:delegate];
}

+ (void) requestLoginWithFullName:(NSString *)fullName password:(NSString *)password delegate:(id)delegate
{
#ifdef TEST
    NSLog(@"fullName:%@", fullName);
    NSLog(@"password:%@", password);
#endif
    PostParams *params = [[PostParams alloc] init];
    [params setStringParams:@"fullname" value:fullName];
    [params setStringParams:@"password" value:password];
    [Net requestToServerURL:@"login.php" params:params delegate:delegate];
}

+ (void) requestSignupWithFullName:(NSString *)fullName kross:(NSString *)kross chapter:(NSString *)chapter occupation:(NSString *)occupation email:(NSString *)email password:(NSString*)password delegate:(id)delegate
{
#ifdef TEST
    NSLog(@"fullName:%@", fullName);
    NSLog(@"kross:%@", kross);
    NSLog(@"chapter:%@", chapter);
    NSLog(@"password:%@", chapter);
    NSLog(@"occupation:%@", occupation);
    NSLog(@"email:%@", email);
    NSLog(@"password:%@", password);
#endif
    PostParams *params = [[PostParams alloc] init];
    [params setStringParams:@"fullname"
                      value:fullName];
    [params setStringParams:@"kross"
                      value:kross];
    [params setStringParams:@"chapter"
                      value:chapter];
    [params setStringParams:@"occupation"
                      value:occupation];
    [params setStringParams:@"email"
                      value:email];
    [params setStringParams:@"password"
                      value:password];
    [Net requestToServerURL:@"signup.php"
                     params:params delegate:delegate];
}

+ (void) requestGetFriendInformation:(NSString *)fullName
                            latitude:(double)lat
                           longitude:(double)lng
                            delegate:(id)delegate
{
#ifdef TEST
    NSLog(@"fullName:%@", fullName);
    NSLog(@"latitude:%f", lat);
    NSLog(@"longitude:%f", lng);
    
#endif
    PostParams *params = [[PostParams alloc] init];
    [params setStringParams:@"fullname"
                      value:fullName];
    [params setDoubleParams:@"y"
                      value:lat];
    [params setDoubleParams:@"x"
                      value:lng];
    [params setStringParams:@"fullname"
                      value:fullName];
    [Net requestToServerURL:@"Filterdistance.php"
                     params:params delegate:delegate];
}

@end
