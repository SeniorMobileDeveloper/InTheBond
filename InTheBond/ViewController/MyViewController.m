//
//  MyViewController.m
//  InTheBond
//
//  Created by Nala on 6/25/15.
//  Copyright (c) 2015 Nala. All rights reserved.
//

#import "MyViewController.h"

@implementation MyViewController
{
    IBOutlet UIView *m_view;
    UIActivityIndicatorView *m_spinner;
    UITextField *m_etActiveTextField;
}

#pragma mark - UIViewController
- (void) viewDidLoad
{
    [super viewDidLoad];
    [self initActivityIndicator];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registerForKeyboardNotifications];

}
#pragma mark - my define
- (void) initActivityIndicator
{
    CGRect screenrect = [[UIScreen mainScreen] bounds];
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(CGRectGetMidX(screenrect), CGRectGetMidY(screenrect));
    spinner.hidesWhenStopped = YES;
    spinner.color = [UIColor blackColor];
    [self.view addSubview:spinner];
    m_spinner = spinner;
}


- (void) showSpinner:(BOOL)state
{
    state ? [m_spinner startAnimating] : [m_spinner stopAnimating];
    [self.view setUserInteractionEnabled:!state];
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    if (m_etActiveTextField == nil)
    {
        return;
    }
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect rectTextFiled = m_etActiveTextField.frame;
    CGRect rect = m_view.frame;
    double offsetY = rectTextFiled.origin.y + rectTextFiled.size.height * 1.5 + kbSize.height - rect.size.height;
    if (offsetY < 0)
    {
        return;
    }
    rect.origin.y = -offsetY;
    [m_view setFrame:rect];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    CGRect rect = [m_view frame];
    rect.origin.y = 0;
    [m_view setFrame:rect];
}


#pragma mark - ConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data
{
    NSMutableData *receivedData = [[NSMutableData alloc] init];
    [receivedData appendData:data];
    m_receivedData = receivedData;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self showSpinner:false];
    NSLog(@"Connection Failed : %@", [error localizedDescription]);
    UIAlertView * failedAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                           message:@"Unable to connect to server."
                                                          delegate:nil cancelButtonTitle:@"Ok"
                                                 otherButtonTitles:nil, nil];
    [failedAlert show];
}




#pragma mark - TextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    m_etActiveTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    m_etActiveTextField = nil;
}
@end
