#import "NSArray+Extension.h"


@implementation NSArray(Extension)

- (id)firstWhere:(BOOL(^)(id))condition {
    for (id obj in self) {
        if (condition(obj)) {
            return obj;
        }
    }
    return nil;
}

- (void)forEach:(void (^)(id _Nonnull))block {
    for (id obj in self) {
        block(obj);
    }
}
@end
