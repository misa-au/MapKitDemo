#import "MDCameraDemoController.h"
#import <MapKit/MapKit.h>


#pragma mark Constants

#define MIN_PITCH 5.f
#define MAX_PITCH 50.f
#define MIN_ALTITUDE 10.f
#define MAX_ALTITUDE 20000.f
#define DEFAULT_MAP_LATITUDUNAL_METERS 200.f
#define DEFAULT_MAP_LONGITUDUNAL_METERS 250.f


#pragma mark - Class Extension

@interface MDCameraDemoController ()
<MKMapViewDelegate,
UISearchBarDelegate>
{
    @private __strong NSString *_searchTerm;
    @private __strong NSMutableArray *_animationCameras;
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

- (void)VC_goToNextCamera;
- (void)VC_goToCoordinate: (CLLocationCoordinate2D)coord;
- (void)VC_performShortCameraAnimation: (MKMapCamera *)end;
- (void)VC_performLongCameraAnimation: (MKMapCamera *)end
    distance: (CLLocationDistance)distance;

- (void)VC_setCenter: (CLLocationCoordinate2D)centerCoordinate;

- (IBAction)VC_toggleShowBldgs: (id)sender;
- (IBAction)VC_toggleShowPointsOfInterest: (id)sender;
- (IBAction)VC_pitchChanged: (id)sender;
- (IBAction)VC_altitudeChanged: (id)sender;
- (IBAction)VC_mapTypeChanged: (UISegmentedControl *)sender;


@end // @interface MDCameraDemoController ()


#pragma mark - Class Variables


#pragma mark - Class Definition

@implementation MDCameraDemoController
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
    [super viewDidLoad];
    
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

- (void)searchBarCancelButtonClicked: (UISearchBar *)searchBar
{
    // undo any changes
    searchBar.text = _searchTerm;
    [searchBar resignFirstResponder];
}

- (void)searchBarResultsListButtonClicked: (UISearchBar *)searchBar
{
    [self searchBarSearchButtonClicked: searchBar];
}

- (void)searchBarSearchButtonClicked: (UISearchBar *)searchBar
{
    // keep track of the search term
    _searchTerm = searchBar.text;
    
    // don't do anything if there is no search term
    if (_searchTerm == nil || [_searchTerm length] == 0)
    {
        return;
    }

    // initialize the request object
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
            UIAlertView *alert = [[UIAlertView alloc]
                initWithTitle: @"Error"
                message: [[error userInfo]
                    valueForKey: NSLocalizedDescriptionKey]
                delegate: nil
                cancelButtonTitle: @"Okay" otherButtonTitles: nil];
            [alert show];
            return;
        }
        
        // get the first item from search results
        MKMapItem *topItem = [response.mapItems firstObject];
        
        // remove existing annotations and place the first search item on map
        [self.mapView removeAnnotations: self.mapView.annotations];
        [self.mapView addAnnotation: topItem.placemark];
        
        // animate the camera movement
        [self VC_goToCoordinate: topItem.placemark.coordinate];
    }];
    
    [searchBar resignFirstResponder];
}


#pragma mark - MKMapView Delegate Methods

- (void)mapView: (MKMapView *)mapView
    regionDidChangeAnimated: (BOOL)animated
{
    NSLog(@"region did change");
    
    // NOTE: if the region changes due to a user interaction, animated will be NO,
    // so we know that if it's YES it's from the code
    if (animated == YES)
    {
        [self VC_goToNextCamera];
    }
    else if (_regionSet == NO)
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
            
            // set the default region
            
            UIAlertView *alert = [[UIAlertView alloc]
                initWithTitle: @"No user location"
                message: @"Using default location instead"
                delegate: nil
                cancelButtonTitle: @"Okay" otherButtonTitles: nil];
            [alert show];
            
            [self VC_setCenter:
                CLLocationCoordinate2DMake(
                    43.6472396,
                    -79.3966252)];
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


#pragma mark - Private Methods

- (void)VC_goToNextCamera
{
    if (_animationCameras.count == 0)
    {
        return;
    }
    
    MKMapCamera *nextCamera = [_animationCameras firstObject];
    [_animationCameras removeObjectAtIndex: 0];
    [UIView animateWithDuration: 1.f
        animations: ^
        {
            self.mapView.camera = nextCamera;
        }]; // Note: do not use completion block here (use mapView:regionDidChangedAnimated: instead)
}

- (void)VC_goToCoordinate: (CLLocationCoordinate2D)coord
{
    // set up the endpoint camera
    [self.pitchSlider setValue: 5.f
        animated: YES];
    [self.altitudeSlider setValue: 500.f
        animated: YES];
    MKMapCamera *end = [MKMapCamera cameraLookingAtCenterCoordinate: coord
        fromEyeCoordinate: coord
        eyeAltitude: self.altitudeSlider.value];
        end.pitch = self.pitchSlider.value;
    
    BOOL useDistanceSmartTransition = YES;
//    CLLocationDistance distance = 0.f;
    CLLocationDistance distance = 50000.f;
    if (useDistanceSmartTransition == YES)
    {
        // figure out how far we are trying to travel
        MKMapCamera *start = self.mapView.camera;
        CLLocation *startLocation = [[CLLocation alloc]
            initWithCoordinate: start.centerCoordinate
            altitude: start.altitude
            horizontalAccuracy: 0.f
            verticalAccuracy: 0.f
            timestamp: nil];
        CLLocation *endLocation = [[CLLocation alloc]
            initWithCoordinate: end.centerCoordinate
            altitude: end.altitude
            horizontalAccuracy: 0.f
            verticalAccuracy: 0.f
            timestamp: nil];
        distance = [startLocation distanceFromLocation: endLocation];
        NSLog(@"Distance: %.0f meters", distance);
    }
    
    // determine camera animation depending on total distance
    if (distance < 2500.f)
    {
        [self.mapView setCamera: end
            animated: YES];
    }
    else if (distance < 50001.f)
    {
        [self VC_performShortCameraAnimation: end];
    }
    else
    {
        [self VC_performLongCameraAnimation: end
            distance: distance];
    }
}

- (void)VC_performShortCameraAnimation: (MKMapCamera *)end
{
    // find midpoint
    CLLocationCoordinate2D startingCoordinate = self.mapView.centerCoordinate;
    MKMapPoint startingPoint = MKMapPointForCoordinate(startingCoordinate);
    MKMapPoint endingPoint = MKMapPointForCoordinate(end.centerCoordinate);
    MKMapPoint midPoint = MKMapPointMake(
        startingPoint.x + ((endingPoint.x - startingPoint.x) / 2.f),
        startingPoint.y + ((endingPoint.y - startingPoint.y) / 2.f));

    // set up the midpoint camera
    MKMapCamera *midCamera = [MKMapCamera cameraLookingAtCenterCoordinate: end.centerCoordinate
        fromEyeCoordinate: MKCoordinateForMapPoint(midPoint)
        eyeAltitude: end.altitude * 4];
    
    // add the midpoint and endpoint cameras
    _animationCameras = [[NSMutableArray alloc]
        initWithObjects:
            midCamera,
            end,
            nil];
    
    // animate camera movement
    [self VC_goToNextCamera];
}

- (void)VC_performLongCameraAnimation: (MKMapCamera *)end
    distance: (CLLocationDistance)distance
{
    CLLocationCoordinate2D startingCoordinate = self.mapView.centerCoordinate;
    CLLocationCoordinate2D endingCoordinate = end.centerCoordinate;

    // set up the midpoint camera 1 and 2 (using distance to travel for altitude)
    MKMapCamera *midCamera1 = [MKMapCamera cameraLookingAtCenterCoordinate: startingCoordinate
        fromEyeCoordinate: startingCoordinate
        eyeAltitude: distance];
    MKMapCamera *midCamera2 = [MKMapCamera cameraLookingAtCenterCoordinate: endingCoordinate
        fromEyeCoordinate: endingCoordinate
        eyeAltitude: distance];
    
    // add the midpoint and endpoint cameras
    _animationCameras = [[NSMutableArray alloc]
        initWithObjects:
            midCamera1,
            midCamera2,
            end,
            nil];
    
    // animate camera movemenet
    [self VC_goToNextCamera];
}

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

@end // @implementation MDCameraDemoController