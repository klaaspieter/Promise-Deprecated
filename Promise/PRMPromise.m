//
//  Promise.m
//  Promise
//
//  Created by Klaas Pieter Annema on 13-06-13.
//
//

#import "PRMPromise.h"

@interface PRMPromise ()
@property (nonatomic, readwrite, strong) id value;
@property (nonatomic, readwrite, assign) BOOL isFulfilled;
@property (nonatomic, readwrite, strong) PRMFulfilledHandler onFulfilled;

@property (nonatomic, readwrite, strong) NSError *error;
@property (nonatomic, readwrite, assign) BOOL isRejected;
@property (nonatomic, readwrite, strong) PRMRejectedHandler onRejected;
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
    }
    
    return self;
}

- (ThenMethod)then;
{
    return nil;
}

@end
