//
//  QuestionWithAnswersViewController.m
//  LocationProfiler
//
//  Created by Kris Fields on 9/16/12.
//  Copyright (c) 2012 Kris Fields. All rights reserved.
//

#import "QuestionWithAnswersViewController.h"
#import <RestKit/RestKit.h>

@interface QuestionWithAnswersViewController () <UITableViewDelegate, UITableViewDataSource, RKRequestDelegate>

@property (strong, nonatomic) NSArray *answers;
@property (weak, nonatomic) IBOutlet UITableView *answersTable;
@end

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation QuestionWithAnswersViewController
@synthesize answersTable;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImageView *questionWithAnswersImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg-black.png"]];
    [questionWithAnswersImageView setFrame:self.answersTable.frame];
    self.answersTable.backgroundView = questionWithAnswersImageView;
    
    [RKClient clientWithBaseURLString:@"http://localhost:3000"];
    RKClient* client = [RKClient sharedClient];
    NSDictionary* params = @{ @"show" : @true };
    [client get:[NSString stringWithFormat:@"/questions/%@.json", [self.question_data valueForKey:@"id"]] queryParameters:params delegate:self];

    // Do any additional setup after loading the view from its nib.
}
- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    if (!titleView) {
        titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.font = [UIFont fontWithName:@"didot" size:40];
        //        titleView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        
        titleView.textColor =UIColorFromRGB(0x9391AC); // Change to desired color
        
        self.navigationItem.titleView = titleView;
    }
    titleView.text = title;
    [titleView sizeToFit];
}
-(void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
    id jsonParser = [[RKParserRegistry sharedRegistry] parserForMIMEType:RKMIMETypeJSON];
    self.answers = [jsonParser objectFromString:[response bodyAsString] error:nil];
    [self.answersTable reloadData];
    
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"answers count = %d", [self.answers count]);
    return [self.answers count];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section

{
    return [self.question_data valueForKey:@"text"];
}
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 60)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    label.text = [self.question_data valueForKey:@"text"];
    label.textColor = UIColorFromRGB(0x9391AC);
    label.textAlignment = UITextAlignmentCenter;
    label.font =[UIFont fontWithName:@"didot" size:20];
    label.backgroundColor = [UIColor clearColor];
    label.adjustsFontSizeToFitWidth = YES;

    label.numberOfLines = 0;
    [label sizeToFit];
    [headerView addSubview:label];
    return headerView;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"question"];
    cell.textLabel.text = [[self.answers objectAtIndex:[indexPath row]] objectForKey:@"text"];
    cell.textLabel.opaque = NO;
    cell.textLabel.alpha = 0.6;
    cell.backgroundColor = UIColorFromRGB(0x21212B);
    cell.textLabel.textColor = UIColorFromRGB(0x9587EB);
    //    [arrayOfColors objectAtIndex:[indexPath row]];
    return cell;
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    PTCategoryViewController *categoryVC = [PTCategoryViewController new];
    //    categoryVC.categoryDetails = [self.categories objectAtIndex:[indexPath row]];
    //    [self.navigationController pushViewController:categoryVC animated:YES];
}

- (void)viewDidUnload
{
    [self setAnswersTable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
