//
//  ICS_ReaderAppDelegate.h
//  ICS Reader
//
//  Created by Mike Metzger on 9/8/10.
//  Copyright Psycho Pigeon Software 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ICS_ReaderAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
	NSURL *launchURL;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) NSURL *launchURL;
@property (nonatomic) BOOL isIntro;

- (void) showIntro;
@end

