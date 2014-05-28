#include <CoreFoundation/CFPreferences.h>
#import <Foundation/NSUserDefaults.h>
#import <Foundation/NSString.h>
#include "UFSSharedCode.h"

@interface NSUserDefaults (UFS_Category)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end

CPLUSPLUS_EXTERN void CFNCAddObserver(const char *notificationName, CFNotificationCallback callback) {
	CFStringRef cfStr = CFStringCreateWithCString(NULL, notificationName, kCFStringEncodingUTF8);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, callback, cfStr, NULL, CFNotificationSuspensionBehaviorCoalesce);
	CFRelease(cfStr);
	return;
}

CPLUSPLUS_EXTERN void CFNCPostNotification(const char *notificationName) {
	CFStringRef cfStr = CFStringCreateWithCString(NULL, notificationName, kCFStringEncodingUTF8);
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), cfStr, NULL, NULL, YES);
	CFRelease(cfStr);
	return;
}

CPLUSPLUS_EXTERN CFPropertyListRef CFPGetKey(const char *notificationName, const char *key) {
	CFStringRef cfNotification = CFStringCreateWithCString(NULL, notificationName, kCFStringEncodingUTF8);
	CFStringRef cfKey = CFStringCreateWithCString(NULL, key, kCFStringEncodingUTF8);
	CFPropertyListRef r = CFPreferencesCopyAppValue(cfKey, cfNotification);
	CFRelease(cfNotification);
	CFRelease(cfKey);
	return r;
}

CPLUSPLUS_EXTERN Boolean CFPSetKey(const char *notificationName, const char *key, void *object) {
	CFStringRef cfNotification = CFStringCreateWithCString(NULL, notificationName, kCFStringEncodingUTF8);
	CFStringRef cfKey = CFStringCreateWithCString(NULL, key, kCFStringEncodingUTF8);
	CFPreferencesSetAppValue(cfKey, object, cfNotification);
	Boolean r = CFPreferencesAppSynchronize(cfNotification);
	CFRelease(cfNotification);
	CFRelease(cfKey);
	return r;
}

CPLUSPLUS_EXTERN id NSPGetKey(const char *notificationName, const char *key) {
	NSString *nsNotificationName = [[NSString alloc] initWithUTF8String:notificationName];
	NSString *nsKey = [[NSString alloc] initWithUTF8String:key];
	id r = [[NSUserDefaults standardUserDefaults] objectForKey:nsKey inDomain:nsNotificationName];
	[nsNotificationName release];
	[nsKey release];
	return r;
}

CPLUSPLUS_EXTERN BOOL NSPSetKey(const char *notificationName, const char *key, void *object) {
	NSString *nsNotificationName = [[NSString alloc] initWithUTF8String:notificationName];
	NSString *nsKey = [[NSString alloc] initWithUTF8String:key];
	[[NSUserDefaults standardUserDefaults] setObject:(id)(object) forKey:nsKey inDomain:nsNotificationName];
	[nsNotificationName release];
	[nsKey release];
	return [[NSUserDefaults standardUserDefaults] synchronize];
}
