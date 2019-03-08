//
//  QSZoomAction.m
//  zoom.us Plugin
//
//  Created by Rob McBroom on 2019/3/7.
//

#import "QSZoom.h"
#import "QSZoomAction.h"

NSURL *zoomURLWithID(NSString *meetingID) {
	NSString *meetingURL = [NSString stringWithFormat:ZoomURLFormat, meetingID];
	NSURL *url = [NSURL URLWithString:meetingURL];
	return url;
}

@implementation QSZoomActionProvider

- (QSObject *)join:(QSObject *)dObject
{
	if (!dObject) {
		NSBeep();
		return nil;
	}
	NSString *meetingID = [dObject objectForMeta:kZoomMeetingID];
	NSURL *url = zoomURLWithID(meetingID);
	if (url) {
		[[NSWorkspace sharedWorkspace] openURL:url];
	} else {
		NSLog(@"error with meeting: %@", dObject);
	}
	return nil;
}

- (QSObject *)joinWithID:(QSObject *)dObject
{
	NSString *meetingID = [dObject stringValue];
	NSString *idFromString = meetingIDFromString(meetingID);
	if (idFromString) {
		meetingID = idFromString;
	}
	NSURL *url = zoomURLWithID(meetingID);
	if (url) {
		[[NSWorkspace sharedWorkspace] openURL:url];
	} else {
		NSLog(@"error with meeting: %@", meetingID);
	}
	return nil;
}

- (NSArray *)validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject
{
	NSString *meetingID = [dObject stringValue];
	// is this a string of digits?
	NSRegularExpression *digits = [NSRegularExpression regularExpressionWithPattern:@"^\\d+$" options:NSRegularExpressionAnchorsMatchLines error:nil];
	NSUInteger matches = [digits numberOfMatchesInString:meetingID options:0 range:NSMakeRange(0, [meetingID length])];
	if (!matches) {
		// try to extract a meeting ID from the text
		meetingID = meetingIDFromString(meetingID);
		if (!meetingID) {
			return nil;
		}
	}
	return @[JoinMeetingWithIDAction];
}

@end
