 //
//  LoginViewController.m
//  InTHeBond
//
//  Created by Nala on 6/23/15.
//  Copyright (c) 2015 Nala. All rights reserved.
//

#import "LoginViewController.h"
#import "Net.h"
#import "Setting.h"
#import "SBJSON.h"
#import <Quickblox/Quickblox.h>
#import "ChatService.h"

@implementation LoginViewController
{
    __weak IBOutlet UITextField *m_etFullName;
    __weak IBOutlet UITextField *m_etPassword;
}
#pragma mark - UIViewController
- (void) viewDidLoad
{
    [super viewDidLoad];
    [self autoLogin];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - nala define
- (void) autoLogin
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"auto_boot"])
    {
        NSString* fullName = [defaults objectForKey:@"name"];
        NSString* password = [defaults objectForKey:@"password"];
        m_etFullName.text = fullName;
        m_etPassword.text = password;
        [super showSpinner:true];
        [self loginQB:fullName password:password];
    }
}

- (void)loginInTheBond:(NSString*)name password:(NSString*)password
{
    [Net requestLoginWithFullName:name
                         password:password
                         delegate:self];
    
    [self showSpinner:true];
}
- (void)loginQB:(NSString*)_name password:(NSString*)password
{
    QBSessionParameters *extendedAuthRequest = [[QBSessionParameters alloc] init];
    NSString *name = [_name stringByReplacingOccurrencesOfString:@" " withString:@""];
    extendedAuthRequest.userLogin = name;
    extendedAuthRequest.userPassword = password;
    __weak __typeof(self)weakSelf = self;
    [QBRequest createSessionWithExtendedParameters:extendedAuthRequest
                                      successBlock:^(QBResponse *response, QBASession *session) {
        QBUUser *currentUser = [QBUUser user];
        currentUser.ID = session.userID;
        currentUser.login = name;
        currentUser.password = password;
        [[ChatService shared] loginWithUser:currentUser completionBlock:^{
            
            // hide alert after delay
            double delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            });
            
            [self loginInTheBond:_name password:password];
        }];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }else{
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
        }
#else
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
#endif
    }
                                        errorBlock:^(QBResponse *response) {
        NSString *errorMessage = [[response.error description] stringByReplacingOccurrencesOfString:@"(" withString:@""];
        errorMessage = [errorMessage stringByReplacingOccurrencesOfString:@")" withString:@""];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Errors"
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];
        [alert show];
        [self showSpinner:false];

    }];
}
- (NSString*) validateWithfullName:(NSString *)fullName withPassword:(NSString *)password
{
    if ([fullName isEqualToString:@""])
    {
        return @"Please enter your fullName";
    }
    if ([password isEqualToString:@""])
    {
        return @"Please enter your password";
    }
    return nil;
}


#pragma mark - Action
- (IBAction)onClickSignIn:(id)sender
{
    NSString *fullName = m_etFullName.text;
    NSString *password = m_etPassword.text;
 
    NSString *rtn = [self validateWithfullName:fullName
                                  withPassword:password];
    if (rtn == nil)
    {
        [Net requestLoginWithFullName:fullName
                             password:password
                             delegate:self];
        [self showSpinner:true];
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login"
                                                    message:rtn
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
#pragma mark - ConnectionDelegate
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *strResult = [[NSString alloc] initWithData:m_receivedData
                                                encoding:NSUTF8StringEncoding];
    SBJSON *jsonParse = [SBJSON new];
    NSDictionary *dic = [jsonParse objectWithString:strResult];
    if (dic)
    {
        int msg = [[dic objectForKey:@"msg"] intValue];
        if (msg == SERVER_RESPONSE_SUCCESS)
        {
            dic = [dic objectForKey:@"profile"];
//            [[Setting sharedSetting].myProfile set:dic];
            
            Setting *setting = [Setting sharedSetting];
            setting.myProfile = [[ProfileInformation alloc] initWithDictionary:dic];
            [setting.myProfile getPhoto:SERVER_DOMAIN];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:true
                       forKey:@"auto_boot"];
            
            NSString *fullName = m_etFullName.text;
            NSString *password = m_etPassword.text;
            
            [defaults setObject:fullName
                         forKey:@"name"];
            [defaults setObject:password
                         forKey:@"password"];
            
            NSString *name = [Setting sharedSetting].myProfile.name;
            NSString *key = [NSString stringWithFormat:@"%@answer", name];
            if ([[defaults objectForKey:key] boolValue]){
                [self performSegueWithIdentifier:@"gotoProfile"
                                          sender:nil];
            }else{
                [self performSegueWithIdentifier:@"gotoQuestion"
                                          sender:nil];
            }
        }
    }
    [self showSpinner:false];
}
#pragma mark - TextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == m_etFullName)
    {
        [textField resignFirstResponder];
        [m_etPassword becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }
    return YES;
}

@end
