//
//  ZoomSource.h
//  Zoom
//
//  Created by Rob McBroom
//

#define QSZoomMeetingType @"QSZoomMeetingType"
#define ZoomURLFormat @"zoommtg://zoom.us/join?confno=%@"
#define ZoomIDFormat @"ZoomMeeting:%@"
#define kZoomMeetingID @"ZoomMeetingID"
#define kForwardMinutes @"ZoomCheckForwardMinutes"
#define JoinMeetingWithIDAction @"QSZoomJoinMeetingWithID"

#import <EventKit/EventKit.h>

QSObject *objectFromEvent(EKEvent *event, NSString *meetingID);
NSString *meetingIDFromString(NSString *sourceText);
NSString *meetingIDFromEvent(EKEvent *event);
