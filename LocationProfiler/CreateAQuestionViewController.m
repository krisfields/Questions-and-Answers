//
//  CreateAQuestionViewController.m
//  LocationProfiler
//
//  Created by Kris Fields on 9/17/12.
//  Copyright (c) 2012 Kris Fields. All rights reserved.
//

#import "CreateAQuestionViewController.h"
#import "ProfilerStore.h"
#import "Question.h"
#import "Answer.h"
#import <RestKit/CoreData.h>

@interface CreateAQuestionViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) UITextField *question;
@property (nonatomic, strong) NSMutableArray *answerTextFields;

@end

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation CreateAQuestionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Add a Question";
        self.tabBarItem.image = [UIImage imageNamed:@"icon_add.png"];
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
    self.answerTextFields = [NSMutableArray new];
    UIImageView *createAQuestionImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg-black.png"]];
    [createAQuestionImageView setFrame:self.tableView.frame];
    self.tableView.backgroundView = createAQuestionImageView;
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
        
        titleView.textColor =UIColorFromRGB(0x9391AC); // Change to desired color
        
        self.navigationItem.titleView = titleView;
    }
    titleView.text = title;
    [titleView sizeToFit];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 || section == 2) {
        return 1;
    } 
    return 5;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"formField"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:@"formField"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        UITextField *formTextField = [[UITextField alloc] initWithFrame:CGRectMake(110, 6, 185, 30)];
        formTextField.delegate = self;
        formTextField.font = [UIFont fontWithName:@"system" size:32];
        formTextField.adjustsFontSizeToFitWidth = YES;
        formTextField.textColor = [UIColor blackColor];
        
        formTextField.keyboardType = UIKeyboardTypeEmailAddress;
        formTextField.returnKeyType = UIReturnKeyNext;
        formTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        formTextField.autocorrectionType = UITextAutocorrectionTypeYes;
        formTextField.backgroundColor = [UIColor whiteColor];
        formTextField.textAlignment = UITextAlignmentLeft;
        formTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [formTextField setEnabled:YES];
        
        if ([indexPath section] == 0) {
            formTextField.placeholder = @"Question - required";
            cell.textLabel.text = @"Question";
            [cell addSubview:formTextField];
            self.question = formTextField;
        } else if([indexPath section] == 1) {
            if ([indexPath row] < 2) {
                formTextField.placeholder = @"Answer - required";
            } else {
                formTextField.placeholder = @"Answer - optional";
            }
            cell.textLabel.text = @"Answer";
            [self.answerTextFields addObject:formTextField];
            [cell addSubview:formTextField];
        } else {
            cell.textLabel.text = @"Submit Question";
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.textLabel.font = [UIFont fontWithName:@"didot" size:36];
            formTextField.adjustsFontSizeToFitWidth = YES;
        }
        
            
    }

    return cell;    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 2) {
        if ([self.question.text length] > 0 && [[[self.answerTextFields objectAtIndex:0] text] length] > 0 && [[[self.answerTextFields objectAtIndex:1] text] length] > 0) {
            Question *question = [Question object];
            [question setText:self.question.text];
            self.question.text = @"";
            NSMutableArray *allAnswers = [NSMutableArray new];
            for (UITextField *answerField in self.answerTextFields) {
                if (answerField.text) {
                    Answer *answer = [Answer object];
                    [answer setText:answerField.text];
                    [allAnswers addObject:answer];
                    answerField.text = @"";
                }

            }

            [ProfilerStore saveQuestion:question withBlock:^(int question_id) {
                for (Answer* answerToSave in allAnswers) {
                    answerToSave.question_id = question_id;
                    [ProfilerStore saveAnswer:answerToSave];
                }
            }];
            UIAlertView *saveSucceeded = [[UIAlertView alloc] initWithTitle:@"Awesome!  Your question has been successfully submitted." message:@"" delegate:self cancelButtonTitle:@"Woot!" otherButtonTitles:nil];
            [saveSucceeded show];
            
        } else {
            UIAlertView *saveFailed = [[UIAlertView alloc] initWithTitle:@"We couldn't save your question yet." message:@"The question field plus at least the first two answer fields must be filled in." delegate:self cancelButtonTitle:@"Let me fix that!" otherButtonTitles:nil];
            [saveFailed show];
        }
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 50) ? NO : YES;
}
- (void) hideKeyboard {
    [self.view endEditing:NO];
}
@end
