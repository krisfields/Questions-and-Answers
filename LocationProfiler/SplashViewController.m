//
//  SplashViewController.m
//  LocationProfiler
//
//  Created by Kris Fields on 9/10/12.
//  Copyright (c) 2012 Kris Fields. All rights reserved.
//

#import "SplashViewController.h"
#import "ProfilerStore.h"



@interface SplashViewController () <UITextFieldDelegate>
- (IBAction)facebookButton:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
- (IBAction)signInButton:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *labelBehindEmail;
@property (weak, nonatomic) IBOutlet UILabel *labelBehindPassword;

@end

@implementation SplashViewController
@synthesize labelBehindEmail;
@synthesize labelBehindPassword;
@synthesize emailField;
@synthesize passwordField;

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
    self.labelBehindEmail.alpha = .7;
    self.labelBehindPassword.alpha = .7;
    self.emailField.delegate = self;
    self.passwordField.delegate = self;
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setEmailField:nil];
    [self setPasswordField:nil];
    [self setLabelBehindEmail:nil];
    [self setLabelBehindPassword:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)facebookButton:(id)sender {
    [self presentModalViewController:self.tabBarController animated:YES];
}
- (IBAction)signInButton:(id)sender {
    [self loginUser];
}
- (void)loginUser {
    NSString *email = self.emailField.text;
    NSString *password = self.passwordField.text;
    [ProfilerStore setupProfilerStore:email password:password];
    [ProfilerStore fetchQuestions: ^{
        [self presentModalViewController:self.tabBarController animated:YES];
    }];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // dismiss keyboard through `resignFirstResponder`
    [self.emailField resignFirstResponder];
    [self.passwordField resignFirstResponder];    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self loginUser];
    return YES;
}
@end
