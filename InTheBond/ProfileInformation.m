//
//  ProfileInformation.m
//  InTheBond
//
//  Created by Nala on 6/28/15.
//  Copyright (c) 2015 Nala. All rights reserved.
//

#import "ProfileInformation.h"
#import "SBJSON.h"

@implementation ProfileInformation

- (ProfileInformation*) initWithString:(NSString *)info{
    self = [super init];
    NSDictionary *dic = [[NSDictionary alloc] init];
    SBJSON *jsonParse = [SBJSON new];
    dic = [jsonParse objectWithString:info];
    self = [self initWithDictionary:dic];
    return self;
}
- (ProfileInformation*) initWithDictionary:(NSDictionary *)dic{
    self = [super init];
    NSString* name = [dic objectForKey:FULL_NAME];
    if (name){
        _name = name;
        [_obj setValue:name forKey:FULL_NAME];
    }
    NSString* urlPhoto = [dic objectForKey:PHOTO_URL];
    if (urlPhoto){
        _urlPhoto = urlPhoto;
        [_obj setValue:urlPhoto forKey:PHOTO_URL];
    }
    NSString* chapter = [dic objectForKey:CHAPTER];
    if (chapter){
        _chapter = chapter;
        [_obj setValue:chapter forKey:CHAPTER];
    }
    NSString* kross = [dic objectForKey:KROSS];
    if (kross){
        _kross = kross;
        [_obj setValue:kross forKey:KROSS];
    }
    NSString* occupation = [dic objectForKey:OCCUPATION];
    if (occupation){
        _occupation = occupation;
        [_obj setValue:occupation forKey:OCCUPATION];
    }
    NSNumber* distress = [dic objectForKey:DISTRESS];
    if (distress){
        _distress = (int)[distress integerValue];
        [_obj setValue:distress forKey:DISTRESS];
    }
    NSNumber* latitude = [dic objectForKey:LATITUDE];
    if (latitude){
        _latitude = [latitude doubleValue];
        [_obj setValue:latitude forKey:LATITUDE];
    }
    NSNumber* longitude = [dic objectForKey:LONGITUDE];
    if (longitude){
        _longitude = [longitude doubleValue];
        [_obj setValue:longitude forKey:LONGITUDE];
    }
    NSNumber* chatId = [dic objectForKey:CHAT_ID];
    if (chatId){
        _chatId = (int)[chatId integerValue];
        [_obj setValue:chatId forKey:CHAT_ID];
    }
    // m_email = obj.getString("email");
    
    return self;
}

- (void)getPhoto:(NSString*) serverUrl
{
    NSString *url = [NSString stringWithFormat:@"%@%@", serverUrl, _urlPhoto];
   
    _photo = [UIImage imageWithData:
             [NSData dataWithContentsOfURL:
              [NSURL URLWithString:url]]];
}

- (void)set:(NSDictionary*) dic {
    
    NSString* name = [dic objectForKey:FULL_NAME];
    if (name){
        _name = name;
        [_obj setValue:name forKey:FULL_NAME];
    }
    NSString* urlPhoto = [dic objectForKey:PHOTO_URL];
    if (urlPhoto){
        _urlPhoto = urlPhoto;
        [_obj setValue:urlPhoto forKey:PHOTO_URL];
    }
    NSString* chapter = [dic objectForKey:CHAPTER];
    if (chapter){
        _chapter = chapter;
        [_obj setValue:chapter forKey:CHAPTER];
    }
    NSString* kross = [dic objectForKey:KROSS];
    if (kross){
        _kross = kross;
        [_obj setValue:kross forKey:KROSS];
    }
    NSString* occupation = [dic objectForKey:OCCUPATION];
    if (occupation){
        _occupation = occupation;
        [_obj setValue:occupation forKey:OCCUPATION];
    }
    NSNumber* distress = [dic objectForKey:DISTRESS];
    if (distress){
        _distress = (int)[distress integerValue];
        [_obj setValue:distress forKey:DISTRESS];
    }
    NSNumber* latitude = [dic objectForKey:LATITUDE];
    if (latitude){
        _latitude = [latitude integerValue];
        [_obj setValue:latitude forKey:LATITUDE];
    }
    NSNumber* longitude = [dic objectForKey:LONGITUDE];
    if (longitude){
        _longitude = [longitude integerValue];
        [_obj setValue:longitude forKey:LONGITUDE];
    }
    NSNumber* chatId = [dic objectForKey:CHAT_ID];
    if (chatId){
        _chatId = (int)[chatId integerValue];
        [_obj setValue:chatId forKey:CHAT_ID];
    }
}

- (NSString*) toString
{
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:_obj options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return myString;
}

@end
