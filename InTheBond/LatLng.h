//
//  LatLng.h
//  InTheBond
//
//  Created by Nala on 7/1/15.
//  Copyright (c) 2015 Nala. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface LatLng : NSObject

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) NSString* name;

- (id)initWithCoordinate:(CLLocationCoordinate2D) coordinate fullName:(NSString*)name;
@end
