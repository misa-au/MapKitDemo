#import "MDDirectionsTableViewCell.h"


#pragma mark Constants

NSString * const MDDirectionsTableViewCell_Identifier = @"MDDirectionsTableViewCell";


#pragma mark - Class Extension

@interface MDDirectionsTableViewCell ()

@property (nonatomic, weak) IBOutlet UILabel *stepNumber;
@property (nonatomic, weak) IBOutlet UILabel *instructions;
@property (nonatomic, weak) IBOutlet UILabel *distance;
@property (nonatomic, weak) IBOutlet UILabel *transportType;
@property (nonatomic, weak) IBOutlet UIButton *notice;

@end // @interface MDDirectionsTableViewCell ()


#pragma mark - Class Variables


#pragma mark - Class Definition

@implementation MDDirectionsTableViewCell


#pragma mark - Properties

- (void)setRouteStep: (MKRouteStep *)routeStep
{
    self.instructions.text = routeStep.instructions;
    self.distance.text = [NSString stringWithFormat:
        @"%.2f km",
        routeStep.distance / 1000.f];
    MKDirectionsTransportType transportType = routeStep.transportType;
    switch (transportType)
    {
        case MKDirectionsTransportTypeAutomobile:
            self.transportType.text = @"Driving";
        break;

        case MKDirectionsTransportTypeWalking:
            self.transportType.text = @"Walking";
        break;
        
        default:
            self.transportType.text = @"Unknown";
        break;
    }
    self.notice.hidden = (routeStep.notice == nil
        || [routeStep.notice length] == 0);
}

- (void)setStepNum: (NSUInteger)stepNum
{
    self.stepNumber.text = [NSString stringWithFormat: @"%d", stepNum];
}


#pragma mark - Public Methods


#pragma mark - Overridden Methods

- (void)setHighlighted: (BOOL)highlighted 
	animated: (BOOL)animated
{
	// call the base implementation
	[super setHighlighted: highlighted 
		animated: animated];
	
	// configure the table view cell for the highlighted state
}

- (void)setSelected: (BOOL)selected 
	animated: (BOOL)animated
{
	// call the base implementation
	[super setSelected: selected 
		animated: animated];
	
	// configure the table view cell for the selected state
}


#pragma mark - Private Methods

- (void)MD_ShowNotice
{
    UIAlertView *alert = [[UIAlertView alloc]
        initWithTitle: @"Notice"
        message: self.routeStep.notice
        delegate: nil
        cancelButtonTitle: @"Okay"
        otherButtonTitles: nil];
    [alert show];
}

@end // @implementation MDDirectionsTableViewCell