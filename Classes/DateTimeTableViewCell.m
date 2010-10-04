//
//  DateTimeTableViewCell.m
//  ICS Reader
//
//  Created by Mike Metzger on 9/16/10.
//  Copyright 2010 Psycho Pigeon Software. All rights reserved.
//

#import "DateTimeTableViewCell.h"


@implementation DateTimeTableViewCell

@synthesize dtstart;
@synthesize dtend;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	[dtstart release];
	[dtend release];
    [super dealloc];
}


@end
