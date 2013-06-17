//
//  Promise.m
//  Promise
//
//  Created by Klaas Pieter Annema on 13-06-13.
//
//

#import "PRMPromise.h"

#import "PRMHandler.h"

@interface PRMPromise ()
@property (nonatomic, readwrite, assign) BOOL isResolved;

@property (nonatomic, readwrite, strong) id value;
@property (nonatomic, readwrite, strong) id reason;

@property (nonatomic, readwrite, strong) NSMutableArray *deferreds;

@end

@implementation PRMPromise

- (id)init;
{
    return [self initWithResolver:nil];
}

- (id)initWithResolver:(PRMPromiseResolver)theResolver;
{
    NSParameterAssert(theResolver);
    
    if (self = [super init])
    {
        self.deferreds = [[NSMutableArray alloc] init];
        
        @try {
            theResolver(^PRMPromise * (id theValue) {
                [self resolvePromise:theValue];
                return nil;
            }, ^PRMPromise *(id theError) {
                [self rejectPromise:theError];
                return nil;
            });
        }
        @catch (NSException *exception) {
            [self rejectPromise:exception];
        }
    }
    
    return self;
}

- (void)resolvePromise:(id)theValue;
{
    if (self.isResolved)
        return;
    
    self.isResolved = YES;
    self.value = theValue;
    [self didResolve];
}

- (void)rejectPromise:(id)theReason;
{
    if (self.isResolved)
        return;
    
    self.isResolved = YES;
    self.reason = theReason;
    [self didResolve];
}

- (void)didResolve;
{
    [self.deferreds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self handle:obj];
    }];
    
}

- (void)handle:(PRMHandler *)theHandler;
{
    if (!self.isResolved)
    {
        [self.deferreds addObject:theHandler];
        return;
    }
    
    if (self.isFulfilled)
    {
        theHandler.onFulfilled(self.value);
        theHandler.resolver(self.value);
    }
    else
    {
        theHandler.onRejected(self.reason);
        theHandler.rejector(self.reason);
    }
}

- (ThenMethod)then;
{
    return ^(PRMFulfilledHandler onFulfilled, PRMRejectedHandler onRejected) {
        return [[PRMPromise alloc] initWithResolver:^(PRMPromiseResolverBlock resolve, PRMPromiseResolverBlock reject) {
            PRMHandler *handler = [[PRMHandler alloc] initWithFulfilledHandler:onFulfilled
                                                               rejectedHandler:onRejected
                                                                      resolver:resolve
                                                                      rejector:reject];
            [self handle:handler];
        }];
    };
}

- (BOOL)isRejected;
{
    return !!self.reason;
}

- (BOOL)isFulfilled;
{
    return !!self.value;
}

@end
