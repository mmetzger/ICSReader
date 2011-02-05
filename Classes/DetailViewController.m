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
	NSString *htmldata = @"<html><meta name=\"viewport\" content=\"width=";
	htmldata = [htmldata stringByAppendingFormat:@"%d", self.view.frame.size.width];
	htmldata = [htmldata stringByAppendingString:@"\"/>"];
	htmldata = [htmldata stringByAppendingString:[data stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"]];
	htmldata = [htmldata stringByAppendingString:@"<br /><br /><br />"];
	[detailView loadHTMLString:htmldata baseURL:[NSURL URLWithString:@"http://www.icsreader.com"]];
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	
	NSURL *url = [request URL];
	
	if (UIWebViewNavigationTypeLinkClicked == navigationType)
	{
		//NSLog(@"Link called to %@", url);
		[[UIApplication sharedApplication] openURL:url];
		return NO;
	}
	return YES;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate) name:UIDeviceOrientationDidChangeNotification object:nil];

	CGRect webFrame = self.view.frame;
	webFrame.origin.x = webFrame.origin.x - 5.0;
	webFrame.origin.y = webFrame.origin.y - 5.0;
	webFrame.size.width = webFrame.size.width + 5.0;
	webFrame.size.height = webFrame.size.height + 5.0;
	detailView = [[UIWebView alloc] initWithFrame:webFrame];
	detailView.delegate = self;
	detailView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	detailView.backgroundColor = [UIColor whiteColor];
	//detailView.scalesPageToFit = YES;
	[self.view addSubview:detailView];
	
	NSString *htmldata = @"<html><meta name=\"viewport\" content=\"width=";
	htmldata = [htmldata stringByAppendingFormat:@"%d", self.view.frame.size.width];
	htmldata = [htmldata stringByAppendingString:@"\"/>"];
	htmldata = [htmldata stringByAppendingString:[data stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"]];
	htmldata = [htmldata stringByAppendingString:@"<br /><br /><br />"];
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
