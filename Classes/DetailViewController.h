//
//  DetailViewController.h
//  ICS Reader
//
//  Created by Mike Metzger on 2/3/11.
//  Copyright 2011 Psycho Pigeon Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DetailViewController : UIViewController <UIWebViewDelegate> {

}
@property (nonatomic, retain) NSString *data;
@property (nonatomic, retain) UIWebView *detailView;
@end
