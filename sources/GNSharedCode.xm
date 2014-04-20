#include <stdlib.h>
#include "GNSharedCode.h"

static void GNOSpreferencesCreateFileIfNonExistent(const char *notificationName);
static void GNOSCFStringCopyUTF8String(CFStringRef string, char **buffer);
static void GNOSpreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo);
static void GNOSpreferencesChanged(const char *notificationName);

static NSMutableDictionary *GNOSpreferences = nil;

void GNOSpreferencesSetup(const char *notificationName) {
	GNOSpreferencesCreateFileIfNonExistent(notificationName);
	GNOSpreferencesChanged(notificationName);
	// register to receive changed notifications
	CFNCAddObserver(GNOSpreferencesChangedCallback, notificationName);
	return;
}

static void GNOSpreferencesCreateFileIfNonExistent(const char *notificationName) {
	NSString *path = GNOSCreatePathFromNotificationName(notificationName);
	if (! [[NSFileManager defaultManager] fileExistsAtPath:path]) {
		GNOSpreferencesSetBoolKey(notificationName, "enabled", YES);
	}
	[path release];
	return;
}

static void GNOSCFStringCopyUTF8String(CFStringRef string, char **buffer) {
	if (!string) {
		return;
	}
	CFIndex length = CFStringGetLength(string);
	char *b = (char *) malloc(length);
	if (!b) {
		return;
	}
	if (CFStringGetCString(string, b, length, kCFStringEncodingUTF8)) {
		*buffer = b;
	} else {
		*buffer = NULL;
		free(b);
	}
	return;
}

static void GNOSpreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	char *notificationName = NULL;//[(NSString *)name UTF8String];
	GNOSCFStringCopyUTF8String(name, &notificationName);
	GNOSpreferencesChanged(notificationName);
	free(notificationName);
	return;
}

static void GNOSpreferencesChanged(const char *notificationName) {
	NSString *path = GNOSCreatePathFromNotificationName(notificationName);
	// reload preferences
	if (!GNOSpreferences) {
		[GNOSpreferences release];
	}
	GNOSpreferences = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
	[path release];
	//don't use UI* so early
	//[[[[%c(UIAlertView) alloc] initWithTitle:[NSString stringWithUTF8String:notificationName] message:[GNOSpreferences description] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease] show];
	return;
}

BOOL GNOSpreferencesGetBoolKey(const char *notificationName, const char *keyName) {
	BOOL b;
	NSString *key = [[NSString alloc] initWithUTF8String:keyName];
#if 0
	NSString *path = GNOSCreatePathFromNotificationName(notificationName);
	NSDictionary *d = [[NSDictionary alloc] initWithContentsOfFile:path];
	[path release];
	*b = [[d objectForKey:key] boolValue]; //defaults to NO
	[d release];
#else
	b = [[GNOSpreferences objectForKey:key] boolValue];
#endif
	[key release];
	return b;
}

void GNOSpreferencesSetBoolKey(const char *notificationName, const char *keyName, BOOL b) {
	NSString *key = [[NSString alloc] initWithUTF8String:keyName];
	NSString *path = GNOSCreatePathFromNotificationName(notificationName);
#if 0
	//set value
	NSMutableDictionary *d;
	if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
		d = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
	} else {
		d = [[NSMutableDictionary alloc] init];
	}
	[d setObject:[NSNumber numberWithBool:b] forKey:key];
	[d writeToFile:path atomically:YES];
	[d release];
#else
	[GNOSpreferences setObject:[NSNumber numberWithBool:b] forKey:key];
	[GNOSpreferences writeToFile:path atomically:YES];
#endif
	[key release];
	[path release];
	return;
}

void GNOSpreferencesToggleBoolKey(const char *notificationName, const char *keyName) {
	GNOSpreferencesSetBoolKey(notificationName, keyName, !GNOSpreferencesGetBoolKey(notificationName, keyName));
	return;
}
