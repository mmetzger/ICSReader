//
//  RootViewController.h
//  ICS Reader
//
//  Created by Mike Metzger on 9/8/10.
//  Copyright Psycho Pigeon Software 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "DateTimeTableViewCell.h"
#import "HelpViewController.h";

@interface RootViewController : UIViewController <EKEventEditViewDelegate> {
	NSArray *sectionArray;
	NSURL *launchURL;
	//NSMutableDictionary *inviteDetails;
}

@property (nonatomic, retain) NSNumber *contentWidth;
@property (nonatomic, retain) NSArray *sectionArray;
@property (nonatomic, retain) NSURL *launchURL;
@property (nonatomic, retain) NSMutableDictionary *inviteDetails;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet ADBannerView *bannerView;
@property (nonatomic, retain) IBOutlet DateTimeTableViewCell *dtTableCell;
@property (nonatomic, retain) IBOutlet UILabel *warningLabel;

@property (nonatomic, retain) EKEventStore *eventStore;
@property (nonatomic, retain) EKCalendar *defaultCalendar;
@property (nonatomic, retain) EKEventViewController *detailViewController;
@property (nonatomic, retain) HelpViewController *helpViewController;

- (NSDate *) parseDate:(NSString *)strDate timezone:(NSString *)tzid;
- (void) parseICS;
- (void) saveEvent;
- (void) refresh;
- (void) addToCalendar:(NSMutableDictionary *)calDetails;
- (void) showHelp;
@end
