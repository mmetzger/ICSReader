    //
//  DetailViewController.m
//  ICS Reader
//
//  Created by Mike Metzger on 2/3/11.
//  Copyright 2011 Psycho Pigeon Software. All rights reserved.
//

#import "DetailViewController.h"


@implementation DetailViewController

@synthesize data;
@synthesize detailView;
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

- (void) didRotate {
	NSString *htmldata = [data stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
	htmldata = [htmldata stringByAppendingString:@"<br /><br /><br />"];
//	NSString *html = @"<html><body>This tool will help you read calendar files from various sources.  Opening it directly won't help significantly as it will automatically read any linked .ics files from applications that support document reading (DropBox, Mail (including before 4.2), Safari, and so forth.)  <p>Regarding ICS files in Mail.app - if like most users, you want to read calendar invitations that you receive via e-mail.  Unfortunately, versions of iOS prior to 4.2 have an issue properly handling these attachments.  It doesn't even properly recognize that these attachments can be interacted with.  We have discovered a workaround that makes opening these files possible.<p>To workaround this issue, forward the e-mail containing the calendar invite to resend@icsreader.com.  The server will reply with the calendar attachment in a form that can be opened by ICS Reader.  <b>NOTE: This is not required if you're running iOS 4.2 or later.</b><p>To open the attachment, press and hold on the icon for the attachment and a window will pop up allowing you to open the attachment in ICS Reader.  Press the ICS Reader and it will parse the file for you, showing the details and giving you the option of saving the appointment to your calendar.<p>&nbsp;</p><p>&nbsp;</p></body></html>";
	[detailView loadHTMLString:htmldata baseURL:[NSURL URLWithString:@"http://www.icsreader.com"]];
    
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	
	NSURL *url = [request URL];
	
	if (UIWebViewNavigationTypeLinkClicked == navigationType)
	{
		NSLog(@"Link called to %@", url);
		[[UIApplication sharedApplication] openURL:url];
		return NO;
	}
	return YES;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate) name:UIDeviceOrientationDidChangeNotification object:nil];

	CGRect webFrame = self.view.frame;
	detailView = [[UIWebView alloc] initWithFrame:webFrame];
	detailView.delegate = self;
	detailView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	detailView.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:detailView];
	
	NSString *htmldata = [data stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
	htmldata = [htmldata stringByAppendingString:@"<br /><br /><br />"];
//	NSString *html = @"<html><body>This tool will help you read calendar files from various sources.  Opening it directly won't help significantly as it will automatically read any linked .ics files from applications that support document reading (DropBox, Mail (including before 4.2), Safari, and so forth.)  <p>Regarding ICS files in Mail.app - if like most users, you want to read calendar invitations that you receive via e-mail.  Unfortunately, versions of iOS prior to 4.2 have an issue properly handling these attachments.  It doesn't even properly recognize that these attachments can be interacted with.  We have discovered a workaround that makes opening these files possible.<p>To workaround this issue, forward the e-mail containing the calendar invite to resend@icsreader.com.  The server will reply with the calendar attachment in a form that can be opened by ICS Reader.  <b>NOTE: This is not required if you're running iOS 4.2 or later.</b><p>To open the attachment, press and hold on the icon for the attachment and a window will pop up allowing you to open the attachment in ICS Reader.  Press the ICS Reader and it will parse the file for you, showing the details and giving you the option of saving the appointment to your calendar.<p>&nbsp;</p><p>&nbsp;</p></body></html>";
	[detailView loadHTMLString:htmldata baseURL:[NSURL URLWithString:@"http://www.icsreader.com"]];
    detailView.dataDetectorTypes = UIDataDetectorTypeLink;
	[super viewDidLoad];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[self.navigationController popViewControllerAnimated:animated];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[data release];
	[detailView release];
    [super dealloc];
}


@end
