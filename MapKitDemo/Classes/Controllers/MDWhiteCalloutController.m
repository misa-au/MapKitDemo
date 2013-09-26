#import "MDWhiteCalloutController.h"
#import "MDAnnotation.h"
#import "MDGroupedAnnotation.h"


#pragma mark Constants

#define LEFT_BUBBLE_PADDING 45.f


#pragma mark - Class Extension

@interface MDWhiteCalloutController ()

@property (nonatomic, weak) IBOutlet UIImageView *leftBubble;
@property (nonatomic, weak) IBOutlet UIImageView *middleBubble;
@property (nonatomic, weak) IBOutlet UIImageView *rightBubble;
@property (nonatomic, weak) IBOutlet UIButton *leftButton;
@property (nonatomic, weak) IBOutlet UILabel *mainText;
@property (nonatomic, weak) IBOutlet UILabel *subText;

- (IBAction)MD_call;
- (IBAction)MD_showAnnotationDetails;


@end // @interface MDWhiteCalloutController ()


#pragma mark - Class Variables


#pragma mark - Class Definition

@implementation MDWhiteCalloutController
{
}


@synthesize anchorXDelta = _anchorXDelta;


#pragma mark - Properties


#pragma mark - Constructors

- (id)initWithDefaultNibName
{
	// abort if base initializer fails
	if ((self = [self initWithNibName: @"MDWhiteCalloutView"
		bundle: nil]) == nil)
	{
		return nil;
	}

	// return initialized instance
	return self;
}


#pragma mark - Public Methods


#pragma mark - Overridden Methods

- (void)viewDidLoad
{
	// call base implementation
	[super viewDidLoad];
	
	// perform additional initialization after nib outlets are bound
    

#if defined SHOW_DIRECTIONS_INSTEAD_OF_PHONE
    [self.leftButton setImage: [UIImage imageNamed: @"iphone-common-btn-get-directions-white"]
        forState: UIControlStateNormal];
#endif
    self.leftBubble.image = [self.leftBubble.image resizableImageWithCapInsets:
        UIEdgeInsetsMake(1.f, 9.f, 1.f, 1.f)
            resizingMode: UIImageResizingModeTile];

    
    [self.mainText setFont:
        [UIFont fontWithName: @"Noteworthy-Bold"
            size: 18.f]];
    
    [self.subText setFont:
        [UIFont fontWithName: @"Papyrus"
            size: 12.f]];
}

- (void)viewWillAppear: (BOOL)animated
{
	// call base implementation
	[super viewWillAppear: animated];

	// prepare view to be displayed onscreen
}

- (void)viewDidAppear: (BOOL)animated
{
	// call base implementation
	[super viewDidAppear: animated];
    
    // set the main and sub text
    self.mainText.text = self.annotation.title;
    self.subText.text = self.annotation.subtitle;

    // adjust the bubble anchor and frame if necessary
    CGPoint middleBubbleCenter = self.middleBubble.center;
    middleBubbleCenter.x = self.view.bounds.size.width * 0.5f + self.anchorXDelta;
    self.middleBubble.center = middleBubbleCenter;
    CGFloat middleBubbleEnd = self.middleBubble.frame.origin.x + self.middleBubble.frame.size.width;
    CGFloat rightBubbleOverlap = self.rightBubble.frame.origin.x - (middleBubbleEnd - 4.f);
    
    CGFloat delta = 0.f;
    if (rightBubbleOverlap < 0)
    {
        delta = rightBubbleOverlap;
    }
    else if (middleBubbleCenter.x < LEFT_BUBBLE_PADDING)
    {
        delta = LEFT_BUBBLE_PADDING - self.middleBubble.frame.origin.x;
    }

    if (delta != 0)
    {
        middleBubbleCenter.x += delta;
        self.view.frame = CGRectOffset(self.view.frame, -delta, 0.f);
        self.middleBubble.center = middleBubbleCenter;
    }
}


#pragma mark - Private Methods

- (IBAction)MD_call
{
    [self.delegate call];
}

- (IBAction)MD_showAnnotationDetails
{
    [self.delegate showAnnotationDetails];
}

@end // @implementation MDWhiteCalloutController