//
//  MyAnnotation.m
//  InTheBond
//
//  Created by Nala on 6/29/15.
//  Copyright (c) 2015 Nala. All rights reserved.
//

#import "MyAnnotation.h"

@implementation MyAnnotation

- (void)setTitle:(NSString *)title{
    _title = title;
}
- (void)setCoordinate:(double)latitude longitude:(double)longitude
{
    _coordinate.latitude = latitude;
    _coordinate.longitude = longitude;
}

@end
