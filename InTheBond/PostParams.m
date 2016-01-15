//
//  PostParams.m
//  InTheBond
//
//  Created by Nala on 6/24/15.
//  Copyright (c) 2015 Nala. All rights reserved.
//

#import "PostParams.h"
#import "Setting.h"

@implementation PostParams

-(id) init{
    self = [super init];
    if( !self ){
        return nil;
    }
    self.params = @"";
    return self;
}

-(void) setStringParams:(NSString *)name value:(NSString *)value{
    self.params = [NSString stringWithFormat:@"%@&%@=%@", self.params, name, value];
}

-(void) setIntegerParams:(NSString *)name value:(int)value{
    self.params = [NSString stringWithFormat:@"%@&%@=%d", self.params, name, value];
}

-(void) setDoubleParams:(NSString *)name value:(double)value{
    self.params = [NSString stringWithFormat:@"%@&%@=%f", self.params, name, value];
}

-(NSData*) getData{
    return [self.params dataUsingEncoding:NSUTF8StringEncoding];
}

@end
