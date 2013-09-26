#import "MDAnnotation.h"
#import "MDAdjustableCalloutController.h"


@protocol MDWhiteCalloutDelegate <NSObject>

- (void)showAnnotationDetails;
- (void)call;

@end

#pragma mark Constants


#pragma mark - Enumerations


#pragma mark - Class Interface

@interface MDWhiteCalloutController : UIViewController
<MDAdjustableCalloutController>


#pragma mark - Properties

@property (nonatomic, weak) MDAnnotation *annotation;
@property (nonatomic, weak) id<MDWhiteCalloutDelegate> delegate;


#pragma mark - Constructors

- (id)initWithDefaultNibName;


#pragma mark - Static Methods


#pragma mark - Instance Methods


@end // @interface MDWhiteCalloutController