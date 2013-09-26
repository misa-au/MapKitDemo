#import "MDAnnotation.h"


@protocol MDCalloutDelegate <NSObject>

- (void)showDetails;
- (void)showDirections;

@end


#pragma mark Constants


#pragma mark - Enumerations


#pragma mark - Class Interface

@interface MDCalloutController : UIViewController


#pragma mark - Properties

@property (nonatomic, strong) MDAnnotation *annotation;
@property (nonatomic, weak) id<MDCalloutDelegate> delegate;


#pragma mark - Constructors

- (id)initWithDefaultNibName;


#pragma mark - Static Methods


#pragma mark - Instance Methods


@end // @interface MDCalloutController