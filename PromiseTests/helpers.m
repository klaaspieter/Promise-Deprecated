#import "helpers.h"

@interface PRMPending ()
@property (nonatomic, readwrite, strong) PRMPromise *promise;
@property (nonatomic, readwrite, strong) PRMPromiseResolverBlock fulfill;
@property (nonatomic, readwrite, strong) PRMPromiseResolverBlock reject;
@end

@implementation PRMPending

- (id)init;
{
    if (self = [super init])
    {
        _promise = [[PRMPromise alloc] initWithResolver:^(PRMPromiseResolverBlock theResolver, PRMPromiseResolverBlock theRejector) {
            _fulfill = theResolver;
            _reject = theRejector;
        }];
    }
    
    return self;
}

@end

@implementation PRMAdapter

+ (id)pending;
{
    return [[PRMPending alloc] init];
}

@end

PRMPromise *fulfilled(id theValue) {
    return [[PRMPromise alloc] initWithResolver:^(PRMPromiseResolverBlock resolve, PRMPromiseResolverBlock reject) {
        resolve(theValue);
    }];
};

PRMPromise *rejected(id theReason) {
    return [[PRMPromise alloc] initWithResolver:^(PRMPromiseResolverBlock resolve, PRMPromiseResolverBlock reject) {
        reject(theReason);
    }];
};