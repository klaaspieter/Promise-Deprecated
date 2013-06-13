//
//  PromiseSpec.m
//  Promise
//
//  Created by Klaas Pieter Annema on 13-06-13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "Kiwi.h"

#import "PRMPromise.h"

@interface TestObject : NSObject

- (PRMPromise *)fulfilledPromiseWithValue:(id)theValue;
- (PRMPromise *)rejectedPromiseWithError:(NSError *)theError;

@end

@implementation TestObject

- (PRMPromise *)fulfilledPromiseWithValue:(id)theValue;
{
    PRMPromise *promise = [[PRMPromise alloc] init];
    [promise fulfillWithValue:theValue];
    return promise;
}

- (PRMPromise *)rejectedPromiseWithError:(NSError *)theError;
{
    PRMPromise *promise = [[PRMPromise alloc] init];
    [promise rejectWithError:theError];
    return promise;
}

@end

SPEC_BEGIN(PRMPromiseSpec)

__block TestObject *testObject;
__block PRMFulfilledHandler fulfilledBlock;
__block PRMRejectedHandler rejectedBlock;

__block id fulfilledValue;
__block NSError *rejectedError;

beforeEach(^{
    testObject = [[TestObject alloc] init];
    
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
    PRMPromise *promise = [testObject fulfilledPromiseWithValue:value];
    promise.then(fulfilledBlock, rejectedBlock);
    
    [[fulfilledValue should] equal:value];
    [rejectedError shouldBeNil];
});

it(@"can reject a promise", ^{
    NSError *error = [NSError errorWithDomain:@"" code:0 userInfo:nil];
    PRMPromise *promise = [testObject rejectedPromiseWithError:error];
    promise.then(fulfilledBlock, rejectedBlock);
    
    [[rejectedError should] equal:error];
    [fulfilledValue shouldBeNil];
});

SPEC_END


