//
//  MyViewController.h
//  InTheBond
//
//  Created by Nala on 6/25/15.
//  Copyright (c) 2015 Nala. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyViewController : UIViewController <UITextFieldDelegate>
{
    NSMutableData *m_receivedData;
}

- (void) showSpinner:(BOOL) state;

@end
