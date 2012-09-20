//
//  QuestionWithAnswersViewController.m
//  LocationProfiler
//
//  Created by Kris Fields on 9/16/12.
//  Copyright (c) 2012 Kris Fields. All rights reserved.
//

#import "QuestionWithAnswersViewController.h"
#import <RestKit/CoreData.h>
#import "ProfilerStore.h"
#import "Answer.h"
#import "Question.h"
#import "UserAnswer.h"
#import "User.h"

@interface QuestionWithAnswersViewController () <UITableViewDelegate, UITableViewDataSource>

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
    [self updateUserAnswerCount];
    self.answers = [[[self.questions objectAtIndex:self.current_question_index] answers] allObjects];
    UIImageView *questionWithAnswersImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg-black.png"]];
    [questionWithAnswersImageView setFrame:self.answersTable.frame];
    self.answersTable.backgroundView = questionWithAnswersImageView;

    // Do any additional setup after loading the view from its nib.
}
-(void)updateUserAnswerCount {
    int userAnswerCount = [[[ProfilerStore currentUser] userAnswers] count];
    self.title = [NSString stringWithFormat:@"Questions Answered: %d of %d", userAnswerCount, [self.questions count]];
    [self.navigationItem.titleView setNeedsDisplay];
}
- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    if (!titleView) {
        titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.font = [UIFont fontWithName:@"didot" size:15];
        //        titleView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        
        titleView.textColor =UIColorFromRGB(0x9391AC); // Change to desired color
        
        self.navigationItem.titleView = titleView;
    }
    titleView.text = title;
    [titleView sizeToFit];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return [self.answers count];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        return 60;
    }
    return 45.0;
}
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//
//{
//    return self.question.text;
//}
//- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 60)];
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
//    label.text = self.question.text;
//    label.textColor = UIColorFromRGB(0x9391AC);
//    label.textAlignment = UITextAlignmentCenter;
//    label.font =[UIFont fontWithName:@"didot" size:20];
//    label.backgroundColor = [UIColor clearColor];
//    label.adjustsFontSizeToFitWidth = YES;
//
//    label.numberOfLines = 0;
//    [label sizeToFit];
//    [headerView addSubview:label];
//    return headerView;
//}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"answer"];
    cell.textLabel.numberOfLines = 0;
//    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    
    cell.backgroundColor = [UIColor whiteColor];
    
    
    if ([indexPath section] == 0) {
        cell.textLabel.text = [[self.questions objectAtIndex:self.current_question_index] text];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.font = [UIFont fontWithName:@"didot" size:18];
    } else {
        BOOL is_answered = NO;
        Answer *answer = [self.answers objectAtIndex:[indexPath row]];
        for (UserAnswer *userAnswer in answer.userAnswers) {
            if (userAnswer.user == [ProfilerStore currentUser]) {
                is_answered = YES;
            }
        }
        if (is_answered) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        cell.textLabel.font = [UIFont fontWithName:@"system" size:28];
        cell.textLabel.text = answer.text;
    //    cell.textLabel.opaque = NO;
    //    cell.textLabel.alpha = 0.6;
    //    cell.backgroundColor = UIColorFromRGB(0x21212B);
//        cell.textLabel.textColor = UIColorFromRGB(0x9587EB);
        //    [arrayOfColors objectAtIndex:[indexPath row]];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //create userAnswer with correct user_id and answer_id
    if ([indexPath section] == 1) {
        for (int i=0; i < [self.answersTable numberOfRowsInSection:1]; i++) {
            UITableViewCell *newCell = [self.answersTable cellForRowAtIndexPath:[[indexPath indexPathByRemovingLastIndex] indexPathByAddingIndex: i]];
                newCell.accessoryType = UITableViewCellAccessoryNone;
        }
        [self.answersTable cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        UserAnswer *userAnswer;
        for (Answer *answer in self.answers) {
            for (UserAnswer *userPreviousAnswer in answer.userAnswers) {
                if (userPreviousAnswer.user == [ProfilerStore currentUser]) {
                    userAnswer = userPreviousAnswer;
                    userAnswer.answer_id = [[self.answers objectAtIndex:[indexPath row]] answer_id];
                }
            }
        }
        if (!userAnswer) {
            userAnswer = [UserAnswer object];
            userAnswer.user_id = [[ProfilerStore currentUser] user_id];
            userAnswer.answer_id = [[self.answers objectAtIndex:[indexPath row]] answer_id];
            [ProfilerStore saveUserAnswer:userAnswer withBlock:^{
                [self updateUserAnswerCount];
            }];
        } else {
            [ProfilerStore updateUserAnswer:userAnswer];
        }
        
        
        self.current_question_index ++;
        if (self.current_question_index < [self.questions count]) {
            self.answers = [[[self.questions objectAtIndex:self.current_question_index] answers] allObjects];
            [self.answersTable reloadData];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You've answered the last question!" message:@"Maybe you should add some more..." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
        
    }

    //post to backend
    //change self.question and reload table
    
    //    PTCategoryViewController *categoryVC = [PTCategoryViewController new];
    //    categoryVC.categoryDetails = [self.categories objectAtIndex:[indexPath row]];
    //    [self.navigationController pushViewController:categoryVC animated:YES];
}

- (void)viewDidUnload
{
    [self setAnswersTable:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
