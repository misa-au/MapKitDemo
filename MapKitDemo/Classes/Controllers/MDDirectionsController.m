#import "MDDirectionsController.h"
#import "MDDirectionsTableViewCell.h"
#import "MDAnnotation.h"
#import "MDAnnotationView.h"


#pragma mark Constants


#pragma mark - Class Extension

@interface MDDirectionsController ()
<MKMapViewDelegate>
{
    @private __strong MKDistanceFormatter *_distancFormatter;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UILabel *address;
@property (nonatomic, weak) IBOutlet UILabel *routeName;
@property (nonatomic, weak) IBOutlet UILabel *distAndTime;
@property (nonatomic, weak, readonly) MKRoute *route;

- (void)VC_updateRoute;
- (void)VC_clearRoute;
- (void)VC_openInMaps;

@end // @interface MDDirectionsController ()


#pragma mark - Class Variables


#pragma mark - Class Definition

@implementation MDDirectionsController
{
}


#pragma mark - Properties

- (MKRoute *)route
{
    return self.destination.firstRoute;
}


#pragma mark - Constructors


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
	
	// create formatter for distance
    _distancFormatter = [[MKDistanceFormatter alloc]
        init];
    
    // add the open in maps button to navigation bar
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
        initWithTitle: @"Maps"
        style: UIBarButtonItemStyleDone
        target: self
        action: @selector(VC_openInMaps)];
}

- (void)viewWillAppear: (BOOL)animated
{
	// call base implementation
	[super viewWillAppear: animated];

	// prepare view to be displayed onscreen
    self.navigationItem.title = self.destination.title;
}

- (void)viewDidAppear: (BOOL)animated
{
	// call base implementation
	[super viewDidAppear: animated];
    
    // start showing user location
    self.mapView.showsUserLocation = YES;
    
    // update the route to show on the map
    [self VC_updateRoute];
}

- (void)viewWillDisappear: (BOOL)animated
{
	// call base implementation
	[super viewWillDisappear: animated];

	// prepare view to be moved offscreen
}

- (void)viewDidDisappear: (BOOL)animated
{
	// call base implementation
	[super viewDidDisappear: animated];
	
    // stop showing user location
    self.mapView.showsUserLocation = NO;

    // clear the route
    [self VC_clearRoute];
}

- (void)didReceiveMemoryWarning
{
	// call base implementation
	[super didReceiveMemoryWarning];
	
	// free up any memory that can be recreated easily
}


#pragma mark - MKMapView Delegate Methods

- (MKAnnotationView *)mapView: (MKMapView *)mapView
    viewForAnnotation: (id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass: [MDAnnotation class]] == YES)
    {
        MDAnnotationView *annotationView = [[MDAnnotationView alloc]
            initWithAnnotation: annotation
            reuseIdentifier: @"MDAnnotationView"];
        annotationView.enabled = NO;
        return annotationView;
    }
    else
    {
        return nil;
    }
}

- (MKOverlayRenderer *)mapView: (MKMapView *)mapView
    rendererForOverlay: (id<MKOverlay>)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc]
        initWithOverlay: overlay];
    renderer.strokeColor = [mapView.tintColor
        colorWithAlphaComponent: 0.7f];
    return renderer;
}


#pragma mark - UITableView Delegate Methods

- (NSInteger)tableView: (UITableView *)tableView
    numberOfRowsInSection: (NSInteger)section
{
    // return number of steps as number of rows
    return self.route != nil
        ? [self.route.steps count]
        : 0;
}

- (CGFloat)tableView: (UITableView *)tableView
    heightForRowAtIndexPath: (NSIndexPath *)indexPath
{
    return MDDirectionsTableViewCell_Height;
}

- (UITableViewCell *)tableView: (UITableView *)tableView
    cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    MDDirectionsTableViewCell *cell = [tableView
          dequeueReusableCellWithIdentifier: MDDirectionsTableViewCell_Identifier];
    if (cell == nil)
    {
        cell = [[MDDirectionsTableViewCell alloc]
          initWithStyle: UITableViewCellStyleDefault
          reuseIdentifier: MDDirectionsTableViewCell_Identifier];
    }
    
    // set the route step and number
    MKRouteStep *routeStep = self.route.steps[indexPath.row];
    cell.routeStep = routeStep;
    cell.stepNum = indexPath.row + 1;
    
    return cell;
}


#pragma mark - Private Methods

- (void)VC_updateRoute
{
    // set the map region based on source and destination
    self.mapView.region = self.initialRegion;
    
    // draw the route polyline on the map
    [self.mapView addOverlay: self.route.polyline
        level: MKOverlayLevelAboveRoads];
    
    // add some padding
    static float inset = 20.f;
    [self.mapView setVisibleMapRect: self.route.polyline.boundingMapRect
        edgePadding:
            UIEdgeInsetsMake(inset, inset, inset, inset)
                animated: YES];
    
    // place source and destination on map
    MKPlacemark *currentPlacemark = [[MKPlacemark alloc]
        initWithCoordinate: self.currentLocation.coordinate addressDictionary: nil];
    [self.mapView addAnnotations:
        [NSArray arrayWithObjects:
            currentPlacemark,
            self.destination,
            nil]];
    
    // set the address label
    self.address.text = self.destination.mapItem.placemark.addressDictionary[@"Street"];
    
    // set the route name
    self.routeName.text = [NSString stringWithFormat:
        @"Directions via %@",
        self.route.name];
    
    // set distance and arrival time
    self.distAndTime.text = [NSString stringWithFormat:
        @"%@ - Arrive @ %.0f minutes",
        [_distancFormatter stringFromDistance: self.route.distance],
        self.route.expectedTravelTime / 60.f];
    
    // load the tableview of directions
    [self.tableView reloadData];
}

- (void)VC_clearRoute
{
    // remove route polyline
    [self.mapView removeOverlay: self.route.polyline];
    
	// remove added annotations
    [self.mapView removeAnnotations: self.mapView.annotations];
    
    // clear route name
    self.address.text = nil;
    self.routeName.text = nil;
    self.distAndTime.text = nil;
    
    // clear table
    [self.tableView reloadData];
}

- (void)VC_openInMaps
{
    [MKMapItem openMapsWithItems:
        [NSArray arrayWithObjects:
            [MKMapItem mapItemForCurrentLocation],
            self.destination.mapItem,
            nil]
                launchOptions:
                    [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSValue valueWithMKCoordinate: self.mapView.region.center],
                        MKLaunchOptionsMapCenterKey,
                        [NSValue valueWithMKCoordinateSpan: self.mapView.region.span],
                        MKLaunchOptionsMapSpanKey,
                        MKLaunchOptionsDirectionsModeWalking,
                        MKLaunchOptionsDirectionsModeKey,
                        [NSNumber numberWithBool: YES],
                        MKLaunchOptionsShowsTrafficKey,
                        nil]];
}

@end // @implementation MDDirectionsController