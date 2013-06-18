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
        if ([onFulfilled isKindOfClass:NSClassFromString(@"NSBlock")])
            _onFulfilled = onFulfilled;
        
        if ([onRejected isKindOfClass:NSClassFromString(@"NSBlock")])
            _onRejected = onRejected;
        
        _resolver = theResolver;
        _rejector = theRejector;
    }
    
    return self;
}

@end
