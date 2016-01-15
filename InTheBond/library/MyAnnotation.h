//
//  MyAnnotation.h
//  InTheBond
//
//  Created by Nala on 6/29/15.
//  Copyright (c) 2015 Nala. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>

@interface MyAnnotation : NSObject <MKAnnotation>
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;

- (void)setTitle:(NSString *)title;
- (void)setCoordinate:(double)latitude longitude:(double)longitude
;@end
