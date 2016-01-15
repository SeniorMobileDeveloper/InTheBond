//
//  MapViewController.h
//  InTheBond
//
//  Created by Nala on 6/27/15.
//  Copyright (c) 2015 Nala. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "MyViewController.h"

@interface MapViewController : MyViewController <MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate>

@end
