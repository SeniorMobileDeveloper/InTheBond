//
//  MapViewController.m
//  InTheBond
//
//  Created by Nala on 6/27/15.
//  Copyright (c) 2015 Nala. All rights reserved.
//

#import "MapViewController.h"
#import "ProfileInformation.h"
#import "Net.h"
#import "Setting.h"
#import "MyAnnotation.h"
#import "ChatService.h"
#import "SVProgressHUD.h"
#import <MapKit/MapKit.h>
#import "SBJSON.h"
#import "LatLng.h"
#import "СhatViewController.h"


#define PI 3.141592654

@implementation MapViewController
{
    __weak IBOutlet MKMapView *m_mapView;
    CLLocationManager *locationManager;
    NSMutableArray* friendsInformation;
    bool firstRun;
    NSMutableArray* dialogs;
    NSMutableArray* positions;
    NSMutableArray* states;
    int selectedChatId;
    QBChatDialog* selectedDialog;

}
- (void)viewDidLoad {
    [super viewDidLoad];
    selectedDialog = nil;
    firstRun = NO;
    MKMapView *mapView = m_mapView;
//    mapView.mapType = MKMapTypeHybrid;
    mapView.delegate =  self;
    mapView.showsUserLocation = YES;

    friendsInformation = [[NSMutableArray alloc] init];
    positions = [[NSMutableArray alloc] init];
    states = [[NSMutableArray alloc] init];
    [self requestFriendsInfomation];
    [self initLocationManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dialogsUpdatedNotification) name:kNotificationDialogsUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatDidAccidentallyDisconnectNotification) name:kNotificationChatDidAccidentallyDisconnect object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
    selectedChatId = -1;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [locationManager startUpdatingLocation];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
         self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [locationManager stopUpdatingLocation];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
//////////////////////////
- (void)initLocationManager
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [locationManager requestWhenInUseAuthorization];
    locationManager.distanceFilter = 500; // meters
}
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (firstRun)
        return;
    firstRun = YES;
    [mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
    [self zoomMap:mapView didUpdateUserLocation:userLocation];
}



-(void)zoomMap:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    double mile = 1.0;
    MKCoordinateRegion region;
    region.center = mapView.userLocation.coordinate;
    MKCoordinateSpan span;
    span.latitudeDelta  = mile / 69;
    span.longitudeDelta = mile / 69;
    region.span = span;
    [mapView setRegion:region animated:YES];
}

#pragma mark - ADClusterMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    NSLog(@"name:%@", annotation.title);
    MKAnnotationView * pinView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotation.title];
    if (!pinView) {
        pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                               reuseIdentifier:annotation.title];
        UIImage *image = nil;
        for(int i = 0; i < friendsInformation.count; i++){
            ProfileInformation* information = [friendsInformation objectAtIndex:i];
            
            if ([annotation.title isEqualToString:information.name]){
                long unreadCount = 0;
                for(QBChatDialog* dialog in dialogs){
                    if ([dialog.occupantIDs containsObject:@(information.chatId)]) {
                        unreadCount =  dialog.unreadMessagesCount;
                        break;
                    }
                }
                image = [self makeBadgePhoto:information.photo unreadMessageCount:unreadCount myPhoto:(NO) userDistress:information.distress-1];
                break;
            }
        }
        if (image == nil){
            if ([annotation.title isEqualToString:@"Current Location"]){
                image = [Setting sharedSetting].myProfile.photo;
            }else{
                image = [UIImage imageNamed:@"default_user"];
            }
            if (dialogs){
                
            }
            image = [self makeBadgePhoto:image unreadMessageCount:0 myPhoto:(YES) userDistress:[Setting sharedSetting].myProfile.distress];
        }
        pinView.image = image;
        pinView.canShowCallout = YES;
    }
    else {
        pinView.annotation = annotation;
    }
    return pinView;
}


////////////////////////
- (void)requestFriendsInfomation
{
    ProfileInformation *myInfo = [Setting sharedSetting].myProfile;

    [Net requestGetFriendInformation:myInfo.name
                            latitude:myInfo.latitude
                           longitude:myInfo.longitude
                            delegate:self];
    [super showSpinner:YES];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *strResult = [[NSString alloc] initWithData:m_receivedData
                                                encoding:NSUTF8StringEncoding];
    NSLog(@"result:%@" , strResult);
    SBJSON *jsonParse = [SBJSON new];
    NSDictionary *dic = [jsonParse objectWithString:strResult];
    if (dic)
    {
        int msg = [[dic objectForKey:@"msg"] intValue];
        if (msg == SERVER_RESPONSE_SUCCESS)
        {
            NSArray *array = [dic objectForKey:@"people"];
            ProfileInformation *myInfo = [Setting sharedSetting].myProfile;
            for(NSDictionary *dic_profile in array){
                ProfileInformation *info = [[ProfileInformation alloc] initWithDictionary:dic_profile];
                if ([info.name isEqualToString:myInfo.name]){
                    continue;
                }
                BOOL canAdd = YES;
                for(ProfileInformation *infoOriginal in friendsInformation)
                {
                    if ([info.name isEqualToString:infoOriginal.name])
                    {
                        canAdd = NO;
                        [infoOriginal set:dic_profile];
                        break;
                    }
                }
                NSLog(@"url:%@", info.urlPhoto);

                [info getPhoto:SERVER_DOMAIN];
                if (canAdd){
                    [friendsInformation addObject:info];
                    [positions addObject:[[LatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(info.latitude, info.longitude) fullName:info.name]];
                    [states addObject:[NSNumber numberWithBool:NO]];
                }
            }
        }
    }
    if([ChatService shared].dialogs == nil){
        // get dialogs
        //
        __weak __typeof(self)weakSelf = self;
        [[ChatService shared] requestDialogsWithCompletionBlock:^{
            [weakSelf updateUnreadMessage];
            [self updateFriendsMarker];
            [self showSpinner:NO];
        }
         errorBlock:^{
             [self showSpinner:NO];
             [self updateFriendsMarker];
         }];
    }else{
        [[ChatService shared] sortDialogs];
        [self updateUnreadMessage];
        [self updateFriendsMarker];
        [self showSpinner:NO];
    }
}


- (void)updateFriendsMarker
{
    NSMutableArray * annotations = [[NSMutableArray alloc] init];
    for (LatLng *pos in positions) {
        MyAnnotation *annotation = [[MyAnnotation alloc] init];
        [annotation setTitle:pos.name];
        [annotation setCoordinate:pos.coordinate.latitude
                        longitude:pos.coordinate.longitude];
        [annotations addObject:annotation];
    }
    [m_mapView removeAnnotations:m_mapView.annotations];
    [m_mapView addAnnotations:annotations];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
- (UIImage*) makeBadgePhoto:(UIImage*) photo unreadMessageCount:(long) count myPhoto:(BOOL) isMine userDistress:(int) distress
{
    photo = [self imageWithImage:photo scaledToSize:CGSizeMake(131, 131)];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(155, 195), NO, 0.0);
    UIImage *frame;
    if (isMine){
        frame = [UIImage imageNamed:@"myframe"];
        
    } else {
        frame = [UIImage imageNamed:@"frame"];
    }
    CGSize frameSize = frame.size;
    [frame drawInRect:CGRectMake(0, 5, frameSize.width, frameSize.height)];
    CGSize photoSize = photo.size;
    [photo drawInRect:CGRectMake(10, 15, photoSize.width, photoSize.height)];
    
    NSString *distressImg[3] = {
        @"ribbon1",
        @"ribbon2",
        @"ribbon3"
    };
    UIImage* ribbon = [UIImage imageNamed:distressImg[distress]];
    CGSize ribbonSize = ribbon.size;
    [ribbon drawInRect:CGRectMake(61, 0, ribbonSize.width, ribbonSize.height)];
    

    if (count > 0){
        NSString *text = [NSString stringWithFormat:@"%ld", count];
        UIFont *font = [UIFont boldSystemFontOfSize:48];
        
        if([text respondsToSelector:@selector(drawInRect:withAttributes:)])
        {
            NSDictionary *att = @{NSFontAttributeName:font, NSForegroundColorAttributeName: [UIColor redColor]};
            [text drawInRect:CGRectMake(20, 20, 100, 100) withAttributes:att];
        }
        else
        {
            [[UIColor redColor] set];
            [text drawInRect:CGRectIntegral(CGRectMake(20, 20, 100, 100)) withFont:font];
        }
    }
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    newImage = [self imageWithImage:newImage scaledToSize:CGSizeMake(46.5, 58.5)];
    return newImage;
}

#pragma mark
#pragma mark Notifications

- (void)dialogsUpdatedNotification{
    [self updateUnreadMessage];
}

- (void)chatDidAccidentallyDisconnectNotification{
    [self updateUnreadMessage];
}

- (void)willEnterForegroundNotification{
    [self updateUnreadMessage];
}

- (void)updateUnreadMessage{
    dialogs = [ChatService shared].dialogs;
    [self updateFriendsMarker];
}

- (long) calcDistancePixel:(CGPoint) p1 pos2:(CGPoint) p2{
    long x = p1.x - p2.x;
    long y = p1.y - p2.y;
    return (long) sqrt(x * x + y * y);
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    for(int i = 0; i < states.count; i++){
        [states replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
        ProfileInformation* info = [friendsInformation objectAtIndex:i];
        ((LatLng*)[positions objectAtIndex:i]).coordinate = CLLocationCoordinate2DMake(info.latitude, info.longitude);
    }
    [self updateFriendsMarker];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    MyAnnotation* annotation = view.annotation;
    [mapView deselectAnnotation:annotation animated:YES];
  
    const int DISTANCE_OVERLAP = 96;
    
    CGPoint clickPosition = [mapView convertCoordinate:annotation.coordinate toPointToView:mapView];
    int count = 0;
    int size = (int)positions.count;
    for(int i = 0; i < size; i++){
        LatLng* pos = [positions objectAtIndex:i];
        CGPoint screenPosition = [mapView convertCoordinate:pos.coordinate toPointToView:mapView];
        long dis = [self calcDistancePixel:clickPosition pos2:screenPosition];
        if (dis < DISTANCE_OVERLAP){
            count ++;
        }
        if ([pos.name isEqualToString:annotation.title] && [[states objectAtIndex:i] boolValue]){
            if([annotation.title isEqualToString:@"Current Location"]){
                return;
            }
            for (ProfileInformation* info in friendsInformation) {
                NSString* name = info.name;
                if ([annotation.title isEqualToString:name]) {
                    selectedChatId = info.chatId;
                    [self gotoChat];
                    return;
                }
            }
        }
    }
    int distance = DISTANCE_OVERLAP;
    double angle = 0;
    
    for(int i = 0; i < size; i++){
        LatLng* pos = [positions objectAtIndex:i];
        CGPoint screenPosition = [mapView convertCoordinate:pos.coordinate toPointToView:mapView];
        long dis = [self calcDistancePixel:clickPosition pos2:screenPosition];
        if (dis < DISTANCE_OVERLAP){
            if (count == 1){
                for (ProfileInformation* info in friendsInformation) {
                    NSString* name = info.name;
//                    if(name.equals(Constants.g_myProfile.m_name)){
//                        continue;
//                    }
                    if ([annotation.title isEqualToString:name]) {
                        selectedChatId = info.chatId;
                        [self gotoChat];
                    }
                }
            } else{
                int step_distance;
                double ANGLE_STEP;
                if (count < 8) {
                    ANGLE_STEP = 2 * PI / count;
                    step_distance = 0;
                } else {
                    ANGLE_STEP = 2 * PI / 8;
                    step_distance = distance / 8;
                }
                angle += ANGLE_STEP;
                distance += step_distance;
                int x = (int)(cos(angle) * distance);
                int y = (int)(sin(angle) * distance);
                CLLocationCoordinate2D newpos = [mapView convertPoint:CGPointMake(clickPosition.x + x, clickPosition.y + y)
                                              toCoordinateFromView:mapView];
                pos.coordinate = newpos;
                [positions replaceObjectAtIndex:i withObject:pos];
                [states replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:YES]];

            }
        } else {
            [states replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
        }
    }
    [self updateFriendsMarker];
    return;
}

#pragma mark
#pragma mark Storyboard

- (void)gotoChat
{
    [super showSpinner:YES];
    for(QBChatDialog *qbChatDialog in dialogs){
        if ([qbChatDialog.occupantIDs containsObject:[NSNumber numberWithInt:selectedChatId]])
        {
            selectedDialog = qbChatDialog;
            [self performSegueWithIdentifier:@"gotoChat" sender:nil];
            [super showSpinner:NO];
            return;
        }
    }
    QBChatDialog *chatDialog = [QBChatDialog new];
    chatDialog.type = QBChatDialogTypePrivate;
    chatDialog.occupantIDs = @[@(selectedChatId)];
    
    [QBRequest createDialog:chatDialog successBlock:^(QBResponse *response, QBChatDialog *createdDialog) {
        selectedDialog = createdDialog;
        [self performSegueWithIdentifier:@"gotoChat" sender:nil];
        [super showSpinner:NO];
    } errorBlock:^(QBResponse *response) {
        
    }];

}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.destinationViewController isKindOfClass:ChatViewController.class]){
        ChatViewController *destinationViewController = (ChatViewController *)segue.destinationViewController;
        destinationViewController.dialog = selectedDialog;
    }
}

@end
