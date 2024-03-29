
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

@property (nonatomic, readwrite, assign) BOOL isDelegating;

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
            __weak typeof(self) weakSelf = self;
            theResolver(^PRMPromise * (id theValue) {
                
                if (weakSelf.isDelegating)
                    return nil;
                
                [weakSelf resolvePromise:theValue];
                return theValue;
            }, ^PRMPromise *(id theReason) {
                
                if (weakSelf.isDelegating)
                    return nil;
                
                [weakSelf rejectPromise:theReason];
                return theReason;
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
    
    @try {
        if (theValue == self)
        {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"A promise cannot be resolved with itself." userInfo:nil];
        }
        
        if (theValue && [theValue isKindOfClass:[PRMPromise class]])
        {
            self.isDelegating = YES;
            PRMPromise *promiseValue = (PRMPromise *)theValue;
            promiseValue.then(^id (id theValue) {
                [self resolvePromise:theValue];
                return nil;
            }, ^id (id theReason) {
                [self rejectPromise:theReason];
                return nil;
            });
            
            return;
        }
        
        
        self.isResolved = YES;
        self.value = theValue;
        [self didResolve];
    }
    @catch (NSException *exception) {
        [self rejectPromise:exception];
    }
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
    self.deferreds = [NSMutableArray array];
    
}

- (void)handle:(PRMHandler *)theHandler;
{
    if (!self.isResolved)
    {
        [self.deferreds addObject:theHandler];
        return;
    }
    
    PRMPromiseResolverBlock block = self.isFulfilled ? theHandler.onFulfilled : theHandler.onRejected;
    id value = self.isFulfilled ? self.value : self.reason;
    
    if (!block)
    {
        if (self.isFulfilled)
            theHandler.resolver(value);
        else
            theHandler.rejector(value);
        
        return;
    }
    
    id returnValue;
    @try {
        returnValue = block(value);
    }
    @catch (NSException *exception) {
        theHandler.rejector(exception);
        return;
    }
    
    theHandler.resolver(returnValue);
}

- (ThenMethod)then;
{
    return ^(PRMPromiseResolverBlock onFulfilled, PRMPromiseResolverBlock onRejected) {
        return [[[self class] alloc] initWithResolver:^(PRMPromiseResolverBlock resolve, PRMPromiseResolverBlock reject) {
            PRMHandler *handler = [[PRMHandler alloc] initWithFulfilledHandler:onFulfilled
                                                               rejectedHandler:onRejected
                                                                      resolver:resolve
                                                                      rejector:reject];
            [self performSelector:@selector(handle:) withObject:handler afterDelay:0.0];
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
