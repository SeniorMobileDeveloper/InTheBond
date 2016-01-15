//
//  PostParams.h
//  InTheBond
//
//  Created by Nala on 6/24/15.
//  Copyright (c) 2015 Nala. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostParams : NSObject

@property (nonatomic, assign) NSString *params;

-(id) init;
-(void) setStringParams : (NSString *)name value : (NSString*) value;
-(void) setIntegerParams : (NSString *)name value : (int) value;
-(void) setDoubleParams : (NSString *)name value : (double) value;
-(NSData* ) getData;
@end
