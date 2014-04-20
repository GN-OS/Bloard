#ifndef UROBORO_LOGBLOCK
#define UROBORO_LOGBLOCK

unsigned long long deepness = 0;

#define logStart0() do { NSLog(@"uroboro %d; %s {", deepness, __PRETTY_FUNCTION__); deepness++; } while (0)
#define logStart() do { NSLog(@"uroboro %lld; class: %@; method: %@; {", deepness, NSStringFromClass([self class]), NSStringFromSelector(_cmd)); deepness++; } while (0)
#define logEnd() do { deepness--; NSLog(@"uroboro; }%s", deepness?"":" //so deep"); } while (0)
#define logBlock(block) do { logStart(); block; logEnd(); } while (0)

#endif