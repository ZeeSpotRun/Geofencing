//
//  GeofenceViewController.m
//  ZMGeofencingApp
//
//  Created by Makeba Zoe Malcolm on 27/08/14.
//  Copyright (c) 2014 Zoe Malcolm. All rights reserved.
//

#import "GeofenceViewController.h"

#define BACKGROUND_COLOR [UIColor colorWithRed:245.0f/255.0f green:245.0f/255.0f blue:199.0f/255.0f alpha:1.0];
#define TEXT_COLOR [UIColor colorWithRed:5.0f/255.0f green:111.0f/255.0f blue:115.0f/255.0f alpha:1.0]

@interface GeofenceViewController ()

@end

@implementation GeofenceViewController

@synthesize locManager, geoMapView, geofenceLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createGeofenceLabel];
    NSArray *geofences = [self populateGeofenceRegions];
    [self initializeLocationManager];
    [self intializeRegionMonitoring:geofences];
    [self initializeMapView];
    
}

-(void)initializeMapView
{
    /* Setup Center of MapView */
    
    CLLocationCoordinate2D initialLocation;
    initialLocation.latitude = 40.777305;
    initialLocation.longitude = -73.922157;
    
    geoMapView.centerCoordinate = initialLocation;
    
    /* Setup MapView Region and Tracking */
    
    [geoMapView setRegion:MKCoordinateRegionMakeWithDistance(geoMapView.centerCoordinate, 500, 500) animated:YES];
    [geoMapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    
}

-(void)createGeofenceLabel
{
    /* Setup background, textColor, text alignment */
    
    geofenceLabel.backgroundColor = BACKGROUND_COLOR;
    geofenceLabel.tintColor = TEXT_COLOR;
    geofenceLabel.textAlignment = NSTextAlignmentCenter;

}


-(NSArray *)populateGeofenceRegions
{
    /* Populate Array with plist Data Array */
    
    NSString *plistPath = [[NSBundle mainBundle]pathForResource:@"Regions" ofType:@"plist"];
    NSArray *regionArray = [NSArray arrayWithContentsOfFile:plistPath];
    
    /* Populate Mutable Array with the dictionary items made up of CLCircularRegions from regionArray */
    
    NSMutableArray *createGeofences = [[NSMutableArray alloc]init];
    
    for (NSDictionary *regionDict in regionArray) {
        
        CLCircularRegion *region = [self mapDictionaryToRegion:regionDict];
        
        [createGeofences addObject:region];
    }
    
    return createGeofences;
    
}


-(CLCircularRegion *)mapDictionaryToRegion:(NSDictionary *)dictionary
{
    /* Create region "identifier" from dicitonary key: title */
    
    NSString *title = [dictionary objectForKey:@"title"];
    
    /* Create region "center" from dictionary keys: latitude and longitude */
    
    CLLocationDegrees latitude = [[dictionary objectForKey:@"latitude"] doubleValue];
    CLLocationDegrees longitude = [[dictionary objectForKey:@"longitude"] doubleValue];
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(latitude, longitude);
    
    /* Create region "radius" from dictionary key: radius */
    
    CLLocationDistance radius = [[dictionary objectForKey:@"radius"] doubleValue];

    CLCircularRegion *initRegion = [[CLCircularRegion alloc]initWithCenter:center radius:radius identifier:title];
    
    /* return CLCircularRegion to add to array of GeoFences */
    
    return initRegion;
}


-(void)initializeLocationManager
{
    locManager = [[CLLocationManager alloc]init];
    [locManager setDelegate:self];
    
    if ([CLLocationManager locationServicesEnabled]==FALSE ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        [self showLocationManagerErrorAlert:@"Enable location services on your phone settings to take full advantage of Geofence App."
                                  withTitle:@"Location Servcies Disabled"];
        
    }
    
}


-(void)intializeRegionMonitoring:(NSArray *)geofences
{
    /* Check that location manager has been initialized */
    
    if (locManager == nil) {
        
        [NSException raise:@"Location Manager not initialized."
                    format:@"To proceed, please initialize location manager."];
        
    }
    
        /* ====================================FIGURE OUT HOW TO MONITOR REGIONS ===================================================== */
    
    if ([CLLocationManager locationServicesEnabled]==FALSE ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        
        [self showLocationManagerErrorAlert:@"If you would like LocalSeasional to send you produce location, enable location services on your phone settings."
                                  withTitle:@"Location Servcies Disabled"];

        
        
    } else if (UIApplication.sharedApplication.backgroundRefreshStatus != UIBackgroundRefreshStatusAvailable) {
        
        [self showLocationManagerErrorAlert:@"Enable App Refresh in phone settings, if you would like to access apps full capabilities."
                                  withTitle:@"Background Location Services Disabled"];
        
        
    }

    
    /* start monitoring for each CLCircularRegion in geofences Array */
    
    for (CLCircularRegion *monitorRegion in geofences) {
        
        [locManager startMonitoringForRegion:monitorRegion];
        NSLog(@"Region Monitoring is Enabled.");
        
    }
    
    
}



#pragma mark - Location Manager - Region Task Methods

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    
    geofenceLabel.text = [NSString stringWithFormat:@"Entered Region - %@", region.identifier];
    [self showRegionAlert:@"Entering Region" forRegion:region.identifier];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    
    geofenceLabel.text = [NSString stringWithFormat:@"Exited Region - %@", region.identifier];
    [self showRegionAlert:@"Exiting Region" forRegion:region.identifier];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    
    geofenceLabel.text = [NSString stringWithFormat:@"Monitoring Regions"];
    NSLog(@"Started monitoring %@ region", region.identifier);
}



#pragma mark CLLocationManager Delegate methods

-(void)locationManager:(CLLocationManager *)locationManager didUpdateLocations:(NSArray *)locations
{
    
    /* Allow location manager to defer updates, based on "Active" or "Background" status */
    
    CLLocation *newLocation = [locations lastObject];
    
    if (self.deferringUpdates) {
        if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive) {
            
            NSLog(@"ACTIVE========== %@", newLocation);
            [locationManager allowDeferredLocationUpdatesUntilTraveled:CLLocationDistanceMax timeout:60];
            
        } else {
            NSLog(@"BACKGROUND========== %@", newLocation);
            [locationManager allowDeferredLocationUpdatesUntilTraveled:CLLocationDistanceMax timeout:180];
        }
    }
    
    
    /* start deferring updates */
    
    geoMapView.centerCoordinate = newLocation.coordinate;
    
    self.deferringUpdates = YES;
}

-(void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error
{
    
    NSLog(@"Location Manager did finish deferred updates with error: %@", [error localizedDescription]);
    self.deferringUpdates = NO;
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
    NSLog(@"Location Manager DId Fail:%@", [error localizedDescription]);
    
}



#pragma mark - Show Alert Methods

-(void)showRegionAlert:(NSString *)message forRegion:(NSString*)region
{
    NSString *messageString = [NSString stringWithFormat:@"%@: %@", message, region];
    
    UIAlertView *regionAlert = [[UIAlertView alloc]initWithTitle:@"Region Alert" message:messageString delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    [regionAlert show];
}

-(void)showLocationManagerErrorAlert:(NSString *)messageText withTitle:(NSString *)titleText
{
    
    UIAlertView *locationManagerErrorAlert = [[UIAlertView alloc]initWithTitle:titleText message:messageText delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    [locationManagerErrorAlert show];
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

@end
