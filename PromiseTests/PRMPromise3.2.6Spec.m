//
//  PRMPromise3.2.6Spec.m
//  Promise
//
//  Created by Klaas Pieter Annema on 18-06-13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "Kiwi.h"
#import "helpers.h"

SPEC_BEGIN(PRMPromise3_2_6Spec)

__block NSDictionary *dummy = @{@"dummy": @"dummy"};
__block NSDictionary *sentinel = @{@"sentinel": @"sentinel"};

describe(@"3.2.6: `then` must return a promise: `promise2 = promise1.then(onFulfilled, onRejected)`", ^{
    it(@"is a promise", ^{
        PRMPromise *promise1 = PRMAdapter.pending.promise;
        PRMPromise *promise2 = promise1.then(nil, nil);
        
        [[promise2 should] beKindOfClass:[PRMPromise class]];
        [[promise2 should] respondsToSelector:@selector(then)];
    });
    
    it(@"3.2.6.1: If either `onFulfilled` or `onRejected` returns a value that is not a promise, `promise2` must be fulfilled with that value.", ^{
        void (^testValue)(id expectedValue);
        testValue = ^(id expectedValue) {
            PRMPromise *promise1 = fulfilled(dummy);
            PRMPromise *promise2 = promise1.then(^id (id theValue) {
                return expectedValue;
            }, nil);
            
            __block id value1;
            promise2.then(^id (id theValue) {
                value1 = theValue;
                return nil;
            }, nil);
            
            
            PRMPromise *promise3 = rejected(dummy);
            PRMPromise *promise4 = promise3.then(nil, ^id (id theReason) {
                return expectedValue;
            });
            
            __block id value2;
            promise4.then(^id (id theValue) {
                value2 = theValue;
                return nil;
            }, nil);
            
            
            waitForIt();
            if (!expectedValue)
            {
                [value1 shouldBeNil];
                [value2 shouldBeNil];
            }
            else
            {
                [[value1 should] equal:expectedValue];
                [[value2 should] equal:expectedValue];
            }
        };
        
        testValue(nil);
        testValue(@0);
        testValue([NSError errorWithDomain:@"" code:0 userInfo:nil]);
        testValue([NSDate date]);
        testValue(@{});
    });
    
    it(@"3.2.6.2: If either `onFulfilled` or `onRejected` throws an exception, `promise2` must be rejected with the thrown exception as the reason.", ^{
        void (^testReason)(NSException *expectedReason);
        testReason = ^(NSException *expectedReason) {
            PRMPromise *promise1 = fulfilled(dummy);
            PRMPromise *promise2 = promise1.then(^id (id theValue) {
                @throw expectedReason;
            }, nil);
            
            __block id reason1;
            promise2.then(nil, ^id (id theReason) {
                reason1 = theReason;
                return nil;
            });
            
            
            PRMPromise *promise3 = rejected(dummy);
            PRMPromise *promise4 = promise3.then(nil, ^id (id theReason) {
                @throw expectedReason;
            });
            
            __block id reason2;
            promise4.then(nil, ^id (id theReason) {
                reason2 = theReason;
                return nil;
            });
            
            
            waitForIt();
            if (!expectedReason)
            {
                [reason1 shouldBeNil];
                [reason2 shouldBeNil];
            }
            else
            {
                [[reason1 should] equal:expectedReason];
                [[reason2 should] equal:expectedReason];
            }
        };
        
        testReason([NSException exceptionWithName:NSInvalidArgumentException reason:@"" userInfo:nil]);
    });
    
    describe(@"3.2.6.3: If either `onFulfilled` or `onRejected` returns a promise (call it `returnedPromise`), `promise2` must assume the state of `returnedPromise`", ^{
        it(@"3.2.6.3.1: If `returnedPromise` is pending, `promise2` must remain pending until `returnedPromise` is fulfilled or rejected.", ^{
            PRMPromise *promise1 = fulfilled(dummy);
            __block BOOL wasFulfilled1 = NO;
            __block BOOL wasRejected1 = NO;
            
            PRMPromise *promise2 = promise1.then(^id (id theValue) {
                return PRMAdapter.pending.promise;
            }, nil);
            
            promise2.then(^id (id theValue) {
                wasFulfilled1 = YES;
                return nil;
            }, ^id (id theReason) {
                wasRejected1 = NO;
                return nil;
            });
            
            PRMPromise *promise3 = rejected(dummy);
            __block BOOL wasFulfilled2 = NO;
            __block BOOL wasRejected2 = NO;
            
            PRMPromise *promise4 = promise3.then(nil, ^id (id theValue) {
                return PRMAdapter.pending.promise;
            });
            
            promise4.then(^id (id theValue) {
                wasFulfilled2 = YES;
                return nil;
            }, ^id (id theReason) {
                wasRejected2 = YES;
                return nil;
            });
            
            waitForIt();
            [[theValue(wasFulfilled1) should] beNo];
            [[theValue(wasRejected1) should] beNo];
            [[theValue(wasFulfilled2) should] beNo];
            [[theValue(wasRejected2) should] beNo];
        });
        
        describe(@"3.2.6.3.2: If/when `returnedPromise` is fulfilled, `promise2` must be fulfilled with the same value.", ^{
            describe(@"`promise1` is fulfilled, and `returnedPromise` is:", ^{
                it(@"fulfilled", ^{
                    PRMPromise *promise1 = fulfilled(dummy);
                    PRMPromise *promise2 = promise1.then(^id (id theValue) {
                        return fulfilled(sentinel);
                    }, nil);
                    
                    __block id value;
                    promise2.then(^id (id theValue) {
                        value = theValue;
                        return nil;
                    }, nil);
                    
                    waitForIt();
                    [[value should] equal:sentinel];
                });
            });
            
            describe(@"`promise1` is rejected, and `returnedPromise` is:", ^{
                it(@"fulfilled", ^{
                    PRMPromise *promise1 = rejected(dummy);
                    PRMPromise *promise2 = promise1.then(nil, ^id (id theReason) {
                        return fulfilled(sentinel);
                    });
                    
                    __block id value;
                    promise2.then(^id (id theValue) {
                        value = theValue;
                        return nil;
                    }, nil);
                    
                    waitForIt();
                    [[value should] equal:sentinel];
                });
            });
        });
        
        describe(@"3.2.6.3.3: If/when `returnedPromise` is rejected, `promise2` must be rejected with the same reason.", ^{
            describe(@"`promise1` is fulfilled, and `returnedPromise` is:", ^{
                it(@"rejected", ^{
                    PRMPromise *promise1 = fulfilled(dummy);
                    PRMPromise *promise2 = promise1.then(^id (id theValue) {
                        return rejected(sentinel);
                    }, nil);
                    
                    __block id reason;
                    promise2.then(nil, ^id (id theReason) {
                        reason = theReason;
                        return nil;
                    });
                    
                    waitForIt();
                    [[reason should] equal:sentinel];
                });
            });
            
            describe(@"`promise1` is rejected, and `returnedPromise` is:", ^{
                it(@"rejected", ^{
                    PRMPromise *promise1 = rejected(dummy);
                    PRMPromise *promise2 = promise1.then(nil, ^id (id theReason) {
                        return rejected(sentinel);
                    });
                    
                    __block id reason;
                    promise2.then(nil, ^id (id theReason) {
                        reason = theReason;
                        return nil;
                    });
                    
                    waitForIt();
                    [[reason should] equal:sentinel];
                });
            });
        });
        
        describe(@"3.2.6.4: If `onFulfilled` is not a function and `promise1` is fulfilled, `promise2` must be fulfilled", ^{
            it(@"fulfilled", ^{
                void (^testNonFunction)(id nonFunction);
                testNonFunction = ^(id nonFunction) {
                    PRMPromise *promise1 = fulfilled(sentinel);
                    PRMPromise *promise2 = promise1.then(nonFunction, nil);
                    
                    __block id value;
                    promise2.then(^id (id theValue) {
                        value = theValue;
                        return nil;
                    }, nil);
                    
                    waitForIt();
                    [[value should] equal:sentinel];
                };

                testNonFunction(nil);
                testNonFunction(@5);
                testNonFunction(@{});
            });
        });
        
        describe(@"3.2.6.5: If `onRejected` is not a function and `promise1` is rejected, `promise2` must be rejected with the same reason.", ^{
            it(@"rejected", ^{
                void (^testNonFunction)(id nonFunction);
                testNonFunction = ^(id nonFunction) {
                    PRMPromise *promise1 = rejected(sentinel);
                    PRMPromise *promise2 = promise1.then(nil, nonFunction);
                    
                    __block id reason;
                    promise2.then(nil, ^id (id theReason) {
                        reason = theReason;
                        return nil;
                    });
                    
                    waitForIt();
                    [[reason should] equal:sentinel];
                };
                
                testNonFunction(nil);
                testNonFunction(@5);
                testNonFunction(@{});
            });
        });
    });
});

SPEC_END