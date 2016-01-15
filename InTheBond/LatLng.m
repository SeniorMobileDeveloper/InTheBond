//
//  LatLng.m
//  InTheBond
//
//  Created by Nala on 7/1/15.
//  Copyright (c) 2015 Nala. All rights reserved.
//

#import "LatLng.h"

@implementation LatLng

- (id)initWithCoordinate:(CLLocationCoordinate2D) coordinate fullName:(NSString*)name
{
    self = [super init];
    if (self){
        _coordinate = coordinate;
        _name = name;
    }
    return self;
}
@end
