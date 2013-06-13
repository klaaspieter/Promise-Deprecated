//
//  PromiseSpec.m
//  Promise
//
//  Created by Klaas Pieter Annema on 13-06-13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "Kiwi.h"

#import "PRMPromise.h"

SPEC_BEGIN(PRMPromiseSpec)

__block PRMFulfilledHandler fulfilledBlock;
__block PRMRejectedHandler rejectedBlock;

__block id fulfilledValue;
__block NSError *rejectedError;

beforeEach(^{
    fulfilledBlock = ^(id theValue) {
        fulfilledValue = theValue;
    };
    
    rejectedBlock = ^(NSError *theError) {
        rejectedError = theError;
    };
});

afterEach(^{
    fulfilledValue = nil;
    rejectedError = nil;
});

it(@"raises an InvalidArgumentException if the resolved value is the same as the promise", ^{
    __block PRMPromise *promise1 = [[PRMPromise alloc] init];
    
    [[theBlock(^{
       [promise1 fulfillWithValue:promise1];
    }) should] raiseWithName:NSInvalidArgumentException];
});

it(@"can fulfill a promise", ^{
    NSString *value = @"value";
    PRMPromise *promise = [[PRMPromise alloc] init];
    promise.then(fulfilledBlock, rejectedBlock);
    [promise fulfillWithValue:value];
    
    [[fulfilledValue should] equal:value];
    [rejectedError shouldBeNil];
});

it(@"can reject a promise", ^{
    NSError *error = [NSError errorWithDomain:@"" code:0 userInfo:nil];
    PRMPromise *promise = [[PRMPromise alloc] init];
    promise.then(fulfilledBlock, rejectedBlock);
    [promise rejectWithError:error];
    
    [[rejectedError should] equal:error];
    [fulfilledValue shouldBeNil];
});

SPEC_END


