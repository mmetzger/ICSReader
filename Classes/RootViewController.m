//
//  RootViewController.m
//  ICS Reader
//
//  Created by Mike Metzger on 9/8/10.
//  Copyright Psycho Pigeon Software 2010. All rights reserved.
//

#import "RootViewController.h"
#import "ICS_ReaderAppDelegate.h"
#import "libical/ical.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "DateTimeTableViewCell.h"
#import "HelpViewController.h"
#import <Foundation/Foundation.h>

@interface RootViewController (PrivateMethods)
-(void) didRotate;
@end



@implementation RootViewController

@synthesize sectionArray;
@synthesize launchURL;
@synthesize inviteDetails;
@synthesize tableView;
@synthesize helpViewController;
@synthesize bannerView;
@synthesize eventStore;
@synthesize defaultCalendar;
@synthesize detailViewController;
@synthesize contentWidth;
@synthesize dtTableCell;
@synthesize warningLabel;
@synthesize noICSWarningLabel;
@synthesize noICSView;

- (void)dealloc {
	bannerView.delegate = nil;
	[bannerView release];
    [inviteDetails release];
	[tableView release];
	[helpViewController release];
	[sectionArray release];
	[launchURL release];
	[eventStore release];
	[defaultCalendar release];
	[detailViewController release];
	[contentWidth release];
	[dtTableCell release];
	[warningLabel release];
	[noICSWarningLabel release];
	[noICSView release];
	[super dealloc];
}

#pragma mark -
#pragma mark Banner/table frame change methods

- (void)moveBannerViewOffscreen
{
	
	// Make the table view take up the void left by the banner
	CGRect originalTableFrame = self.tableView.frame;
	CGFloat newTableHeight = self.view.frame.size.height;
	CGRect newTableFrame = originalTableFrame;
	newTableFrame.size.height = newTableHeight;
	
	// Position the banner below the table view (offscreen)
	CGRect newBannerFrame = self.bannerView.frame;
	newBannerFrame.origin.y = newTableHeight;
	
	self.tableView.frame = newTableFrame;
	self.bannerView.frame = newBannerFrame;
}

- (void)moveBannerViewOnscreen
{
	//return;
	CGRect newBannerFrame = self.bannerView.frame;
	newBannerFrame.origin.y = self.view.frame.size.height - newBannerFrame.size.height;

	CGRect originalTableFrame = self.tableView.frame;
	CGFloat newTableHeight = self.view.frame.size.height - newBannerFrame.size.height;
	CGRect newTableFrame = originalTableFrame;
	newTableFrame.size.height = newTableHeight;
	
	[UIView beginAnimations:@"BannerViewIntro" context:NULL];
	self.tableView.frame = newTableFrame;
	self.bannerView.frame = newBannerFrame;
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark ADBannerViewDelegate methods

- (void)bannerView:(ADBannerView *)banner
didFailToReceiveAdWithError:(NSError *)error
{
	[self moveBannerViewOffscreen];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
	[self moveBannerViewOnscreen];
}

- (NSDate *) parseDate:(NSString *)strDate timezone:(NSString *)tzid
{
	NSLog(@"Source string: %@", strDate);
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	[formatter setDateFormat:@"yyyyMMddHHmmss"];
	[formatter setTimeZone:[NSTimeZone timeZoneWithName:tzid]];
	
	strDate = [[strDate stringByReplacingOccurrencesOfString:@"Z" withString:@""] stringByReplacingOccurrencesOfString:@"T" withString:@""];
	
	NSLog(@"Cleaned string: %@", strDate);
	NSDate *sourceDate = [formatter dateFromString:strDate];
	
	NSLog(@"Date: %@", sourceDate);
	
	return sourceDate;
}

- (NSDate *) parseDateNew:(icalproperty *)prop
{/*
	struct icaltimetype t;
	t = icalproperty_get_dtstart(start);
	
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	[formatter setDateFormat:@"yyyyMMddHHmmss"];
	
	NSString *str = [[NSString alloc] initWithString:@"%04d%02d%02d%02d%02d%02d", t.year, t.month, t.day, t.hour, t.minute, t.second];
	
	NSDate *d = [formatter dateFromString:str];
	NSLog(@"DateNew: %@", d);
	
	return d;
  */
}
    

- (void)parseICS {
	
	NSMutableDictionary *calendarDetails = [[NSMutableDictionary alloc] init];
	
	//launchURLTextField.text = [LaunchURL absoluteString];
	NSStringEncoding encoding;
	NSError *error;
	NSString *contents = [[[NSString alloc] initWithContentsOfURL:launchURL usedEncoding:&encoding error:&error] autorelease];
	//urlContentsTextView.text = contents;
	NSLog(@"File Contents: %@", contents);
	
	if (contents) {
		
		icalcomponent *root = icalparser_parse_string([contents cStringUsingEncoding:NSUTF8StringEncoding]);
	
		if (root) {
			
			icalcomponent *tzinfo = icalcomponent_get_first_component(root, ICAL_VTIMEZONE_COMPONENT);
			icaltimezone *zone = icaltimezone_new();
			NSLog(@"Betting this is an issue in the tzinfo section...");
			NSString *timezonename;
			
			if (tzinfo) {
				const char *tzid;
				if (icaltimezone_set_component(zone, tzinfo)) {
					tzid = icaltimezone_get_tzid(zone);
					if (tzid) {
						timezonename = [NSString stringWithCString:tzid encoding:NSUTF8StringEncoding];
					} else {
						timezonename = @"GMT";
					}
				}
			}
			
			NSLog(@"Timezone is %@", timezonename);
			
			icalcomponent *c = icalcomponent_get_first_component(root, ICAL_VEVENT_COMPONENT);
		
			while (c) {
				icalproperty *description = icalcomponent_get_first_property(c, ICAL_DESCRIPTION_PROPERTY);
			
				if (description) {
					icalvalue *v = icalproperty_get_value(description); 
					NSString *descriptionString = [[NSString stringWithCString:icalvalue_as_ical_string(v) encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
					descriptionString = [descriptionString stringByReplacingOccurrencesOfString:@"\\" withString:@""];
					NSLog(@"Description: %@", descriptionString);
					//descriptionTextView.text = descriptionString;
					[calendarDetails setValue:descriptionString forKey:@"Description"];
					//p = icalcomponent_get_next_property(c, ICAL_DESCRIPTION_PROPERTY);
				} else {
					NSLog(@"No Description found");
					//descriptionTextView.text = @"";
				}

			
				icalproperty *location = icalcomponent_get_first_property(c, ICAL_LOCATION_PROPERTY);
			
				if (location) {
					icalvalue *v = icalproperty_get_value(location);
					NSString *locationString = [[NSString stringWithCString:icalvalue_as_ical_string(v) encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
					locationString = [locationString stringByReplacingOccurrencesOfString:@"\\" withString:@""];
					NSLog(@"Location: %@", locationString);
					//whereTextField.text = locationString;
					[calendarDetails setValue:locationString forKey:@"Location"];
				} else {
					NSLog(@"No Location found");
					//whereTextField.text = @"";
				}
			
				icalproperty *start = icalcomponent_get_first_property(c, ICAL_DTSTART_PROPERTY);
				icalproperty *end = icalcomponent_get_first_property(c, ICAL_DTEND_PROPERTY);
			
				if (start && end) {
					icalvalue *sv = icalproperty_get_value(start);
					icalvalue *ev = icalproperty_get_value(end);
					/*struct icaltimetype t;
					t = icalproperty_get_dtstart(start);
					
                    struct tm d_tm;
                    memset(&d_tm, 0, sizeof d_tm);
                    d_tm.tm_year = t.year;
                    d_tm.tm_mon = t.month;
                    d_tm.tm_mday = t.day;
					d_tm.tm_hour = t.hour;
					d_tm.tm_min = t.minute;
					
					struct icaltimetype t2;
					t2 = icalproperty_get_dtend(end);
					
                    struct tm d_tm2;
                    memset(&d_tm2, 0, sizeof d_tm2);
                    d_tm2.tm_year = t2.year;
                    d_tm2.tm_mon = t2.month;
                    d_tm2.tm_mday = t2.day;
					d_tm2.tm_hour = t2.hour;
					d_tm2.tm_min = t2.minute;
					
					NSLog(@"Start: %d-%02d-%02d %02d:%02d", d_tm.tm_year, d_tm.tm_mon, d_tm.tm_mday, d_tm.tm_hour, d_tm.tm_min);
					NSLog(@"End: %d-%02d-%02d %02d:%02d", d_tm2.tm_year, d_tm2.tm_mon, d_tm2.tm_mday, d_tm2.tm_hour, d_tm2.tm_min);
					
					
					//NSLog(icalproperty_get_dtstart(start));
//					
					
					NSLog(@"End Date via ical_get_dtend: %@", icalproperty_get_dtend(end));
					*/
					
					NSDate *startDate = [self parseDate:[NSString stringWithCString:icalvalue_as_ical_string(sv) encoding:NSUTF8StringEncoding] timezone:timezonename];
					NSDate *endDate = [self parseDate:[NSString stringWithCString:icalvalue_as_ical_string(ev) encoding:NSUTF8StringEncoding] timezone:timezonename];
				
					
					//NSDate *s = [self par
					//startDate = [startDate initWithTimeIntervalSinceNow:<#(NSTimeInterval)secs#>
				
					NSLog(@"Starts: %@, Ends: %@", startDate, endDate);
					//whenTextField.text = [NSString stringWithFormat:@"%@ - %@", startDate, endDate];
				
					[calendarDetails setValue:startDate forKey:@"StartDate"];
					[calendarDetails setValue:endDate forKey:@"EndDate"];
				
			
					NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
					[df setDateFormat:@"cccc, LLL d, yyyy"];
			
					NSDateFormatter *tf = [[[NSDateFormatter alloc] init] autorelease];
					[tf setDateFormat:@"h:mm a"];
					
					// Create a formatted date/time string here - ie, Tuesday, July 12, 2010 from 4:30PM to 11:00PM
					// Doing this here to ease a little memory and make it easier to autoresize the cell height later on
					NSString *resp = @"";
					
					// Check if the start / stop are on the same physical day
					if ( [[df stringFromDate:startDate] isEqualToString:[df stringFromDate:endDate]] ) {
						// Check if the times are the same as well, meaning an all-day event
						if ([[tf stringFromDate:startDate] isEqualToString:[tf stringFromDate:endDate]]) {
							resp = @"All day on ";
							resp = [resp stringByAppendingString:[df stringFromDate:startDate]];
						} else {
							resp = [df stringFromDate:startDate];
							resp = [resp stringByAppendingString:@"\nfrom "];
							resp = [resp stringByAppendingString:[tf stringFromDate:startDate]];
							resp = [resp stringByAppendingString:@" to "];
							resp = [resp stringByAppendingString:[tf stringFromDate:endDate]];
						}
					} else {
						// Check if the times are the same (meaning, a multiday event)
						if ([[tf stringFromDate:startDate] isEqualToString:[tf stringFromDate:endDate]]) {
							resp = [df stringFromDate:startDate];
							resp = [resp stringByAppendingString:@" to "];
							resp = [resp stringByAppendingString:[df stringFromDate:endDate]];
						} else {
							resp = [tf stringFromDate:startDate];
							resp = [resp stringByAppendingString:@" "];
							resp = [resp stringByAppendingString:[df stringFromDate:startDate]];
							resp = [resp stringByAppendingString:@" until "];
							resp = [resp stringByAppendingString:[tf stringFromDate:endDate]];
							resp = [resp stringByAppendingString:@" "];
							resp = [resp stringByAppendingString:[df stringFromDate:endDate]];
						}
					}
					[calendarDetails setValue:resp forKey:@"FormattedDateTime"];
					NSLog(@"Formatted dt: %@", resp);
					//				[[[NSString stringWithCString:icalvalue_as_ical_string(sv) encoding:NSUTF8StringEncoding] stringByAppendingString:@" - "] stringByAppendingString:[NSString stringWithCString:icalvalue_as_ical_string(ev) encoding:NSUTF8StringEncoding]];
				} else {
					NSLog(@"Start / End not found");
					[calendarDetails setValue:nil forKey:@"FormattedDateTime"];
					//whenTextField.text = @"";
				}
				/*
				icalproperty *tzidprop = icalcomponent_get_first_property(c, ICAL_TZID_PROPERTY);
				if (tzidprop)
				{
					const char *tzid;
					tzid = icalproperty_get_tzid(tzidprop);
					NSLog(@"Timezone: %s", tzid);
				}
				 */
				//icalproperty *attendees = icalcomponent_get_first_property(c, ICAL_
			
				icalproperty *organizer = icalcomponent_get_first_property(c, ICAL_ORGANIZER_PROPERTY);
			
				if (organizer) {
					icalvalue *v = icalproperty_get_value(organizer);
					icalparameter *name = icalproperty_get_first_parameter(organizer, ICAL_CN_PARAMETER);
					NSLog(@"Organizer: %@", [NSString stringWithCString:icalvalue_as_ical_string(v) encoding:NSUTF8StringEncoding]);
				
					NSString *organizer;
					NSString *organizercn;
					if (name) {
						char *n = icalparameter_get_cn(name);
						organizercn = [NSString stringWithCString:n encoding:NSUTF8StringEncoding];
						NSLog(@"Organizer CN: %@", organizercn);
						//organizerTextField.text = [NSString stringWithCString:n encoding:NSUTF8StringEncoding];
						[calendarDetails setValue:organizercn forKey:@"OrganizerCN"];
					}
					organizer = [[[NSString stringWithCString:icalvalue_as_ical_string(v) encoding:NSUTF8StringEncoding] componentsSeparatedByString:@":"] objectAtIndex:1];
					NSLog(@"Organizer: %@", organizer);
					[calendarDetails setValue:organizer forKey:@"Organizer"];

				
				} else {
					NSLog(@"Organizer not found");
					//organizerTextField.text = @"";
				}
			
				icalproperty *status = icalcomponent_get_first_property(c, ICAL_STATUS_PROPERTY);
			
				if (status) {
					icalvalue *v = icalproperty_get_value(status);
					NSLog(@"Status: %@", [NSString stringWithCString:icalvalue_as_ical_string(v) encoding:NSUTF8StringEncoding]);
					[calendarDetails setValue:[NSString stringWithCString:icalvalue_as_ical_string(v) encoding:NSUTF8StringEncoding] forKey:@"Status"];
				} else {
					NSLog(@"Status not found");
				}
			
				icalproperty *summary = icalcomponent_get_first_property(c, ICAL_SUMMARY_PROPERTY);
			
				if (summary) {
					icalvalue *v = icalproperty_get_value(summary);
					NSLog(@"Summary: %@", [NSString stringWithCString:icalvalue_as_ical_string(v) encoding:NSUTF8StringEncoding]);
					[calendarDetails setValue:[NSString stringWithCString:icalvalue_as_ical_string(v) encoding:NSUTF8StringEncoding] forKey:@"Summary"];
				} else {
					NSLog(@"Summary not found");
				}
			
				icalproperty *uid = icalcomponent_get_first_property(c, ICAL_UID_PROPERTY);
			
				if (uid) {
					icalvalue *v = icalproperty_get_value(uid);
					NSLog(@"UID: %@", [NSString stringWithCString:icalvalue_as_ical_string(v) encoding:NSUTF8StringEncoding]);
					[calendarDetails setValue:[NSString stringWithCString:icalvalue_as_ical_string(v) encoding:NSUTF8StringEncoding] forKey:@"UID"];
				} else {
					NSLog(@"UID not found");
				}
			
				c = icalcomponent_get_next_component(root, ICAL_VEVENT_COMPONENT);
			}
		
			icalcomponent_free(root);
		
			self.inviteDetails = calendarDetails;
			
			UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] init];
			rightButton.target = self;
			rightButton.style = UIBarButtonItemStyleBordered;
	
			rightButton.title = @"Save";
			rightButton.action = @selector(saveEvent);
			rightButton.enabled = YES;
	
			self.navigationItem.rightBarButtonItem = rightButton;
			NSLog(@"Adding button...");
			[rightButton release];
			
			// Check if there's an event at the same time on the calendar
			NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:[calendarDetails valueForKey:@"StartDate"] endDate:[calendarDetails valueForKey:@"EndDate"] calendars:nil];
	
			NSArray *events = [self.eventStore eventsMatchingPredicate:predicate];
	
			if ([events count] == 1)
			{
				NSLog(@"%d event(s) found around the same time as new event", [events count]);
				warningLabel.text = @"This event conflicts with 1 appointment";
			} else if ([events count] > 0) {
				NSLog(@"%d event(s) found around the same time as new event", [events count]);
				warningLabel.text = [NSString stringWithFormat:@"This event conflicts with %d appointments", [events count]];
			} else {
				NSLog(@"No events found at same time");
				warningLabel.text = @"";
			}
	
	
			[calendarDetails release];
		}
		
	}
}

- (void) saveEvent {
	NSLog(@"Oh yeah... save Event...");
	[self addToCalendar:self.inviteDetails];
}

- (void) refresh {
	NSLog(@"Refresh...");
	[self.navigationController popToRootViewControllerAnimated:NO];
	ICS_ReaderAppDelegate *appDelegate = (ICS_ReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
	self.launchURL = appDelegate.launchURL;
	if (!self.launchURL) { 
		[self.view bringSubviewToFront:self.noICSView];
		self.noICSWarningLabel.text = @"No ICS file selected - Please open an ICS file - refer to help for more info";
		[self showHelp]; 
	} else {
		[self.view sendSubviewToBack:self.noICSView];
	}
	//UIAlertView *someError2 = [[UIAlertView alloc] initWithTitle:@"Setting launchURL in rootview!" message:[self.launchURL absoluteString] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	//	[someError2 show];
	//	[someError2 release];
	[self parseICS];
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark Help Page
- (void) showHelp {
	NSLog(@"Help...");
	[self.navigationController pushViewController:self.helpViewController animated:YES];
}

- (void) didRotate {
	if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
		self.bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifier320x50;
		self.contentWidth = [NSNumber numberWithFloat:280.0];
	} else {
		self.bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifier480x32;
		self.contentWidth = [NSNumber numberWithFloat:440.0];
	}

}

#pragma mark -
#pragma mark Calendar Save
- (EKCalendar *)eventEditViewControllerDefaultCalendarForNewEvents:(EKEventEditViewController *)controller {
	EKCalendar *calendarForEdit = self.defaultCalendar;
	return calendarForEdit;
}

- (void) addToCalendar:(NSMutableDictionary *)calDetails
{
	NSLog(@"In AddToCalendar: %@", calDetails);

	EKEventEditViewController *addController = [[EKEventEditViewController alloc] initWithNibName:nil bundle:nil];
	
	addController.eventStore = self.eventStore;
	
	if ([calDetails valueForKey:@"Summary"]) { addController.event.title = [calDetails valueForKey:@"Summary"]; }
	if ([calDetails valueForKey:@"Location"]) { addController.event.location = [calDetails valueForKey:@"Location"]; }
	if ([calDetails valueForKey:@"Description"]) { addController.event.notes = [calDetails valueForKey:@"Description"]; }
	if ([calDetails valueForKey:@"StartDate"]) { addController.event.startDate = [calDetails valueForKey:@"StartDate"]; }
	if ([calDetails valueForKey:@"EndDate"]) { addController.event.endDate = [calDetails valueForKey:@"EndDate"]; }
	
	//EKParticipant *p = [[EKParticipant alloc] init];
	//[p setValue:@"Mike Metzger" forKey:@"name"];
	//[p setValue:@"mailto:mike@flexiblecreations.com" forKey:@"URL"];
	
	//[addController.event.attendees arrayByAddingObject:p];
	//if ([calDetails	valueForKey:@"UID"]) { addController.event.eventIdentifier = [calDetails valueForKey:@"UID"]; }
		
	[self presentModalViewController:addController animated:YES];
	
	addController.editViewDelegate = self;
	
	[addController release];
	
}


- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
	
	NSError *error = nil;
	//EKEvent *thisEvent = controller.event;
	
	switch (action) {
		case EKEventEditViewActionCanceled:
			NSLog(@"Event not saved...");
			break;
		case EKEventEditViewActionSaved:
			NSLog(@"Chose to save event...");
			[controller.eventStore saveEvent:controller.event span:EKSpanThisEvent error:&error];
			UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Calendar" message:@"Calendar entry saved!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
			[alert show];
			ICS_ReaderAppDelegate *appDelegate = (ICS_ReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
			appDelegate.launchURL = nil;
			self.launchURL = nil;
			self.inviteDetails = nil;
			[self.tableView reloadData];
			self.navigationItem.rightBarButtonItem = nil;
			self.warningLabel.text = @"";
			break;

		default:
			break;
	}
	
	[controller dismissModalViewControllerAnimated:YES];
}



#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:@"RefreshSent" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate) name:UIDeviceOrientationDidChangeNotification object:nil];
	self.bannerView.requiredContentSizeIdentifiers = [NSSet setWithObjects:
													  ADBannerContentSizeIdentifier320x50,
													  ADBannerContentSizeIdentifier480x32,
													  nil];

	self.contentWidth = [NSNumber numberWithFloat:280.0];
	[self moveBannerViewOffscreen];
	self.title = @"ICS Reader";
	
	self.eventStore = [[EKEventStore alloc] init];
	self.defaultCalendar = [self.eventStore defaultCalendarForNewEvents];
	ICS_ReaderAppDelegate *appDelegate = (ICS_ReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
	
										  
	self.launchURL = appDelegate.launchURL;
	
	NSLog(@"In RootViewController:viewDidLoad - URL: %@", self.launchURL);
	self.tableView.sectionFooterHeight = 0.0;
	
	self.helpViewController = [[HelpViewController alloc] init];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showHelp) name:@"ShowHelp" object:nil];
	
	sectionArray = [[NSArray arrayWithObjects:@"Title & Location", @"When", @"Organizer", @"Details", nil] retain];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] init];
	leftButton.target = self;
	leftButton.style = UIBarButtonItemStyleBordered;
	leftButton.title = @"Help";
	leftButton.action = @selector(showHelp);
	leftButton.enabled = YES;
	
	self.navigationItem.leftBarButtonItem = leftButton;
	NSLog(@"Adding help button...");
	[leftButton release];
	
	if (!self.launchURL) { 
		noICSView.autoresizingMask = UIViewAutoresizingFlexibleWidth; 
		noICSWarningLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[self.view bringSubviewToFront:self.noICSView];
		self.noICSWarningLabel.text = @"No ICS file selected - Please open an ICS file - refer to help for more info";
		[self showHelp]; 
	} else {
		[self.view sendSubviewToBack:self.noICSView];
	}

}


/*
- (void)viewWillAppear:(BOOL)animated {
	NSLog(@"In rootViewController - viewWillAppear");
    [super viewWillAppear:animated];
}
*/

 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	//ICS_ReaderAppDelegate *appDelegate = (ICS_ReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
	//if (appDelegate.isIntro)
	//{
	//	return NO;
	//} else {
		return YES;
	//}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	// Make sure proper ad size is displayed based on interface orientation
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
		self.bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifier320x50;
		self.contentWidth = [NSNumber numberWithFloat:280.0];
	} else {
		self.bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifier480x32;
		self.contentWidth = [NSNumber numberWithFloat:440.0];
	}
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (self.launchURL)
	{
		return 4;
	} else {
		return 0;
	}

}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {	
	//NSLog(@"In titleForHeaderInSection: %d", section);
	return (NSString *)[sectionArray objectAtIndex:section];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"In cellForRowAtIndexPath: %@", indexPath);
	static NSString *CellIdentifier;// = @"Cell";
    //if (cell == nil) {
    //    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    //}
	switch ([indexPath indexAtPosition:0]) {
		case 0:
			CellIdentifier = @"TitleCell";
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
			}
			NSLog(@"In title & location");
			NSLog(@"Summary: %@", [self.inviteDetails valueForKey:@"Summary"]);
			cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
			cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
			cell.textLabel.text = [self.inviteDetails valueForKey:@"Summary"];
			cell.detailTextLabel.text = [self.inviteDetails valueForKey:@"Location"];
//			cell.textLabel.text = [[[NSString alloc] init] stringByAppendingFormat:@"%@\n%@", [self.inviteDetails valueForKey:@"Summary"], [inviteDetails objectForKey:@"Location"]];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			return cell;
			break;
		case 1:
			CellIdentifier = @"DateTimeCell";
			//[[NSBundle mainBundle] loadNibNamed:@"DateTimeTableViewCell" owner:self options:nil];
			//DateTimeTableViewCell *dtcell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			//if (dtcell == nil) {
				//dtcell = [[[DateTimeTableViewCell alloc] initWithStyle:UITableViewStylePlain reuseIdentifier:CellIdentifier] autorelease];
			//	dtcell = dtTableCell;
			//}
			//cell = dtTableCell;

			//cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
			NSLog(@"In Date...");
			//cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
			//cell.textLabel.text = [[[NSString alloc] init] stringByAppendingFormat:@"Starts: %@", [self.inviteDetails valueForKey:@"StartDate"]];
			//cell.detailTextLabel.font = cell.textLabel.font;
			//cell.detailTextLabel.text = [[[NSString alloc] init] stringByAppendingFormat:@"Ends: %@", [inviteDetails objectForKey:@"EndDate"]];
			
			//dtcell.dtstart.text = [[[NSString alloc] init] stringByAppendingFormat:@"%@", [self.inviteDetails valueForKey:@"StartDate"]] ;
			//dtcell.dtend.text = [[[NSString alloc] init] stringByAppendingFormat:@"%@", [self.inviteDetails valueForKey:@"EndDate"]];
			//return dtcell;
			
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
				cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
				cell.textLabel.numberOfLines = 0;
				cell.textLabel.font = [UIFont systemFontOfSize:17.0];
			}
			
			/*
			NSDate *sdate = [self.inviteDetails valueForKey:@"StartDate"];
			NSDate *edate = [self.inviteDetails valueForKey:@"EndDate"];
			
			NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
			[df setDateFormat:@"cccc, LLL d, yyyy"];
			
			NSDateFormatter *tf = [[[NSDateFormatter alloc] init] autorelease];
			[tf setDateFormat:@"h:mm a"];
			if (sdate == nil)
			{
				cell.textLabel.text = @"";
			} else if ( [[df stringFromDate:sdate] isEqualToString:[df stringFromDate:edate]] ) {
				NSString *resp = [df stringFromDate:sdate];
				resp = [resp stringByAppendingString:@"\nfrom "];
				resp = [resp stringByAppendingString:[tf stringFromDate:sdate]];
				resp = [resp stringByAppendingString:@" to "];
				resp = [resp stringByAppendingString:[tf stringFromDate:edate]];
				cell.textLabel.text = resp;
			} else {
				if ([[tf stringFromDate:sdate] isEqualToString:[tf stringFromDate:edate]]) {
					NSString *resp = [df stringFromDate:sdate];
					resp = [resp stringByAppendingString:@" to "];
					resp = [resp stringByAppendingString:[df stringFromDate:edate]];
					cell.textLabel.text = resp;
				} else {
					NSString *resp = [tf stringFromDate:sdate];
					resp = [resp stringByAppendingString:@" "];
					resp = [df stringFromDate:sdate];
					resp = [resp stringByAppendingString:@" until "];
					resp = [resp stringByAppendingString:[tf stringFromDate:edate]];
					resp = [resp stringByAppendingString:@" "];
					resp = [resp stringByAppendingString:[df stringFromDate:edate]];
					cell.textLabel.text = resp;
				}
			}
			 */
			cell.textLabel.text = [self.inviteDetails valueForKey:@"FormattedDateTime"];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			return cell;
			
			break;
		case 2:
			CellIdentifier = @"OrganizerCell";
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
			NSString *organizercn = [self.inviteDetails valueForKey:@"OrganizerCN"];
			if (organizercn != nil)
			{
				cell.textLabel.text = organizercn;
				cell.detailTextLabel.text = [self.inviteDetails valueForKey:@"Organizer"];
			} else {
				cell.textLabel.text = [self.inviteDetails valueForKey:@"Organizer"];
			}
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			return cell;
			break;
		case 3:
			CellIdentifier = @"DetailsCell";
			//UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			NSLog(@"In Notes...");
			NSString *d;
			d = [self.inviteDetails valueForKey:@"Description"];
			UIFont *f = [UIFont systemFontOfSize:17];
			CGSize s;
			s = [d sizeWithFont:f];
			CGFloat w = [self.contentWidth floatValue];
			CGRect contentRect = CGRectMake(10.0, 5.0, w, s.height + 10);
			UILabel *t = [[UILabel alloc] initWithFrame:contentRect];
			t.text = d;
			t.numberOfLines = 0;
			[t sizeToFit];
			[cell.contentView addSubview:t];
			[t release];
			//cell.textLabel.text = [[[NSString alloc] init] stringByAppendingFormat:@"%@", [self.inviteDetails valueForKey:@"Description"]];
			//NSLog(@"%@", cell.textLabel.text);
			//cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			return cell;
			break;
		default:
			break;
	}
    
	// Configure the cell.

    return nil;
}

- (NSString *)getTextForIndexPath:(NSIndexPath *)indexPath
{
	switch ([indexPath indexAtPosition:0]) {
		case 3:
			return [self.inviteDetails valueForKey:@"Description"];
			break;
		default:
			return @"";
			break;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([indexPath indexAtPosition:0] == 0 || [indexPath indexAtPosition:0] == 2) {
		return 60.0;
	} else if ([indexPath indexAtPosition:0] == 3) {
		//NSString *t = [self getTextForIndexPath:indexPath];
		//UIFont *f = [UIFont systemFontOfSize:17];
		//CGSize s = [t sizeWithFont:f];
		//return s.height + 11;
		
		
		NSString *d;
		d = [self.inviteDetails valueForKey:@"Description"];
		if (d == nil)
		{
			return 60.0;
		} else {
			UIFont *f = [UIFont systemFontOfSize:17];
			CGSize s;
			s = [d sizeWithFont:f];
			CGFloat w = [self.contentWidth floatValue];
			CGRect contentRect = CGRectMake(10.0, 5.0, w, s.height + 10);
			UILabel *t = [[UILabel alloc] initWithFrame:contentRect];
			t.text = d;
			t.numberOfLines = 0;
			[t sizeToFit];
			return t.frame.size.height + 11;
		}
	} else {
		NSString *d;
		d = [self.inviteDetails valueForKey:@"FormattedDateTime"];
		if (d == nil)
		{
			return 60.0;
		} else {
			UIFont *f = [UIFont systemFontOfSize:17];
			CGSize s;
			s = [d sizeWithFont:f];
			CGFloat w = [self.contentWidth floatValue];
			CGRect contentRect = CGRectMake(10.0, 5.0, w, s.height + 10);
			UILabel *t = [[UILabel alloc] initWithFrame:contentRect];
			t.text = d;
			t.numberOfLines = 0;
			[t sizeToFit];
			return t.frame.size.height + 11;
		}
	}
}

#pragma mark -
#pragma mark Table view delegate
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
//}



#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}




@end

