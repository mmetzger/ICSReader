//
//  DateTimeTableViewCell.h
//  ICS Reader
//
//  Created by Mike Metzger on 9/16/10.
//  Copyright 2010 Psycho Pigeon Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DateTimeTableViewCell : UITableViewCell {
	UILabel *dtstart;
	UILabel *dtend;
}

@property (nonatomic, retain) IBOutlet UILabel *dtstart;
@property (nonatomic, retain) IBOutlet UILabel *dtend;
@end
