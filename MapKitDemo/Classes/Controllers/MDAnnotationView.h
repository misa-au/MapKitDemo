#import <MapKit/MapKit.h>
#import "MDCalloutController.h"
#import "MDWhiteCalloutController.h"
#import "MDWhiteGroupedCalloutController.h"


@protocol MDAnnotationViewDelegate <NSObject>

- (void)showDetailsForAnnotationView: (MKAnnotationView *)annotationView;
#ifdef USE_GREEN_CALLOUT
- (void)showDirectionsForAnnotationView: (MKAnnotationView *)annotationView;
#else
#ifdef SHOW_DIRECTIONS_INSTEAD_OF_PHONE
- (void)showDirectionsForAnnotationView: (MKAnnotationView *)annotationView;
#else
- (void)callForAnnotationView: (MKAnnotationView *)annotationView;
#endif
- (void)showDetailsForGroupedAnnotationView: (MKAnnotationView *)annotationView;
#endif

@end


#pragma mark Constants


#pragma mark - Enumerations


#pragma mark - Class Interface

@interface MDAnnotationView : MKAnnotationView
#if defined (USE_WHITE_CALLOUT)
<MDWhiteCalloutDelegate,
MDWhiteGroupedCalloutDelegate>
#elif defined (USE_GREEN_CALLOUT)
<MDCalloutDelegate>
#endif


#pragma mark - Properties

@property (nonatomic, weak) id<MDAnnotationViewDelegate> delegate;


#pragma mark - Constructors


#pragma mark - Static Methods


#pragma mark - Instance Methods


@end // @interface MDAnnotationView