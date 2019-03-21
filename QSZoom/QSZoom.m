//
//  QSZoom.m
//  zoom.us Plugin
//
//  Created by Rob McBroom on 2019/3/8.
//  Copyright © 2019 Quicksilver. All rights reserved.
//

#import "QSZoom.h"

#pragma mark Helpers

NSURL *zoomURLWithID(NSString *meetingID) {
	NSString *meetingURL = [NSString stringWithFormat:ZoomURLFormat, meetingID];
	NSURL *url = [NSURL URLWithString:meetingURL];
	return url;
}

QSObject *objectFromEvent(EKEvent *event, NSString *meetingID) {
	NSString *ident = [NSString stringWithFormat:ZoomIDFormat, meetingID];
	NSString *urlString = [zoomURLWithID(meetingID) absoluteString];
	QSObject *meeting = [QSObject makeObjectWithIdentifier:ident];
	[meeting setName:[event title]];
	[meeting setObject:meetingID forMeta:kZoomMeetingID];
	[meeting setObject:urlString forType:QSURLType];
	[meeting setObject:urlString forType:QSTextType];
	[meeting setObject:event forType:QSZoomMeetingType];
	[meeting setPrimaryType:QSZoomMeetingType];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	NSString *start = [dateFormatter stringFromDate:[event startDate]];
	NSString *end = [dateFormatter stringFromDate:[event endDate]];
	[meeting setDetails:[NSString stringWithFormat:@"%@ – %@", start, end]];
	return meeting;
}

NSString *meetingIDFromString(NSString *sourceText) {
	NSRegularExpression *zoomURL = [NSRegularExpression regularExpressionWithPattern:@".*zoom\\.us/.*[=/](\\d+)$" options:NSRegularExpressionAnchorsMatchLines error:nil];
	NSRange range = NSMakeRange(0, [sourceText length]);
	NSTextCheckingResult *result = [zoomURL firstMatchInString:sourceText options:0 range:range];
	if ([result numberOfRanges] == 2) {
		NSRange matchLocation = [result rangeAtIndex:1];
		NSString *meetingID = [sourceText substringWithRange:matchLocation];
		return meetingID;
	}
	return nil;
}

NSString *meetingIDFromEvent(EKEvent *event) {
	NSMutableArray *searchFields = [NSMutableArray arrayWithCapacity:3];
	if ([event URL]) {
		[searchFields addObject:[[event URL] absoluteString]];
	}
	if ([event location]) {
		[searchFields addObject:[event location]];
	}
	if ([event notes]) {
		[searchFields addObject:[event notes]];
	}
	for (NSString *field in searchFields) {
		NSString *meetingID = meetingIDFromString(field);
		if (meetingID) {
			return meetingID;
		}
	}
	return nil;
}
