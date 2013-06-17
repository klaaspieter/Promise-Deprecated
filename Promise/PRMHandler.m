//
//  PRMHandler.m
//  Promise
//
//  Created by Klaas Pieter Annema on 16-06-13.
//
//

#import "PRMHandler.h"

@implementation PRMHandler

- (id)initWithFulfilledHandler:(PRMPromiseResolverBlock)onFulfilled
               rejectedHandler:(PRMPromiseResolverBlock)onRejected
                      resolver:(PRMPromiseResolverBlock)theResolver
                      rejector:(PRMPromiseResolverBlock)theRejector;
{
    if (self = [super init])
    {
        _onFulfilled = onFulfilled;
        _onRejected = onRejected;
        _resolver = theResolver;
        _rejector = theRejector;
    }
    
    return self;
}

@end
