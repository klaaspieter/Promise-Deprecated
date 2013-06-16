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
@property (nonatomic, readwrite, strong) NSError *error;

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
            theResolver(^(id theValue) {
                [self resolvePromise:theValue];
            }, ^(id theError) {
                [self rejectPromise:theError];
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
}

- (void)rejectPromise:(id)theError;
{
    if (self.isResolved)
        return;
    
    self.isResolved = YES;
    self.error = theError;
}

- (void)handle:(PRMHandler *)theHandler;
{
    if (self.isFulfilled)
    {
        theHandler.onFulfilled(self.value);
        theHandler.resolver(self.value);
    }
    else
    {
        theHandler.onRejected(self.error);
        theHandler.rejector(self.error);
    }
}

- (ThenMethod)then;
{
    return ^(PRMFulfilledHandler onFulfilled, PRMRejectedHandler onRejected) {
        return [[PRMPromise alloc] initWithResolver:^(PRMFulfilledHandler resolve, PRMRejectedHandler reject) {
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
    return !!self.error;
}

- (BOOL)isFulfilled;
{
    return !!self.value;
}

@end
