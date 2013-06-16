//
//  PRMPromise3.2.1Spec.m
//  Promise
//
//  Created by Klaas Pieter Annema on 16-06-13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "Kiwi.h"

#import "PRMPromise.h"

SPEC_BEGIN(PRMPromise3_2_1Spec)

__block PRMPromiseResolverBlock fulfilled;
__block PRMPromiseResolverBlock rejected;
__block NSDictionary *dummy = @{ @"dummy": @"dummy" };

__block id value;
__block id reason;

beforeEach(^{
    fulfilled = ^PRMPromise *(id theReason) {
        return [[PRMPromise alloc] initWithResolver:^(PRMPromiseResolverBlock resolve, PRMPromiseResolverBlock reject) {
            resolve(theReason);
        }];
    };
    
    rejected = ^PRMPromise *(id theReason) {
        return [[PRMPromise alloc] initWithResolver:^(PRMPromiseResolverBlock resolve, PRMPromiseResolverBlock reject) {
            reject(theReason);
        }];
    };
});

describe(@"3.2.1: Both `onFulfilled` and `onRejected` are optional arguments", ^{
    it(@"3.2.1.1: must be ignored if `onFulfilled is not a function", ^{
        rejected(dummy).then(nil, ^(id theReason) {
            reason = theReason;
        });
        
        [[reason should] equal:dummy];
    });
    
    it(@"3.2.1.2: it must be ignored if `onRejected` is not a function", ^{
        fulfilled(dummy).then(^(id theValue) {
            value = theValue;
        }, nil);
        
        [[value should] equal:dummy];
    });
});

SPEC_END


