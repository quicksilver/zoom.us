//
//  ZoomSource.h
//  Zoom
//
//  Created by Rob McBroom
//

#define QSZoomMeetingType @"QSZoomMeetingType"
#define ZoomURLFormat @"zoommtg://%@/join?action=join&confno=%@"
#define ZoomIDFormat @"ZoomMeeting:%@"
#define kZoomMeetingID @"ZoomMeetingID"
#define kForwardMinutes @"ZoomCheckForwardMinutes"
#define JoinMeetingWithIDAction @"QSZoomJoinMeetingWithID"
#define kMeetingID @"id"
#define kMeetingHost @"host"
#define kMeetingParams @"params"

#import <EventKit/EventKit.h>

NSURL *zoomURLWithData(NSDictionary *meetingData);
QSObject *objectFromEvent(EKEvent *event, NSDictionary *meetingData);
NSURL *getRedirectURL(NSURL *url);
NSDictionary *meetingDataFromString(NSString *sourceText);
NSDictionary *meetingDataFromEvent(EKEvent *event);
