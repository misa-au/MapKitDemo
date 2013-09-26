#import "MDMapController.h"
#import <MapKit/MapKit.h>
#import "MDAnnotationView.h"
#import "MDAnnotation.h"
#import "MDGroupedAnnotation.h"
#import "MDDirectionsController.h"
#import "MDTableViewController.h"
#import "MDLocationManager.h"
#import <AddressBook/AddressBook.h>


// note: we use a custom segue here in order to cache/reuse the
//       destination view controller each time you select a place
//
@interface PushSegue : UIStoryboardSegue
@end

@implementation PushSegue

- (void)perform
{
    // our custom segue is being fired, push the destination view controller
    [((UIViewController *)self.sourceViewController).navigationController
        pushViewController: self.destinationViewController
        animated: YES];
}

@end


#pragma mark Constants

#define MIN_PITCH 5.f
#define MAX_PITCH 50.f
#define MIN_ALTITUDE 10.f
#define MAX_ALTITUDE 20000.f
#define DEFAULT_MAP_LATITUDUNAL_METERS 200.f
#define DEFAULT_MAP_LONGITUDUNAL_METERS 250.f


#pragma mark - Class Extension

@interface MDMapController ()
<MKMapViewDelegate,
UISearchBarDelegate>
{
    @private __strong NSString *_searchTerm;
    @private __strong MDDirectionsController *_directionsController;
    @private __strong MDTableViewController *_tableViewController;
    @private __strong PushSegue *_directionsSegue;
    @private __strong PushSegue *_tableViewSegue;
    @private BOOL _regionSet;
    @private BOOL _userLocationSet;
    @private NSUInteger _noLocationCount;
}

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UISlider *pitchSlider;
@property (nonatomic, weak) IBOutlet UISlider *altitudeSlider;
@property (nonatomic, weak) IBOutlet UILabel *pitch;
@property (nonatomic, weak) IBOutlet UILabel *altitude;

- (void)VC_setCenter: (CLLocationCoordinate2D)centerCoordinate;

- (IBAction)VC_toggleShowBldgs: (id)sender;
- (IBAction)VC_toggleShowPointsOfInterest: (id)sender;
- (IBAction)VC_pitchChanged: (id)sender;
- (IBAction)VC_altitudeChanged: (id)sender;
- (IBAction)VC_mapTypeChanged: (id)sender;

@end // @interface MDMapController ()


#pragma mark - Class Variables


#pragma mark - Class Definition

@implementation MDMapController
{
}


#pragma mark - Properties


#pragma mark - Destructor

- (void)dealloc 
{
	// nil out delegates of any instance variables
}


#pragma mark - Public Methods


#pragma mark - Overridden Methods

- (void)viewDidLoad
{
	// call base implementation
	[super viewDidLoad];
	
	// perform additional initialization after nib outlets are bound
    
    // create the directionsController and tavleViewController and reuse for later
    _directionsController = [[self storyboard]
        instantiateViewControllerWithIdentifier: @"MDDirectionsControllerID"];
    _tableViewController = [[self storyboard]
        instantiateViewControllerWithIdentifier: @"MDTableViewControllerID"];
    
    // use our custom segues to the destination view controller is reused
    _directionsSegue = [[PushSegue alloc]
        initWithIdentifier: @"directionsSegue"
        source: self destination:
        _directionsController];
    _tableViewSegue = [[PushSegue alloc]
        initWithIdentifier: @"tableViewSegue"
        source: self destination:
        _tableViewController];
    
    self.pitchSlider.minimumValue = MIN_PITCH;
    self.pitchSlider.maximumValue = MAX_PITCH;

    self.altitudeSlider.minimumValue = MIN_ALTITUDE;
    self.altitudeSlider.maximumValue = MAX_ALTITUDE;
    
    // set pitch and altitude sliders
    [self.pitchSlider setValue: 5.f animated: NO];
    [self.altitudeSlider setValue: 500.f animated: NO];
    [self VC_pitchChanged: self.pitchSlider];
    [self VC_altitudeChanged: self.altitudeSlider];
    
    // set map to show buildings and points of interests
    self.mapView.showsBuildings = YES;
    self.mapView.showsPointsOfInterest = YES;
}


#pragma mark - UISearchBar Delegate Methods

- (BOOL)searchBarShouldBeginEditing: (UISearchBar *)searchBar
{
    if (self.mapView.userLocation == nil
        || self.mapView.userLocation.location == nil)
    {
        UIAlertView *alertView = [[UIAlertView alloc]
            initWithTitle: @"No user location"
            message: @"Cannot search without user location."
            delegate: nil
            cancelButtonTitle: @"Okay"
            otherButtonTitles: nil];
        [alertView show];
        return NO;
    }
    return YES;
}

- (void)searchBarCancelButtonClicked: (UISearchBar *)searchBar
{
    searchBar.text = _searchTerm;
    [searchBar resignFirstResponder];
}

- (void)searchBarResultsListButtonClicked: (UISearchBar *)searchBar
{
    [self searchBarSearchButtonClicked: searchBar];
}

- (void)searchBarSearchButtonClicked: (UISearchBar *)searchBar
{
    _searchTerm = searchBar.text;
    
    // clear searched results if there's no text entered
    if (searchBar.text == nil
        || [searchBar.text length] == 0)
    {
        [self.mapView removeAnnotations: self.mapView.annotations];
        [searchBar resignFirstResponder];
        return;
    }

    // initialize the request object with the query and region to search
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc]
        init];
    request.naturalLanguageQuery = searchBar.text;
    request.region = self.mapView.region;
    
    // initialize the search object
    MKLocalSearch *localSearch = [[MKLocalSearch alloc]
        initWithRequest: request];
    
    // run search and display results
    [localSearch startWithCompletionHandler: ^(MKLocalSearchResponse *response, NSError *error)
    {
        if (error != nil
            || response.mapItems.count == 0)
        {
            // handle error
            UIAlertView *alertView = [[UIAlertView alloc]
                initWithTitle: @"Error"
                message: [[error userInfo]
                    valueForKey: NSLocalizedDescriptionKey]
                delegate: nil
                cancelButtonTitle: @"Okay"
                otherButtonTitles: nil];
            [alertView show];
            return;
        }
        
        CLLocation *currentLocation = self.mapView.userLocation.location;
        NSMutableArray *annotations = [NSMutableArray array];
        for (MKMapItem *item in response.mapItems)
        {
            MDAnnotation *annotation = [[MDAnnotation alloc]
                initWithMapItem: item];
            annotation.distance = [item.placemark.location distanceFromLocation: currentLocation];
            [annotations addObject: annotation];
        }
#ifndef USE_GREEN_CALLOUT
        // add (hardcoded/fake) grouped annotation
        MDGroupedAnnotation *groupedAnnotation = [[MDGroupedAnnotation alloc]
            init];
        groupedAnnotation.numAnnotations = 3;
        CLLocationCoordinate2D fakeCoord = ((MKMapItem *)[response.mapItems lastObject]).placemark.coordinate;
        groupedAnnotation.fakeCoordinate = CLLocationCoordinate2DMake(
            fakeCoord.latitude + .001f,
            fakeCoord.longitude + .001f);
        [annotations addObject: groupedAnnotation];
#endif
        [self.mapView removeAnnotations: self.mapView.annotations];
        [self.mapView showAnnotations: annotations
            animated: NO];
    }];
    
    [searchBar resignFirstResponder];
}


#pragma mark - MKMapView Delegate Methods

- (void)mapView: (MKMapView *)mapView
    regionDidChangeAnimated: (BOOL)animated
{
    MKCoordinateRegion region = mapView.region;
    NSLog(@"region did change:\n    coordinate: (%0.4f, %0.4f),\n    span(%0.4f, %0.4f)",
        region.center.latitude,
        region.center.longitude,
        region.span.latitudeDelta,
        region.span.longitudeDelta);
    
    if (_regionSet == NO)
    {
        CLLocation *userLocation = mapView.userLocation.location;
        if (userLocation == nil)
        {
            if (_userLocationSet == NO
                && _noLocationCount < 2)
            {
                _noLocationCount++;
                return;
            }
            
            // check if location services turned on for the device, and enabled for this app
            if ([[MDLocationManager sharedInstance]
                locationServicesOnAndEnabled] == YES)
            {
                // set default region
                UIAlertView *alertView = [[UIAlertView alloc]
                    initWithTitle: @"No user location"
                    message: @"Using default location instead"
                    delegate: nil
                    cancelButtonTitle: @"Okay"
                    otherButtonTitles: nil];
                [alertView show];
            
                [self VC_setCenter:
                    CLLocationCoordinate2DMake(
                        43.6472396,
                        -79.3966252)];
            }
            else
            {
                // show the approriate error message
                NSString *message;
                if ([CLLocationManager locationServicesEnabled] == YES)
                {
                    message = @"Please turn enable location services for this app";
                }
                else
                {
                    message = @"Please turn on location services on your device";
                }
                UIAlertView *alertView = [[UIAlertView alloc]
                    initWithTitle: @"Location services disabled"
                    message: message
                    delegate: nil
                    cancelButtonTitle: @"Okay"
                    otherButtonTitles: nil];
                [alertView show];
            }
        }
        else
        {
            [self VC_setCenter: mapView.userLocation.location.coordinate];
        }
    }
    else
    {
        [self.pitchSlider setValue: self.mapView.camera.pitch animated: YES];
        self.pitch.text = [NSString stringWithFormat: @"Pitch: %0.f",
            self.pitchSlider.value];
        
        [self.altitudeSlider setValue: self.mapView.camera.altitude animated: YES];
        self.altitude.text = [NSString stringWithFormat: @"Altitude: %0.f",
            self.altitudeSlider.value];
    }
    NSLog(@"debug: %@", self.mapView.camera.debugDescription);
}

- (void)mapView: (MKMapView *)mapView
    didUpdateUserLocation: (MKUserLocation *)userLocation
{
    // update the region if there is a user location
    if (self.mapView.userLocation.location != nil
        && _userLocationSet == NO)
    {
        _userLocationSet = YES;
        NSLog(@"User loc lat: %0.02f , long: %0.02f",
            userLocation.coordinate.latitude,
            userLocation.coordinate.longitude);
        
        if (_regionSet == NO)
        {
            [self VC_setCenter: userLocation.coordinate];
        }
    }
}

- (MKAnnotationView *)mapView: (MKMapView *)mapView
    viewForAnnotation: (id<MKAnnotation>)annotation
{
    // show custom annotations for search result locations
    if ([annotation isKindOfClass: [MDAnnotation class]] == YES
        || [annotation isKindOfClass: [MDGroupedAnnotation class]] == YES)
    {
        MDAnnotationView *annotationView = [[MDAnnotationView alloc]
            initWithAnnotation: annotation
            reuseIdentifier: @"MDAnnotationView"];
        annotationView.delegate = self;
        annotationView.leftCalloutAccessoryView.backgroundColor = self.mapView.tintColor;
        return annotationView;
    }
    
    // don't show any custom annotations for current location
    else
    {
        return nil;
    }
}

- (void)mapView: (MKMapView *)mapView
    didSelectAnnotationView: (MKAnnotationView *)view
{
    NSLog(@"tapped %@", view.annotation.title);
}

- (void)mapView: (MKMapView *)mapView
    didDeselectAnnotationView: (MKAnnotationView *)view
{
    NSLog(@"untapped %@", view.annotation.title);
}

- (void)mapView: (MKMapView *)mapView
    annotationView: (MKAnnotationView *)view
    calloutAccessoryControlTapped: (UIControl *)control
{
    NSLog(@"calloutAccessoryControlTapped");
    
    // Note: this is called when either the left/right accessory
    // is tapped on a standard (non-custom) callout view
#ifdef USE_DEFAULT_CALLOUT
    // call the appropriate function based on whether
    // the user tapped on the left or right callout
    id testAnnotation = view.annotation;
    if ([testAnnotation isKindOfClass: [MDAnnotation class]] == YES)
    {
        if (control == view.rightCalloutAccessoryView)
        {
            [self showDetailsForAnnotationView: view];
        }
        else if (control == view.leftCalloutAccessoryView)
        {
            [self callForAnnotationView: view];
        }
    }
    
    // right accessory on grouped annotation was tapped
    else
    {
        [self showDetailsForGroupedAnnotationView: view];
    }
#endif
}


#pragma mark - MDAnnotationView Delegate Methods

- (void)showDetailsForAnnotationView: (MDAnnotationView *)annotationView
{
    // show details of the annotation in an alertview
    id testAnnotation = annotationView.annotation;
    if ([testAnnotation isKindOfClass: [MDAnnotation class]] == YES)
    {
        MDAnnotation *annotation = (MDAnnotation *)testAnnotation;
        MKMapItem *mapItem = annotation.mapItem;
        
#if defined(OPEN_IN_MAPS) && (defined(USE_WHITE_CALLOUT) || defined(USE_DEFAULT_CALLOUT))

        // create current (hardcoded) location -- for demo purpose
        MKMapItem *currentLocationMapItem = [[MKMapItem alloc]
            initWithPlacemark:
                [[MKPlacemark alloc]
                    initWithCoordinate: self.mapView.userLocation.coordinate
                    addressDictionary:
                        [NSDictionary dictionaryWithObjectsAndKeys:
                            @"300-12 Camden Street",
                            kABPersonAddressStreetKey,
                            @"Toronto",
                            kABPersonAddressCityKey,
                            @"M5V 1V1",
                            kABPersonAddressZIPKey,
                            @"ON",
                            kABPersonAddressStateKey,
                            @"Canada",
                            kABPersonAddressCountryKey,
                            nil]]];
        currentLocationMapItem.phoneNumber = @"4163049831";
        currentLocationMapItem.name = @"Nascent Digital";
        
        // open destination in maps for directions
        [MKMapItem openMapsWithItems:
            [NSArray arrayWithObjects:
                currentLocationMapItem,
                mapItem,
                nil]
                    launchOptions:
                        [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSValue valueWithMKCoordinate: self.mapView.region.center],
                            MKLaunchOptionsMapCenterKey,
                            [NSValue valueWithMKCoordinateSpan: self.mapView.region.span],
                            MKLaunchOptionsMapSpanKey,
                            MKLaunchOptionsDirectionsModeDriving,
                            MKLaunchOptionsDirectionsModeKey,
                            [NSNumber numberWithBool: YES],
                            MKLaunchOptionsShowsTrafficKey,
                            nil]];
#else
        // parse address details
        NSDictionary *addressDictionary = annotation.mapItem.placemark.addressDictionary;
        NSMutableString *address = [[NSMutableString alloc]
            initWithCapacity: 40];
        NSArray *formattedAddressLines = addressDictionary[@"FormattedAddressLines"];
        if (formattedAddressLines != nil
            && [formattedAddressLines count] != 0)
        {
            for (NSString *line in formattedAddressLines)
            {
                [address appendFormat: @"%@\n", line];
            }
        }
        else
        {
            NSString *street = addressDictionary[@"Street"];
            NSString *city = addressDictionary[@"City"];
            NSString *state = addressDictionary[@"State"];
            NSString *zip = addressDictionary[@"ZIP"];
            address = [NSMutableString stringWithFormat:
                @"%@\n%@, %@, %@\n",
                street,
                city,
                state,
                zip];
        }
        NSString *phone = mapItem.phoneNumber;
        NSURL *url = mapItem.url;
        NSString *urlString = url == nil
            ? @"none"
            : url.absoluteString;
        NSString *sublocality = addressDictionary[@"SubLocality"];
        NSString *premises = addressDictionary[@"Premises"];
        NSString *subAdministrativeArea = addressDictionary[@"SubAdministrativeArea"];
        NSString *title = [NSString stringWithFormat:
            @"%@ in %@",
            mapItem.name,
            (sublocality != nil
                && [sublocality length] != 0)
                    ? sublocality
                    : [NSString stringWithFormat:
                        @"%@ %@",
                        premises,
                        subAdministrativeArea]];
        NSString *message = [NSString stringWithFormat:
            @"\naddress: %@\nphone: %@\nurl: %@",
            address,
            phone,
            urlString];
        UIAlertView *alertView = [[UIAlertView alloc]
            initWithTitle: title
            message: message
            delegate: nil
            cancelButtonTitle: @"Okay"
            otherButtonTitles: nil];
        [alertView show];
#ifdef DEBUG
        // print out values in the address dictionary
        for (id key in addressDictionary)
        {
            id value = addressDictionary[key];
            if ([value isKindOfClass: [NSString class]] == YES)
            {
                NSLog(@"%@ : %@", key, value);
            }
            else
            {
                Class clazz = [value class];
                NSLog(@"description of value (%@) of %@ is %@",
                    [clazz description],
                    key,
                    [value description]);
            }
        }
#endif
#endif
    }
#ifdef DEBUG
    else
    {
        NSAssert(NO, @"Should not be calling %s for grouped annotation", __PRETTY_FUNCTION__);
    }
#endif
}
#if defined (USE_GREEN_CALLOUT) || defined (SHOW_DIRECTIONS_INSTEAD_OF_PHONE)
- (void)showDirectionsForAnnotationView: (MDAnnotationView *)annotationView
{
    // show directions controller for the annotation
    id testAnnotation = annotationView.annotation;
    if ([testAnnotation isKindOfClass: [MDAnnotation class]] == YES)
    {
        MDAnnotation *annotation = (MDAnnotation *)testAnnotation;
        if (annotation.directionsResponse !=  nil)
        {
            _directionsController.destination = annotation;
            _directionsController.currentLocation = self.mapView.userLocation;
            _directionsController.initialRegion = self.mapView.region;
            [_directionsSegue perform];
        }
        else
        {
            // get the directions for each search result
            MKDirectionsRequest *request = [[MKDirectionsRequest alloc]
                init];
            request.source = [MKMapItem mapItemForCurrentLocation];
            request.destination = annotation.mapItem;
            request.requestsAlternateRoutes = NO;
            MKDirections *directions = [[MKDirections alloc]
                initWithRequest: request];
            [directions calculateDirectionsWithCompletionHandler:
                ^(MKDirectionsResponse *directionsResponse, NSError *error)
                {
                    if (error != nil)
                    {
                        NSLog(@"Error fetching distance: %@", [[error userInfo]
                            valueForKey: NSLocalizedDescriptionKey]);
                    }
                    else
                    {
                        annotation.directionsResponse = directionsResponse;
                        _directionsController.destination = annotation;
                        _directionsController.currentLocation = self.mapView.userLocation;
                        [_directionsSegue perform];
                    }
                }];
        }
    }
#ifdef DEBUG
    else
    {
        NSAssert(NO, @"Should not be showing directions for grouped annotation");
    }
#endif
}
#else
- (void)callForAnnotationView: (MKAnnotationView *)annotationView
{
    // show the call confirmation alertview
    id testAnnotation = annotationView.annotation;
    if ([testAnnotation isKindOfClass: [MDAnnotation class]] == YES)
    {
        MDAnnotation *annotation = (MDAnnotation *)testAnnotation;
        MKMapItem *mapItem = annotation.mapItem;
        [UIAlertView showMessageWithTitle: mapItem.name
            message: mapItem.phoneNumber];
    }
    else
    {
#ifdef DEBUG
        NSAssert(NO, @"Should not be calling %s for non-grouped annotation", __PRETTY_FUNCTION__);
#endif
    }
}
#endif
#ifndef USE_GREEN_CALLOUT
- (void)showDetailsForGroupedAnnotationView: (MKAnnotationView *)annotationView
{
    // show a table controller with number of rows matching
    // the number of annotations in the group
    id testAnnotation = annotationView.annotation;
    if ([testAnnotation isKindOfClass: [MDGroupedAnnotation class]] == YES)
    {
        MDGroupedAnnotation *annotation = (MDGroupedAnnotation *)testAnnotation;
        _tableViewController.numRows = annotation.numAnnotations;
        [_tableViewSegue perform];
    }
    else
    {
#ifdef DEBUG
        NSAssert(NO, @"Should not be calling %s for non-grouped annotation", __PRETTY_FUNCTION__);
#endif
    }
}
#endif

#pragma mark - Private Methods

- (void)VC_setCenter: (CLLocationCoordinate2D)centerCoordinate
{
    // set the map region
    _regionSet = YES;
    [self.mapView setRegion:
        MKCoordinateRegionMakeWithDistance(
            centerCoordinate,
            DEFAULT_MAP_LATITUDUNAL_METERS,
            DEFAULT_MAP_LONGITUDUNAL_METERS)
                animated: YES];
    
    // set the camera coordinate
    self.mapView.camera.centerCoordinate = centerCoordinate;
    
    // enable user interaction
    self.mapView.userInteractionEnabled = YES;
}

- (IBAction)VC_toggleShowBldgs: (id)sender
{
    self.mapView.showsBuildings = ((UISwitch *)sender).on;
}

- (IBAction)VC_toggleShowPointsOfInterest: (id)sender
{
    self.mapView.showsPointsOfInterest = ((UISwitch *)sender).on;
}

- (IBAction)VC_pitchChanged: (id)sender
{
    // get value from slider and update label
    CGFloat pitchValue = ((UISlider *)sender).value ;
    self.mapView.camera.pitch = pitchValue;
    self.pitch.text = [NSString stringWithFormat: @"Pitch: %0.f",
        pitchValue];
}

- (IBAction)VC_altitudeChanged: (id)sender
{
    // get value from slider and update label
    CGFloat altValue = ((UISlider *)sender).value;
    self.mapView.camera.altitude = altValue;
    self.altitude.text = [NSString stringWithFormat: @"Alt: %0.f",
        altValue];
}

- (IBAction)VC_mapTypeChanged: (id)sender
{
    // switch map types
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    switch (segmentedControl.selectedSegmentIndex)
    {
        case 0:
            self.mapView.mapType = MKMapTypeStandard;
        break;
        case 1:
            self.mapView.mapType = MKMapTypeSatellite;
        break;
        case 2:
            self.mapView.mapType = MKMapTypeHybrid;
        break;
    }
}

@end // @implementation MDMapController