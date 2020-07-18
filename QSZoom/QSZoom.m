//
//  QSZoom.m
//  zoom.us Plugin
//
//  Created by Rob McBroom on 2019/3/8.
//  Copyright © 2019 Quicksilver. All rights reserved.
//

#import "QSZoom.h"

#pragma mark Helpers

// Zoom URL Scheme Documentation
// https://marketplace.zoom.us/docs/guides/guides/client-url-schemes

NSURL *zoomURLWithData(NSDictionary *meetingData) {
	NSString *host = meetingData[kMeetingHost];
	NSString *meetingID = meetingData[kMeetingID];
	NSString *meetingArgs = meetingID;
	NSString *meetingParams = meetingData[kMeetingParams];
	if (meetingParams) {
		meetingArgs = [NSString stringWithFormat:@"%@&%@", meetingID, meetingParams];
	}
	NSString *meetingURL = [NSString stringWithFormat:ZoomURLFormat, host, meetingArgs];
	NSURL *url = [NSURL URLWithString:meetingURL];
	return url;
}

QSObject *objectFromEvent(EKEvent *event, NSDictionary *meetingData) {
	NSString *meetingID = meetingData[kMeetingID];
	NSString *ident = [NSString stringWithFormat:ZoomIDFormat, meetingID];
	NSString *urlString = [zoomURLWithData(meetingData) absoluteString];
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

NSDictionary *meetingDataFromString(NSString *sourceText) {
	NSRegularExpression *zoomURL = [NSRegularExpression regularExpressionWithPattern:@"^http[s?]:.*zoom\\.us/.*" options:NSRegularExpressionAnchorsMatchLines error:nil];
	NSRange range = NSMakeRange(0, [sourceText length]);
	if ([zoomURL numberOfMatchesInString:sourceText options:0 range:range]) {
		// looks like a Zoom URL
		NSURL *meetingURL = [NSURL URLWithString:sourceText];
		NSMutableDictionary *meetingData = [NSMutableDictionary dictionaryWithCapacity:3];
		meetingData[kMeetingID]	 = [meetingURL lastPathComponent];
		meetingData[kMeetingHost]  = [meetingURL host];
		NSString *query = [meetingURL query];
		if (query) {
			meetingData[kMeetingParams]	 = query;
		}
		return meetingData;
	}
	return nil;
}

NSDictionary *meetingDataFromEvent(EKEvent *event) {
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
		NSDictionary *meetingData = meetingDataFromString(field);
		if (meetingData) {
			return meetingData;
		}
	}
	return nil;
}
