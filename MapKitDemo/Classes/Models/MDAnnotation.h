#import <MapKit/MapKit.h>


#pragma mark Constants


#pragma mark - Enumerations


#pragma mark - Class Interface

@interface MDAnnotation : NSObject
<MKAnnotation>


#pragma mark - Properties

@property (nonatomic, strong, readonly) MKMapItem *mapItem;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *subtitle;
@property (nonatomic, assign) CLLocationDistance distance;
@property (nonatomic, strong) MKDirectionsResponse *directionsResponse;
@property (nonatomic, weak, readonly) MKRoute *firstRoute;


#pragma mark - Constructors

- (id)initWithMapItem: (MKMapItem *)mapItem;


#pragma mark - Static Methods


#pragma mark - Instance Methods


@end // @interface MDAnnotation