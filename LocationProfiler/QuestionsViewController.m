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
#import "ProfilerStore.h"
#import "Question.h"
#import "Answer.h"
#import "UserAnswer.h"
#import "User.h"

@interface QuestionsViewController () <UITableViewDelegate, UITableViewDataSource>

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
        self.title = NSLocalizedString(@"Answer Questions", @"Answer Questions");
        self.tabBarItem.image = [UIImage imageNamed:@"icon_help.png"];
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
    
}
- (void)viewWillAppear:(BOOL)animated
{
    self.questions = [Question allObjects
                      ];
    [self.questionsTable reloadData];
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
        titleView.font = [UIFont fontWithName:@"didot" size:35];
        //        titleView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        
        titleView.textColor =UIColorFromRGB(0x9391AC); // Change to desired color
        
        self.navigationItem.titleView = titleView;
    }
    titleView.text = title;
    [titleView sizeToFit];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.questions count];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45.0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Question *question = [self.questions objectAtIndex:[indexPath row]];
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"question"];
    BOOL is_answered = NO;
    for (Answer *answer in question.answers) {
        for (UserAnswer *userAnswer in answer.userAnswers) {
            if (userAnswer.user == [ProfilerStore currentUser]) {
                is_answered = YES;
            }
        }
    }
    if (is_answered) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    cell.textLabel.text = question.text;
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.textLabel.opaque = NO;
    cell.textLabel.font = [UIFont fontWithName:@"system" size:28];
//    cell.textLabel.alpha = 0.6;
//    cell.backgroundColor = UIColorFromRGB(0x21212B);
    cell.backgroundColor = [UIColor whiteColor];
//    cell.backgroundColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:.3];
//    cell.textLabel.textColor = UIColorFromRGB(0x9587EB);
    //    [arrayOfColors objectAtIndex:[indexPath row]];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    QuestionWithAnswersViewController *questionWithAnswersVC = [QuestionWithAnswersViewController new];
    questionWithAnswersVC.questions = self.questions;
    questionWithAnswersVC.current_question_index = [indexPath row];
    [ProfilerStore fetchAnswersForQuestion:[self.questions objectAtIndex:[indexPath row]] withBlock:^{
        [self.navigationController pushViewController:questionWithAnswersVC animated:YES];
    }];
    
}
@end
