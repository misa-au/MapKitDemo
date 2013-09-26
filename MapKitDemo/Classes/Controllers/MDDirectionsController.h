#import <MapKit/MapKit.h>
@class MDAnnotation;


#pragma mark Constants


#pragma mark - Enumerations


#pragma mark - Class Interface

@interface MDDirectionsController : UIViewController
<UITableViewDataSource, UITableViewDelegate>


#pragma mark - Properties

@property (nonatomic, assign) MKUserLocation *currentLocation;
@property (nonatomic, weak) MDAnnotation *destination;
@property (nonatomic, assign) MKCoordinateRegion initialRegion;


#pragma mark - Constructors


#pragma mark - Static Methods


#pragma mark - Instance Methods


@end // @interface MDDirectionsController