#ifndef CFSHAREDCODE_H
#define CFSHAREDCODE_H

#include <CoreFoundation/CFNotificationCenter.h>

void CFNCAddObserver(CFNotificationCallback callback, const char *notificationName);
void CFNCPostNotification(const char *notificationName);

#endif