#import "MDCalloutController.h"


#pragma mark Constants


#pragma mark - Class Extension

@interface MDCalloutController ()
{
    @private __strong MKDistanceFormatter *_distanceFormatter;
}

@property (nonatomic, weak) IBOutlet UILabel *mainTitle;
@property (nonatomic, weak) IBOutlet UILabel *subtitle;
@property (nonatomic, weak) IBOutlet UILabel *distance;
@property (nonatomic, weak) IBOutlet UIButton *infoButton;

- (void)MD_initializeCalloutController;
- (IBAction)MD_ShowDirections;
- (IBAction)MD_ShowDetails;


@end // @interface MDCalloutController ()


#pragma mark - Class Variables


#pragma mark - Class Definition

@implementation MDCalloutController
{
}


#pragma mark - Properties

- (void)setAnnotation:(MDAnnotation *)annotation
{
    _annotation = annotation;
}


#pragma mark - Constructors

- (id)initWithDefaultNibName
{
	// abort if base initializer fails
	if ((self = [self initWithNibName: @"MDCalloutView" 
		bundle: nil]) == nil)
	{
		return nil;
	}

	[self MD_initializeCalloutController];
	return self;
}


#pragma mark - Public Methods


#pragma mark - Overridden Methods

- (void)viewWillAppear: (BOOL)animated
{
	// call base implementation
	[super viewWillAppear: animated];

	// prepare view to be displayed onscreen
    
    // set the title and subtitle label
    self.mainTitle.text = self.annotation.title;
    self.subtitle.text = self.annotation.subtitle;
    
    // set the distance label
    self.distance.text = [_distanceFormatter stringFromDistance: self.annotation.distance];
}


#pragma mark - Private Methods

- (void)MD_initializeCalloutController
{
	// create formatter for distance
    _distanceFormatter = [[MKDistanceFormatter alloc]
        init];
}

- (IBAction)MD_ShowDirections
{
    [self.delegate showDirections];
}

- (IBAction)MD_ShowDetails
{
    [self.delegate showDetails];
}


@end // @implementation MDCalloutController