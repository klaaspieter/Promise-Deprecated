//
//  PRMPromise3.2.4Spec.m
//  Promise
//
//  Created by Klaas Pieter Annema on 17-06-13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "Kiwi.h"
#import "helpers.h"

SPEC_BEGIN(PRMPromise3_2_4Spec)

__block NSDictionary *dummy = @{@"dummy": @"dummy"};

describe(@"3.2.4: `then` must return before `onFulfilled or `onRejected` is called", ^{
    it(@"fulfilled", ^{
        __block BOOL thenHasReturned = NO;
        __block BOOL blockWasCalled = NO;
        
        PRMPromise *promise = fulfilled(dummy);
        promise.then(^(id theValue) {
            [[theValue(thenHasReturned) should] beYes];
            blockWasCalled = YES;
        }, nil);
        
        thenHasReturned = YES;
        
        waitForIt();
        [[theValue(blockWasCalled) should] beYes];
    });
    
    it(@"rejected", ^{
        __block BOOL thenHasReturned = NO;
        __block BOOL blockWasCalled = NO;
        
        PRMPromise *promise = rejected(dummy);
        promise.then(nil, ^(id theReason) {
            [[theValue(thenHasReturned) should] beYes];
            blockWasCalled = YES;
        });
        
        thenHasReturned = YES;
        
        waitForIt();
        [[theValue(blockWasCalled) should] beYes];
    });
});

SPEC_END