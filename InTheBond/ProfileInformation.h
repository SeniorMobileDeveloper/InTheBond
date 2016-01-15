//
//  ProfileInformation.h
//  InTheBond
//
//  Created by Nala on 6/28/15.
//  Copyright (c) 2015 Nala. All rights reserved.
//

#import <UIKit/UIKit.h>

#define FULL_NAME @"fullname"
#define PHOTO_URL @"image_url"
#define LATITUDE @"y"
#define LONGITUDE @"x"
#define KROSS @"kross"
#define OCCUPATION @"occupation"
#define CHAPTER @"chapter"
#define DISTRESS @"distress"
#define CHAT_ID @"chat_id"

@interface ProfileInformation : NSObject

@property (retain, nonatomic) NSString* name;
@property (assign, nonatomic) int chatId;

@property (retain, nonatomic) UIImage* photo;
@property (assign, nonatomic) double latitude;
@property (assign, nonatomic) double longitude;

@property (retain, nonatomic) NSString* urlPhoto;
@property (retain, nonatomic) NSString* chapter;
@property (retain, nonatomic) NSString* kross;
@property (retain, nonatomic) NSString* occupation;
@property (assign, nonatomic) int distress;
@property (retain, nonatomic) NSDictionary* obj;


- (ProfileInformation*) initWithString:(NSString*) info;
- (ProfileInformation*) initWithDictionary:(NSDictionary*) dic;

- (void) getPhoto:(NSString*)serverUrl;
- (void) set:(NSDictionary*) dic;
- (NSString*) toString;

@end
