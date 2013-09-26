#import "MDTableViewController.h"


#pragma mark Constants


#pragma mark - Class Extension

@interface MDTableViewController ()


@end // @interface MDTableViewController ()


#pragma mark - Class Variables


#pragma mark - Class Definition

@implementation MDTableViewController
{
}


#pragma mark - Properties


#pragma mark - Public Methods


#pragma mark - Overridden Methods

- (void)viewDidLoad
{
	// call base implementation
	[super viewDidLoad];
	
	// perform additional initialization after nib outlets are bound
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
	
	// perform any actions required when the view is displayed onscreen
    
    [self.tableView reloadData];
}

- (NSInteger)tableView: (UITableView *)tableView
    numberOfRowsInSection: (NSInteger)section
{
    return self.numRows;
}

- (UITableViewCell *)tableView: (UITableView *)tableView
    cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MDTableViewCell";
    UITableViewCell *cell = [tableView
          dequeueReusableCellWithIdentifier: cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]
          initWithStyle: UITableViewCellStyleDefault
          reuseIdentifier: cellIdentifier];
    }
    cell.textLabel.text = [NSString stringWithFormat: @"%d", indexPath.row + 1];
    return cell;
}

@end // @implementation MDTableViewController