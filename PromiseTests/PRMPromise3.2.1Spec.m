//
//  PRMPromise3.2.1Spec.m
//  Promise
//
//  Created by Klaas Pieter Annema on 16-06-13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "Kiwi.h"

#import "PRMPromise.h"
#import "helpers.h"

SPEC_BEGIN(PRMPromise3_2_1Spec)

__block NSDictionary *dummy = @{ @"dummy": @"dummy" };

__block id value;
__block id reason;

describe(@"3.2.1: Both `onFulfilled` and `onRejected` are optional arguments", ^{
    it(@"3.2.1.1: must be ignored if `onFulfilled is not a function", ^{
        rejected(dummy).then(nil, ^id (id theReason) {
            reason = theReason;
            return theReason;
        });
        
        waitForIt();
        [[reason should] equal:dummy];
    });
    
    it(@"3.2.1.2: it must be ignored if `onRejected` is not a function", ^{
        fulfilled(dummy).then(^id (id theValue) {
            value = theValue;
            return theValue;
        }, nil);
        
        waitForIt();
        [[value should] equal:dummy];
    });
});

SPEC_END


