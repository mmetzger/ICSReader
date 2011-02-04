    //
//  HelpViewController.m
//  ICS Reader
//
//  Created by Mike Metzger on 1/27/11.
//  Copyright 2011 Psycho Pigeon Software. All rights reserved.
//

#import "HelpViewController.h"


@implementation HelpViewController
@synthesize helpView;

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


// Implement loadView to create a view hierarchy programmatically, without using a nib.
/*- (void)loadView {
}*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	CGRect webFrame = self.view.frame;
	helpView = [[UIWebView alloc] initWithFrame:webFrame];
	helpView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	helpView.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:helpView];
	
	NSString *html = @"<html><body>This tool will help you read calendar files from various sources.  Opening it directly won't help significantly as it will automatically read any linked .ics files from applications that support document reading (DropBox, Mail (including before 4.2), Safari, and so forth.)  <p>Regarding ICS files in Mail.app - if like most users, you want to read calendar invitations that you receive via e-mail.  Unfortunately, versions of iOS prior to 4.2 have an issue properly handling these attachments.  It doesn't even properly recognize that these attachments can be interacted with.  We have discovered a workaround that makes opening these files possible.<p>To workaround this issue, forward the e-mail containing the calendar invite to resend@icsreader.com.  The server will reply with the calendar attachment in a form that can be opened by ICS Reader.  <b>NOTE: This is not required if you're running iOS 4.2 or later.</b><p>To open the attachment, press and hold on the icon for the attachment and a window will pop up allowing you to open the attachment in ICS Reader.  Press the ICS Reader and it will parse the file for you, showing the details and giving you the option of saving the appointment to your calendar.<p>&nbsp;</p><p>&nbsp;</p></body></html>";
	[helpView loadHTMLString:html baseURL:[NSURL URLWithString:@"http://www.icsreader.com"]];

}

- (void)viewWillDisappear:(BOOL)animated
{
	[self.navigationController popToRootViewControllerAnimated:animated];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}




- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
	NSLog(@"Received memory warning in help...");
    //[super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[helpView release];
    [super dealloc];
}


@end
