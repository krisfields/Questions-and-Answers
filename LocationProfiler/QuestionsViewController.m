//
//  QuestionsViewController.m
//  LocationProfiler
//
//  Created by Kris Fields on 9/9/12.
//  Copyright (c) 2012 Kris Fields. All rights reserved.
//

#import "QuestionsViewController.h"
#import <RestKit/RestKit.h>
#import "QuestionWithAnswersViewController.h"


@interface QuestionsViewController () <UITableViewDelegate, UITableViewDataSource, RKRequestDelegate>

@property (strong, nonatomic) NSArray *questions;
@property (weak, nonatomic) IBOutlet UITableView *questionsTable;
@end

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation QuestionsViewController
@synthesize questionsTable = _questionsTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Questions", @"Questions");
        self.tabBarItem.image = [UIImage imageNamed:@"pencil.png"];
        [[UITabBar appearance] setSelectedImageTintColor:[UIColor purpleColor]];
        [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
        [[self tabBarItem] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   [UIColor whiteColor], UITextAttributeTextColor,
                                                   nil] forState:UIControlStateNormal];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *questionsImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg-black.png"]];
    [questionsImageView setFrame:self.questionsTable.frame];
    
    self.questionsTable.backgroundView = questionsImageView;
    
    [RKClient clientWithBaseURLString:@"http://localhost:3000"];
    RKClient* client = [RKClient sharedClient];
    client.username = @"user@example.com";
    client.password = @"please";
    [client get:@"/questions.json" queryParameters:nil delegate:self];
}

- (void)viewDidUnload
{
    [self setQuestionsTable:nil];
    [super viewDidUnload];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    self.questions = [jsonParser objectFromString:[response bodyAsString] error:nil];
    [self.questionsTable reloadData];
    
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"questions count = %d", [self.questions count]);
    return [self.questions count];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"question"];
    cell.textLabel.text = [[self.questions objectAtIndex:[indexPath row]] objectForKey:@"text"];
    cell.textLabel.opaque = NO;
    cell.textLabel.alpha = 0.6;
    cell.backgroundColor = UIColorFromRGB(0x21212B);
    cell.textLabel.textColor = UIColorFromRGB(0x9587EB);
    //    [arrayOfColors objectAtIndex:[indexPath row]];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    QuestionWithAnswersViewController *questionWithAnswersVC = [QuestionWithAnswersViewController new];
    questionWithAnswersVC.question_data = [self.questions objectAtIndex:[indexPath row]];
    [self.navigationController pushViewController:questionWithAnswersVC animated:YES];
}
@end
