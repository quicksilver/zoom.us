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
	NSString *meetingInfo = [dObject stringValue];
	NSDictionary *dataFromString = meetingDataFromString(meetingInfo);
	if (dataFromString) {
		NSURL *url = zoomURLWithData(dataFromString);
		if (url) {
			[[NSWorkspace sharedWorkspace] openURL:url];
		} else {
			NSLog(@"error with meeting: %@", meetingInfo);
		}
	}
	return nil;
}

@end
