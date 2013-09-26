#import "MDWhiteGroupedCalloutController.h"
#import "MDGroupedAnnotation.h"


#pragma mark Constants

#define LEFT_BUBBLE_PADDING 19.f


#pragma mark - Class Extension

@interface MDWhiteGroupedCalloutController ()

@property (nonatomic, weak) IBOutlet UIImageView *leftBubble;
@property (nonatomic, weak) IBOutlet UIImageView *middleBubble;
@property (nonatomic, weak) IBOutlet UIImageView *rightBubble;
@property (nonatomic, weak) IBOutlet UILabel *mainText;
@property (nonatomic, weak) IBOutlet UILabel *subText;

- (IBAction)MD_showGroupedAnnotationDetails;


@end // @interface MDWhiteGroupedCalloutController ()


#pragma mark - Class Variables


#pragma mark - Class Definition

@implementation MDWhiteGroupedCalloutController
{
}

@synthesize anchorXDelta = _anchorXDelta;

#pragma mark - Properties


#pragma mark - Constructors

- (id)initWithDefaultNibName
{
	// abort if base initializer fails
	if ((self = [self initWithNibName: @"MDWhiteGroupedCalloutView"
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

- (IBAction)MD_showGroupedAnnotationDetails
{
    [self.delegate showGroupedAnnotationDetails];
}

@end // @implementation MDWhiteGroupedCalloutController