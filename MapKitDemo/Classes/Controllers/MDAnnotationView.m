#import "MDAnnotationView.h"


#pragma mark Constants

#define EXPANDED_ARROW_HEIGHT 46.f
#define EXPANDED_PIN_HEIGHT 40.f


#pragma mark - Class Extension

@interface MDAnnotationView ()
{
#ifdef USE_WHITE_CALLOUT
    @private __strong MDWhiteCalloutController *_calloutController;
    @private __strong MDWhiteGroupedCalloutController *_groupedCalloutController;
#else
    @private __strong MDCalloutController *_calloutController;
#endif
    @private BOOL _useCustomCallout;
}

#ifdef USE_WHITE_CALLOUT
@property (nonatomic, strong, readonly) UIViewController<MDAdjustableCalloutController> *calloutController;
#else
@property (nonatomic, strong, readonly) MDCalloutController *calloutController;
#endif

@end // @interface MDAnnotationView ()


#pragma mark - Class Variables


#pragma mark - Class Definition

@implementation MDAnnotationView


#pragma mark - Properties

#if defined (USE_WHITE_CALLOUT)
- (UIViewController<MDAdjustableCalloutController> *)calloutController
{
    if ([self.annotation isKindOfClass:
            [MDGroupedAnnotation class]] == YES)
    {
        if (_groupedCalloutController == nil)
        {
            _groupedCalloutController = [[MDWhiteGroupedCalloutController alloc]
                initWithDefaultNibName];
            _groupedCalloutController.annotation = (MDGroupedAnnotation *)self.annotation;
            _groupedCalloutController.delegate = self;
        }
        return _groupedCalloutController;
    }
    else
    {
        if (_calloutController == nil)
        {
            _calloutController = [[MDWhiteCalloutController alloc]
                initWithDefaultNibName];
            _calloutController.annotation = (MDAnnotation *)self.annotation;
            _calloutController.delegate = self;
        }
        return _calloutController;
    }
}

#else
#ifdef USE_GREEN_CALLOUT
- (MDCalloutController *)calloutController
{
    if (_calloutController == nil)
    {
        _calloutController = [[MDCalloutController alloc]
            initWithDefaultNibName];
        _calloutController.annotation = (MDAnnotation *)self.annotation;
        _calloutController.delegate = self;
    }
    return _calloutController;
}
#endif
#endif


#pragma mark - Constructors

- (id)initWithAnnotation: (id<MKAnnotation>)annotation
    reuseIdentifier: (NSString *)reuseIdentifier
{
    self = [super initWithAnnotation: annotation
        reuseIdentifier: reuseIdentifier];

    if ([annotation isKindOfClass: [MDGroupedAnnotation class]] == YES)
    {
        MDGroupedAnnotation *groupedAnnotation = (MDGroupedAnnotation *)annotation;
        UIImageView *badgeImage = [[UIImageView alloc]
            initWithImage: [UIImage
            imageNamed: @"iphone-results-icon-map-badge"]];
        CGRect badgeFrame = badgeImage.frame;
        UILabel *label = [[UILabel alloc]
            initWithFrame: badgeFrame];
        label.text = [NSString stringWithFormat: @"%d", groupedAnnotation.numAnnotations];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName: @"Noteworthy-Bold"
            size: 8.f];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        [badgeImage addSubview: label];
        badgeImage.frame = CGRectOffset(badgeFrame, 25.f, -4.f);
        [self addSubview: badgeImage];
    }
    
#ifndef USE_DEFAULT_CALLOUT
    _useCustomCallout = YES;
#endif

    if (_useCustomCallout == YES)
    {
#ifdef USE_WHITE_CALLOUT
        self.image = [UIImage imageNamed: @"iphone-coffee-icon-map-pin"];
#else
        self.image = [UIImage imageNamed: @"physicians-map-physicianpin"];
#endif
        self.canShowCallout = NO;
    }
    else
    {
        self.image = [UIImage imageNamed: @"iphone-results-icon-map-pin"];
        self.canShowCallout = YES;
        
        if ([annotation isKindOfClass: [MDGroupedAnnotation class]] == YES)
        {
            UIButton *button = [UIButton buttonWithType: UIButtonTypeDetailDisclosure];
            self.rightCalloutAccessoryView = button;
        }
        else
        {
            UIButton *button = [UIButton buttonWithType: UIButtonTypeDetailDisclosure];
            self.rightCalloutAccessoryView = button;
            
            UIImage *image = [UIImage imageNamed: @"iphone-results-icon-map-phone"];
            UIButton *leftButton = [UIButton buttonWithType: UIButtonTypeCustom];
            leftButton.frame = CGRectMake(0.f, 0.f, 45.f, 45.f);
            [leftButton setImage: image
                forState: UIControlStateNormal];
            self.leftCalloutAccessoryView = leftButton;
        }
    }
    
    return self;
}


#pragma mark - Public Methods


#if defined (USE_WHITE_CALLOUT)
#pragma mark - MDWhiteCallout Delegate Methods

- (void)showAnnotationDetails
{
    [self.delegate showDetailsForAnnotationView: self];
}

- (void)call
{
#if defined SHOW_DIRECTIONS_INSTEAD_OF_PHONE
    [self.delegate showDirectionsForAnnotationView: self];
#else
    [self.delegate callForAnnotationView: self];
#endif
}

#pragma mark - MDWhiteGroupedCallout Delegate Methods

- (void)showGroupedAnnotationDetails
{
    [self.delegate showDetailsForGroupedAnnotationView: self];
}

#else
#ifdef USE_GREEN_CALLOUT
#pragma mark - MDCallout Delegate Methods

- (void)showDetails
{
    [self.delegate showDetailsForAnnotationView: self];
}

- (void)showDirections
{
    [self.delegate showDirectionsForAnnotationView: self];
}
#endif
#endif


#pragma mark - Overridden Methods

- (void)setSelected: (BOOL)selected
{
    [super setSelected: selected];
    
    if (_useCustomCallout == YES)
    {
#ifdef USE_WHITE_CALLOUT
        UIView *calloutView = self.calloutController.view;
        if (selected)
        {
            CGFloat halfScreenWidth =  160.f;
            CGPoint annotationCenter = self.center;

            calloutView.center = CGPointMake(
                halfScreenWidth - (annotationCenter.x - self.frame.size.width * 0.5f),
                -calloutView.frame.size.height * 0.5f);
            
            CGFloat anchorX = annotationCenter.x - halfScreenWidth;
            ((UIViewController<MDAdjustableCalloutController> *)self.calloutController)
                .anchorXDelta = anchorX;

            calloutView = self.calloutController.view;
#else
        UIView *calloutView = self.calloutController.view;
        if (selected)
        {
            CGRect annotationBounds = self.bounds;
            CGRect calloutViewFrame = calloutView.frame;
            calloutView.center = CGPointMake(
                annotationBounds.size.width * 0.5f - 4.f,
                calloutViewFrame.size.height * 0.5f);
#endif
            [self addSubview: calloutView];
        }
        else
        {
            [calloutView removeFromSuperview];
        }
    }
}

- (UIView *)hitTest: (CGPoint)point
    withEvent: (UIEvent *)event
{
    NSEnumerator *reverseE = [self.subviews reverseObjectEnumerator];
    UIView *iSubView;
    while ((iSubView = [reverseE nextObject]))
    {

        UIView *viewWasHit = [iSubView hitTest:
            [self convertPoint: point
                toView: iSubView]
                    withEvent:event];
        if (viewWasHit)
        {
            return viewWasHit;
        }

    }
    return [super hitTest: point
        withEvent: event];
}


@end // @implementation MDAnnotationView