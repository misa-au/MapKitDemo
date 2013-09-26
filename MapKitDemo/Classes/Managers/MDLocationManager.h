#import <CoreLocation/CoreLocation.h>


#pragma mark Constants


#pragma mark - Enumerations


#pragma mark - Class Interface

@interface MDLocationManager : NSObject
<CLLocationManagerDelegate>


#pragma mark - Properties

@property (nonatomic, strong, readonly) CLLocationManager *locationManager;


#pragma mark - Constructors


#pragma mark - Static Methods

+ (MDLocationManager *)sharedInstance;


#pragma mark - Instance Methods

- (void)freeze;
- (void)unfreeze;
- (BOOL)locationServicesOnAndEnabled;

@end // @interface MDLocationManager