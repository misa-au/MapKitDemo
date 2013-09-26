#import <MapKit/MapKit.h>


#pragma mark Constants


#pragma mark - Enumerations


#pragma mark - Class Interface

@interface MDGroupedAnnotation : NSObject
<MKAnnotation>


#pragma mark - Properties

@property (nonatomic, assign) NSUInteger numAnnotations;
@property (nonatomic, assign) CLLocationCoordinate2D fakeCoordinate;


#pragma mark - Constructors


#pragma mark - Static Methods


#pragma mark - Instance Methods


@end // @interface MDGroupedAnnotation