#ifndef GNOSSHAREDCODE_H
#define GNOSSHAREDCODE_H

#include "CFSharedCode.h"

//macros start
#define PPstring_(x) #x
#define PPstring(x) PPstring_(x)
#define PPconcat_(a, b) a##b
#define PPconcat(a, b) PPconcat_(a, b)
#define PPprefix(a) PPconcat(PREFIX, a)

#define GNOSCreatePathFromNotificationName(n) [[NSString alloc] initWithFormat:@"%@/Library/Preferences/%s", NSHomeDirectory(), (n)]

//macros end


//function prototypes start

void GNOSpreferencesSetup(const char *notificationName);

BOOL GNOSpreferencesGetBoolKey(const char *notificationName, const char *keyName);
void GNOSpreferencesSetBoolKey(const char *notificationName, const char *keyName, BOOL b);
void GNOSpreferencesToggleBoolKey(const char *notificationName, const char *keyName);

#endif
