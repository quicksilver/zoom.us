//
//  QSZoomAction.m
//  zoom.us Plugin
//
//  Created by Rob McBroom on 2019/3/7.
//

#import "QSZoom.h"
#import "QSZoomAction.h"

@implementation QSZoomActionProvider

- (QSObject *)join:(QSObject *)dObject
{
	if (!dObject) {
		NSBeep();
		return nil;
	}
	NSString *meetingURLString = [dObject objectForType:QSURLType];
	NSURL *url = [NSURL URLWithString:meetingURLString];
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

@end
