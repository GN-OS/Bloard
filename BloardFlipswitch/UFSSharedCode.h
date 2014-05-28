#ifndef UFS_SHARED_CODE_H
#define UFS_SHARED_CODE_H

#include <CoreFoundation/CFNotificationCenter.h>

#define STRINGIFY_(x) # x
#define STRINGIFY(x) STRINGIFY_(x)

#define PASTE_(a,b) a ## b
#define PASTE(a,b) PASTE_(a,b)

#ifdef __cplusplus
#define CPLUSPLUS_EXTERN	extern "C"
#else
#define CPLUSPLUS_EXTERN	
#endif

#ifdef UFS_USE_NSUSERDEFAULTS
#define NSGetPathFromNotificationName(n) [[NSUserDefaults standardUserDefaults] _filePathForDomain:n]
#else
#define NSGetPathFromNotificationName(n) [NSHomeDirectory() stringByAppendingFormat:@"/Library/Preferences/%s.plist", (n)]
#endif

#define notificationCallback() static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)

CPLUSPLUS_EXTERN void CFNCAddObserver(const char *notificationName, CFNotificationCallback callback);
CPLUSPLUS_EXTERN void CFNCPostNotification(const char *notificationName);

CPLUSPLUS_EXTERN CFPropertyListRef CFPGetKey(const char *notificationName, const char *key);
CPLUSPLUS_EXTERN Boolean CFPSetKey(const char *notificationName, const char *key, void *object);

CPLUSPLUS_EXTERN id NSPGetKey(const char *notificationName, const char *key);
CPLUSPLUS_EXTERN BOOL NSPSetKey(const char *notificationName, const char *key, void *object);

#endif /* UFS_SHARED_CODE_H */
