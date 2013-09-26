#import "MDLocationManager.h"


#pragma mark Constants


#pragma mark - Class Extension

@interface MDLocationManager ()

@end // @interface MDLocationManager ()


#pragma mark - Class Variables

static MDLocationManager *_sharedInstance;
static BOOL _classInitialized = NO;


#pragma mark - Class Definition

@implementation MDLocationManager


#pragma mark - Properties

@synthesize locationManager = _locationManager;


#pragma mark - Constructors

+ (void)initialize
{
    // Create auto-release pool.
    @autoreleasepool
	{
		// Initialize class.
		if (_classInitialized == NO)
		{
			// Initialize class variables.
			_sharedInstance = [[MDLocationManager alloc]
				init];
			_classInitialized = YES;
		}
    }
}

+ (id)allocWithZone: (NSZone *)zone
{
	// Because we are creating the shared instance in the +initialize method, 
    // we can check if it exists here to know if we should alloc an instance of the class.
	if (_sharedInstance == nil)
	{
		return [super allocWithZone: zone];
	}
	else
	{
	    return [self sharedInstance];
	}
}

- (id)init
{
	// abort if base initializer fails
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	// initialize instance variables
    _locationManager = [[CLLocationManager alloc] init];
	_locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
 
    // set a movement threshold for new events.
    _locationManager.distanceFilter = 500;
    
	// return initialized instance
	return self;
}


#pragma mark - Public Methods

+ (MDLocationManager *)sharedInstance
{
	return _sharedInstance;
}

- (void)freeze
{
    [_locationManager stopUpdatingLocation];
}

- (void)unfreeze
{
    if ([self locationServicesOnAndEnabled]  == YES)
    {
        [_locationManager startUpdatingLocation];
    }
}

- (BOOL)locationServicesOnAndEnabled
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    BOOL locationServicesEnabled = [CLLocationManager locationServicesEnabled];
    return (status == kCLAuthorizationStatusAuthorized
        && locationServicesEnabled == YES);
}


#pragma mark - Overridden Methods

- (id)copyWithZone: (NSZone *)zone
{
	return self;
}


#pragma mark - CLLocationManagerDelegate Methods

- (void)locationManager: (CLLocationManager *)manager
    didChangeAuthorizationStatus: (CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorized)
    {
        [_locationManager startUpdatingLocation];
    }
}

- (void)locationManager: (CLLocationManager *)manager
    didUpdateLocations: (NSArray *)locations
{
    // If it's a relatively recent event, turn off updates to save power
   CLLocation* location = [locations lastObject];
   NSDate* eventDate = location.timestamp;
   NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
   if (abs(howRecent) < 15.0) {
      // If the event is recent, do something with it.
      NSLog(@"latitude %+.6f, longitude %+.6f\n",
              location.coordinate.latitude,
              location.coordinate.longitude);
    }
}

@end // @implementation MDLocationManager