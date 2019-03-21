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
	NSUInteger eventCount = [events count];
	if (eventCount) {
		EKEvent *targetEvent;
		if (eventCount == 1) {
			targetEvent = events[0];
		} else {
			// pick the event that hasn't started
			for (EKEvent *upcomingEvent in events) {
				if ([[upcomingEvent startDate] compare:now] == NSOrderedDescending) {
					targetEvent = upcomingEvent;
					break;
				}
			}
		}
		NSString *meetingID = meetingIDFromEvent(targetEvent);
		if (meetingID) {
			return objectFromEvent(targetEvent, meetingID);
		}
	}
	return [QSObject objectWithString:@"No Upcoming Meeting"];
}

- (NSArray *)typesForProxyObject:(id)proxy
{
	return [[proxy resolvedObject] types];
}

@end
