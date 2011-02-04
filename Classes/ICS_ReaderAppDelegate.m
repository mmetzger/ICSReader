//
//  ICS_ReaderAppDelegate.m
//  ICS Reader
//
//  Created by Mike Metzger on 9/8/10.
//  Copyright Psycho Pigeon Software 2010. All rights reserved.
//

#import "ICS_ReaderAppDelegate.h"
#import "RootViewController.h"


@implementation ICS_ReaderAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize launchURL;
@synthesize isIntro;

- (void) showIntro {
	//NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:@"IntroView" owner:self options:nil];
	//[window addSubview:[bundle objectAtIndex:0]] ;
	NSLog(@"Firing ShowHelp");
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ShowHelp" object:nil];
	self.isIntro = YES;
}

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
	NSURL *tmpurl = (NSURL *)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
	
	//UIAlertView *someError = [[UIAlertView alloc] initWithTitle:@"Launch URL" message:[tmpurl absoluteString] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	//[someError show];
	//[someError release];
	NSLog(@"Launch Options: %@", launchOptions);
	NSLog(@"URL: %@", tmpurl);
	
    // Add the navigation controller's view to the window and display.
	[window addSubview:navigationController.view];
	[window makeKeyAndVisible];
	
	if (tmpurl != nil) {
	//	UIAlertView *someError2 = [[UIAlertView alloc] initWithTitle:@"Setting launchURL!" message:[tmpurl absoluteString] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	//	[someError2 show];
	//	[someError2 release];
		NSLog(@"Setting launchURL to %@", tmpurl);
		self.launchURL = tmpurl;
		[window bringSubviewToFront:navigationController.view];
		// Not fond of this, but can't get the data to parse on first setup.  Force a call to refresh to make it properly visible.
		[(RootViewController *)navigationController.visibleViewController refresh];
		self.isIntro = NO;
	} else {
		//NSLog(@"No url - calling ShowHelp");
		//[self showIntro];
	}

	
	
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshSent" object:nil];

    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	NSLog(@"In handleOpenURL\nURL: %@", url);
	if (url != nil)
	{
		NSLog(@"No intro - showing base frame");
		self.launchURL = url;
		[window bringSubviewToFront:navigationController.view];
		self.isIntro = NO;
		return YES;
	} else {
		NSLog(@"URL is nil, showing help");
		[self showIntro];
		return NO;
	}

}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
	NSLog(@"In DidBecomeActive...");
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshSent" object:nil];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[navigationController release];
	[window release];
	[launchURL release];
	[super dealloc];
}


@end

