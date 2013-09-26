#import <MapKit/MapKit.h>


#pragma mark Constants

extern NSString * const MDDirectionsTableViewCell_Identifier;
#define MDDirectionsTableViewCell_Height	53.0f


#pragma mark - Enumerations


#pragma mark - Class Interface

@interface MDDirectionsTableViewCell : UITableViewCell


#pragma mark - Properties

@property (nonatomic, weak) MKRouteStep *routeStep;
@property (nonatomic, assign) NSUInteger stepNum;


#pragma mark - Constructors


#pragma mark - Static Methods


#pragma mark - Instance Methods


@end // @interface MDDirectionsTableViewCell