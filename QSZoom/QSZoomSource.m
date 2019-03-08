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
	if ([[object primaryType] isEqualToString:QSProxyType]) {
		QSObject *meeting = [object resolvedObject];
		if (meeting) {
			EKEvent *event = [meeting objectForType:QSZoomMeetingType];
			NSString *start = [dateFormatter stringFromDate:[event startDate]];
			return [NSString stringWithFormat:@"%@ at %@", [meeting name], start];
		}
		return @"No Upcoming Meeting";
	}
	if (object) {
		EKEvent *event = [object objectForType:QSZoomMeetingType];
		NSString *start = [dateFormatter stringFromDate:[event startDate]];
		NSString *end = [dateFormatter stringFromDate:[event endDate]];
		return [NSString stringWithFormat:@"%@ – %@", start, end];
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
	NSDate *start = [NSDate date];
	NSDate *end = [NSDate dateWithTimeIntervalSinceNow:interval];
	NSPredicate *query = [store predicateForEventsWithStartDate:start endDate:end calendars:nil];
	NSArray *events = [store eventsMatchingPredicate:query];
	if ([events count]) {
		EKEvent *targetEvent = events[0];
		NSString *meetingID = meetingIDFromEvent(targetEvent);
		if (meetingID) {
			return objectFromEvent(targetEvent, meetingID);
		}
	}
	return nil;
}
@end