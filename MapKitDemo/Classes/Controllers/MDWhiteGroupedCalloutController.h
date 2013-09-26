#import "MDGroupedAnnotation.h"
#import "MDAdjustableCalloutController.h"


@protocol MDWhiteGroupedCalloutDelegate <NSObject>

- (void)showGroupedAnnotationDetails;

@end

#pragma mark Constants


#pragma mark - Enumerations


#pragma mark - Class Interface

@interface MDWhiteGroupedCalloutController : UIViewController
<MDAdjustableCalloutController>


#pragma mark - Properties

@property (nonatomic, weak) MDGroupedAnnotation *annotation;
@property (nonatomic, weak) id<MDWhiteGroupedCalloutDelegate> delegate;


#pragma mark - Constructors

- (id)initWithDefaultNibName;


#pragma mark - Static Methods


#pragma mark - Instance Methods


@end // @interface MDWhiteGroupedCalloutController