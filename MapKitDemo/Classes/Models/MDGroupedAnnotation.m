#import "MDGroupedAnnotation.h"


#pragma mark Constants


#pragma mark - Class Extension

@interface MDGroupedAnnotation ()

@end // @interface MDGroupedAnnotation ()


#pragma mark - Class Variables


#pragma mark - Class Definition

@implementation MDGroupedAnnotation


#pragma mark - Properties

- (CLLocationCoordinate2D)coordinate
{
    return self.fakeCoordinate;
}

- (NSString *)title
{
    return [NSString stringWithFormat: @"%d Grouped Annotations", self.numAnnotations];
}

- (NSString *)subtitle
{
    return @"See list";
}


#pragma mark - Constructors

- (id)init
{
	// abort if base initializer fails
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	// initialize instance variables
	
	// return initialized instance
	return self;
}


#pragma mark - Public Methods


#pragma mark - Overridden Methods


#pragma mark - Private Methods


@end // @implementation MDGroupedAnnotation