//
//  SignupViewController.m
//  InTHeBond
//
//  Created by Nala on 6/23/15.
//  Copyright (c) 2015 Nala. All rights reserved.
//

#import "SignupViewController.h"
#import "Net.h"
#import "SBJSON.h"
#import "Setting.h"
#import "ChatService.h"

@implementation SignupViewController
{
    __weak IBOutlet UITextField *m_etFullName, *m_etKross, *m_etChapter, *m_etOccupation, *m_etEmail, *m_etPasswrod;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onClickSignup:(id)sender {
    NSString *fullName = m_etFullName.text;
    NSString *kross = m_etKross.text;
    NSString *chapter = m_etChapter.text;
    NSString *occupation = m_etOccupation.text;
    NSString *email = m_etEmail.text;
    NSString *password = m_etPasswrod.text;
    
    NSString *rtn = [self validateWithFullName:fullName kroww:kross chapter:chapter occupation:occupation email:email password:password];
    if (rtn == nil){
        [super showSpinner:YES];
        QBUUser *user = [QBUUser user];
        user.password = password;
        user.login = [fullName stringByReplacingOccurrencesOfString:@" " withString:@""];

        [[ChatService shared] signupWithUser:user
                                successBlock:^(QBResponse *response, QBUUser *user){
                                    [Net requestSignupWithFullName:fullName kross:kross chapter:chapter occupation:occupation email:email password:password delegate:self];
                                }
                                  errorBlock:^(QBResponse *response){
                                      NSString *errorMessage = [[response.error description] stringByReplacingOccurrencesOfString:@"(" withString:@""];
                                      errorMessage = [errorMessage stringByReplacingOccurrencesOfString:@")" withString:@""];
                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Errors"
                                                                                      message:errorMessage
                                                                                     delegate:nil
                                                                            cancelButtonTitle:@"Ok"
                                                                            otherButtonTitles: nil];
                                      [alert show];
                                      [super showSpinner:NO];
                                  }];
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login"
                                                    message:rtn
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (NSString*)validateWithFullName:(NSString *)fullName kroww:(NSString *)kross chapter:(NSString *)chapter occupation:(NSString *)occupation email:(NSString *)email password : (NSString*) password{
    
    if ([fullName isEqualToString:@""]) {
        return @"Please enter your full name";
    }
    if (fullName.length < 6) {
        return @"FullName must 6 character long";
    }
    if ([kross isEqualToString:@""]) {
        return @"Please enter your kross";
    }
    if ([chapter isEqualToString:@""]) {
        return @"Please enter your chapter";
    }
    if ([occupation isEqualToString:@""]) {
        return @"Please enter your occupation";
    }
    if ([email isEqualToString:@""]) {
        return @"Please enter your email";
    }
    if (![self isValidEmail:email]){
        return @"Please input correct email";
    }
    if ([password isEqualToString:@""]) {
        return @"Please enter your password";
    }
    return nil;
}

-(BOOL) isValidEmail:(NSString *)email{
    NSString *emailFormat = @"[a-zA-Z0-9\\+\\.\\_\\%\\-\\+]{1,256}\\@[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}(\\.[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25})+";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailFormat];
    return [emailTest evaluateWithObject:email]||[emailTest evaluateWithObject:email];
}

#pragma mark - ConnectionDelegate
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [super showSpinner:NO];
    NSString *strResult = [[NSString alloc] initWithData:m_receivedData encoding:NSUTF8StringEncoding];
#ifdef TEST
    NSLog(@"Signup Result:%@", strResult);
#endif
    NSDictionary *v_Dic = [[NSDictionary alloc] init];
    SBJSON *jsonParse = [SBJSON new];
    v_Dic = [jsonParse objectWithString:strResult];
    if (!v_Dic) {
        return;
    }
    int msg = [[v_Dic objectForKey:@"msg"] intValue];
    if (msg == SERVER_RESPONSE_SUCCESS){
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - TextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == m_etFullName) {
        [textField resignFirstResponder];
        [m_etKross becomeFirstResponder];
    } else if (textField == m_etKross){
        [textField resignFirstResponder];
        [m_etChapter becomeFirstResponder];
    } else if (textField == m_etChapter){
        [textField resignFirstResponder];
        [m_etOccupation becomeFirstResponder];
    } else if (textField == m_etOccupation){
        [textField resignFirstResponder];
        [m_etEmail becomeFirstResponder];
    } else if (textField == m_etEmail){
        [textField resignFirstResponder];
        [m_etPasswrod becomeFirstResponder];
    } else {
        [m_etPasswrod resignFirstResponder];
    }
    return YES;
}

@end
