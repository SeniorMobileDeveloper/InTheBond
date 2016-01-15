//
//  QuestionViewContoller.m
//  InTHeBond
//
//  Created by Nala on 6/23/15.
//  Copyright (c) 2015 Nala. All rights reserved.
//

#import "QuestionViewContoller.h"
#import "Setting.h"

@implementation QuestionViewContoller
{
    __weak IBOutlet UITextField *m_etTime, *m_etDay;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.isMovingFromParentViewController || self.isBeingDismissed) {
        exit(1);
    }
}

- (IBAction)onClickNext:(id)sender {
    NSString* time = m_etTime.text;
    NSString* day = m_etDay.text;
    
    
    if (![time containsString:@"pawned"] && ![time containsString:@"watch"]
        && ![time isEqualToString:@"Alpha Pi"] && ![time isEqualToString:@"A Pi"] && ![time isEqualToString:@"a pi"] && ![time isEqualToString:@"alpha pi"]){
        UIAlertView * failedAlert = [[UIAlertView alloc] initWithTitle:@"Question" message:@"Please correct answers" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [failedAlert show];
        return;
    }
    if (![day isEqualToString:@"Nov 7th"] && ![day isEqualToString:@"November 7th 1947"] && ![day isEqualToString:@"11/7"] && ![day isEqualToString:@"Diggs died"] && ![day isEqualToString:@"diggs died"]
        && ![day isEqualToString:@"Alpha Pi"] && ![day isEqualToString:@"A Pi"] && ![day isEqualToString:@"a pi"] && ![day isEqualToString:@"alpha pi"]){
       
        UIAlertView * failedAlert = [[UIAlertView alloc] initWithTitle:@"Question" message:@"Please correct answers" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [failedAlert show];
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:true
               forKey:@"auto_boot"];
    NSString *name = [Setting sharedSetting].myProfile.name;
    NSString *key = [NSString stringWithFormat:@"%@answer", name];
    [defaults setBool:true
                 forKey:key];
    [self performSegueWithIdentifier:@"questionToProfile" sender:nil];

}

#pragma mark - TextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == m_etTime) {
        [textField resignFirstResponder];
        [m_etDay becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}

@end
