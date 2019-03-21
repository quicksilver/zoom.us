//
//  Zoom Plug-in
//  QSZoomSource.m
//
//  Created by Rob McBroom
//

#import "QSZoom.h"
#import "QSZoomSource.h"

@implementation QSZoomSource

#pragma mark Catalog Entry Methods

// Try to determine if the source data has changed.
// If so, index is invalid - return NO to have it rescanned.
// If not, return YES to skip an unneccessary rescan.
- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry
{
	return YES;
}

// create and return an array of QSObjects to add to the catalog
- (NSArray *) objectsForEntry:(NSDictionary *)theEntry
{
	return nil;
}

# pragma mark Object Handler

- (NSString *)detailsOfObject:(QSObject *)object
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	if ([object isProxyObject]) {
		QSObject *meeting = [object objectForCache:QSProxyTargetCache];
		if ([meeting containsType:QSZoomMeetingType]) {
			EKEvent *event = [meeting objectForType:QSZoomMeetingType];
			NSString *start = [dateFormatter stringFromDate:[event startDate]];
			return [NSString stringWithFormat:@"%@ at %@", [meeting name], start];
		}
		return nil;
	}
	return nil;
}

# pragma mark Proxy Objects

- (QSObject *)resolveProxyObject:(QSProxyObject *)proxy
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSUInteger minutesForward = [[defaults valueForKey:kForwardMinutes] integerValue];
	NSUInteger interval = minutesForward * 60;
	EKEventStore *store = [[EKEventStore alloc] initWithAccessToEntityTypes:EKEntityMaskEvent];
	NSDate *now = [NSDate date];
	NSDate *cutoff = [NSDate dateWithTimeIntervalSinceNow:interval];
	NSPredicate *query = [store predicateForEventsWithStartDate:now endDate:cutoff calendars:nil];
	NSArray *events = [store eventsMatchingPredicate:query];
	// pick the zoom event that hasn't started
	EKEvent *targetEvent = nil;
	NSString *targetID;
	for (EKEvent *upcomingEvent in events) {
		NSString *meetingID = meetingIDFromEvent(upcomingEvent);
		if (!meetingID) {
			// skip events with no Zoom URL
			continue;
		}
		if ([[upcomingEvent startDate] compare:now] == NSOrderedDescending) {
			// prefer an event in the future
			targetID = meetingID;
			targetEvent = upcomingEvent;
			break;
		}
		targetID = meetingID;
		targetEvent = upcomingEvent;
	}
	if (targetEvent) {
		return objectFromEvent(targetEvent, targetID);
	}
	return [QSObject objectWithString:@"No Upcoming Meeting"];
}

- (NSArray *)typesForProxyObject:(id)proxy
{
	return [[proxy objectForCache:QSProxyTargetCache] types];
}

@end
