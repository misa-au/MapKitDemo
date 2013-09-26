#import "MDAnnotation.h"


#pragma mark Constants


#pragma mark - Class Extension

@interface MDAnnotation ()

@end // @interface MDAnnotation ()


#pragma mark - Class Variables


#pragma mark - Class Definition

@implementation MDAnnotation


#pragma mark - Properties

- (MKRoute *)firstRoute
{
    return _directionsResponse == nil
            || [_directionsResponse.routes count] == 0
                ? nil
                : _directionsResponse.routes[0];
}


#pragma mark - Constructors

- (id)initWithMapItem: (MKMapItem *)mapItem
{
	// abort if base initializer fails
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	// initialize instance variables
    _mapItem = mapItem;
    _coordinate = mapItem.placemark.coordinate;
    _title = mapItem.name;
    NSDictionary *addressDictionary = mapItem.placemark.addressDictionary;
    _subtitle = addressDictionary[@"Street"];
	
	// return initialized instance
	return self;
}


#pragma mark - Public Methods


#pragma mark - Overridden Methods


#pragma mark - Private Methods


@end // @implementation MDAnnotation