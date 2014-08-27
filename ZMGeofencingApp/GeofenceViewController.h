//
//  GeofenceViewController.h
//  ZMGeofencingApp
//
//  Created by Makeba Zoe Malcolm on 27/08/14.
//  Copyright (c) 2014 Zoe Malcolm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface GeofenceViewController : UIViewController <CLLocationManagerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) CLLocationManager *locManager;
@property (strong, nonatomic) IBOutlet MKMapView *geoMapView;
@property (strong, nonatomic) IBOutlet UILabel *geofenceLabel;

@property (nonatomic) BOOL deferringUpdates;

@end
