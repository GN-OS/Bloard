#include "CFSharedCode.h"

void CFNCAddObserver(CFNotificationCallback callback, const char *notificationName) {
	CFStringRef cfStr = CFStringCreateWithCString(NULL, notificationName, kCFStringEncodingUTF8);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, callback, cfStr, NULL, CFNotificationSuspensionBehaviorCoalesce);
	CFRelease(cfStr);
	return;
}

void CFNCPostNotification(const char *notificationName) {
	CFStringRef cfStr = CFStringCreateWithCString(NULL, notificationName, kCFStringEncodingUTF8);
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), cfStr, NULL, NULL, YES);
	CFRelease(cfStr);
	return;
}
