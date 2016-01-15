//
//  ProfileViewController.m
//  InTheBond
//
//  Created by Nala on 6/25/15.
//  Copyright (c) 2015 Nala. All rights reserved.
//

#import "ProfileViewController.h"
#import "Setting.h"
#import "Net.h"
#import "SBJSON.h"
#import <Quickblox/Quickblox.h>
@implementation ProfileViewController
{
    __weak IBOutlet UIImageView *m_imgPhoto;
    __weak IBOutlet UIProgressView *m_progressUpload;
}


-(void) viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;

    m_imgPhoto.image = [Setting sharedSetting].myProfile.photo;
    
//    float width = self.view.bounds.size.width;
//    float height = self.view.bounds.size.height;
    
//    CGRect rectUpload = m_progressUpload.frame;
//    CGRect rectPhoto = m_imgPhoto.frame;
//    //rectUpload.size.width = rectPhoto.size.width;
//    [m_progressUpload setFrame:CGRectMake(rectUpload.origin.x, rectUpload.origin.y, rectPhoto.size.width, rectUpload.size.height)];

}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.isMovingFromParentViewController || self.isBeingDismissed) {
        exit(1);
    }
}
- (IBAction)onUpload {
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    [self presentViewController:pickerController animated:YES completion:nil];
}
#pragma mark -
#pragma mark UIImagePickerControllerDelegate

- (void) imagePickerController:(UIImagePickerController *)picker
         didFinishPickingImage:(UIImage *)image
                   editingInfo:(NSDictionary *)editingInfo
{
    m_imgPhoto.image = image;
    image = [self imageWithImage:image scaledToSize:CGSizeMake(128, 128)];

    [self dismissModalViewControllerAnimated:YES];
    [self uploadImage:image];
}
- (IBAction)onOK {
}

- (IBAction)onSoundSwitch:(UISwitch *)sender {
}


- (void) uploadImage:(UIImage*) image
{
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    
    NSString *urlString = @"http://thedatapp.co/aaa/fileUpload.php";
    NSMutableURLRequest *request= [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData *postbody = [NSMutableData data];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"fullname"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"%@", [Setting sharedSetting].myProfile.name] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *fileName = [NSString stringWithFormat:@"%@%@", [Setting sharedSetting].myProfile.name, @".jpg"];
    fileName = [fileName stringByReplacingOccurrencesOfString:@" " withString:@""];
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"image\"; filename=\"%@\"\r\n", fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[NSData dataWithData:imageData]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postbody];
    
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [connection start];
    [super showSpinner:true];
    
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
                        [[Setting sharedSetting].myProfile set:dic];
            Setting *setting = [Setting sharedSetting];
            [setting.myProfile getPhoto:SERVER_DOMAIN];
            
        }
    }
    [self showSpinner:false];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Photo"
                                                    message:@"Uploaded successfully"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}



@end
