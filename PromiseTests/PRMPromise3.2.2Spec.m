//
//  PRMPromise3.2.2Spec.m
//  Promise
//
//  Created by Klaas Pieter Annema on 16-06-13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "Kiwi.h"
#import "helpers.h"

SPEC_BEGIN(PRMPromise3_2_2Spec)

__block NSDictionary *dummy = @{ @"dummy": @"dummy" };

__block id value;
//__block id reason;

describe(@"3.2.2: If ~onFulfilled` is a function, ", ^{
    it(@"3.2.2.1: must be called after `promise` is fulfilled, with `promise`'s fulfillment value as its first argument", ^{
        fulfilled(dummy).then(^(id theValue) {
            value = theValue;
        }, nil);
        
        [[value should] equal:dummy];
    });
    
    describe(@"3.2.2.2: it must not be called more than once.", ^{
        it(@"already-fulfilled", ^{
            __block NSUInteger timesCalled = 0;
            fulfilled(dummy).then(^(id theValue) {
                timesCalled++;
            }, nil);
            
            [[theValue(timesCalled) should] equal:theValue(1)];
        });
        
        it(@"trying to fulfill a pending promise more than once, immediately", ^{
            PRMPending *tuple = PRMAdapter.pending;
            __block NSUInteger timesCalled = 0;
            
            tuple.promise.then(^(id theValue) {
                timesCalled++;
            }, nil);
            
            tuple.fulfill(dummy);
            tuple.fulfill(dummy);
            
            [[theValue(timesCalled) should] equal:theValue(1)];
        });
        
        pending(@"trying to fulfill a pending promise more than once, delayed", ^{
            
        });
    });
});

SPEC_END

    //         specify("trying to fulfill a pending promise more than once, immediately", function (done) {
    //             var tuple = pending();
    //             var timesCalled = 0;
    
    //             tuple.promise.then(function onFulfilled() {
    //                 assert.strictEqual(++timesCalled, 1);
    //                 done();
    //             });
    
    //             tuple.fulfill(dummy);
    //             tuple.fulfill(dummy);
    //         });
    
    //         specify("trying to fulfill a pending promise more than once, delayed", function (done) {
    //             var tuple = pending();
    //             var timesCalled = 0;
    
    //             tuple.promise.then(function onFulfilled() {
    //                 assert.strictEqual(++timesCalled, 1);
    //                 done();
    //             });
    
    //             setTimeout(function () {
    //                 tuple.fulfill(dummy);
    //                 tuple.fulfill(dummy);
    //             }, 50);
    //         });
    
    //         specify("trying to fulfill a pending promise more than once, immediately then delayed", function (done) {
    //             var tuple = pending();
    //             var timesCalled = 0;
    
    //             tuple.promise.then(function onFulfilled() {
    //                 assert.strictEqual(++timesCalled, 1);
    //                 done();
    //             });
    
    //             tuple.fulfill(dummy);
    //             setTimeout(function () {
    //                 tuple.fulfill(dummy);
    //             }, 50);
    //         });
    
    //         specify("when multiple `then` calls are made, spaced apart in time", function (done) {
    //             var tuple = pending();
    //             var timesCalled = [0, 0, 0];
    
    //             tuple.promise.then(function onFulfilled() {
    //                 assert.strictEqual(++timesCalled[0], 1);
    //             });
    
    //             setTimeout(function () {
    //                 tuple.promise.then(function onFulfilled() {
    //                     assert.strictEqual(++timesCalled[1], 1);
    //                 });
    //             }, 50);
    
    //             setTimeout(function () {
    //                 tuple.promise.then(function onFulfilled() {
    //                     assert.strictEqual(++timesCalled[2], 1);
    //                     done();
    //                 });
    //             }, 100);
    
    //             setTimeout(function () {
    //                 tuple.fulfill(dummy);
    //             }, 150);
    //         });
    
    //         specify("when `then` is interleaved with fulfillment", function (done) {
    //             var tuple = pending();
    //             var timesCalled = [0, 0];
    
    //             tuple.promise.then(function onFulfilled() {
    //                 assert.strictEqual(++timesCalled[0], 1);
    //             });
    
    //             tuple.fulfill(dummy);
    
    //             tuple.promise.then(function onFulfilled() {
    //                 assert.strictEqual(++timesCalled[1], 1);
    //                 done();
    //             });
    //         });
    //     });
    
    //     describe("3.2.2.3: it must not be called if `onRejected` has been called.", function () {
    //         testRejected(dummy, function (promise, done) {
    //             var onRejectedCalled = false;
    
    //             promise.then(function onFulfilled() {
    //                 assert.strictEqual(onRejectedCalled, false);
    //                 done();
    //             }, function onRejected() {
    //                 onRejectedCalled = true;
    //             });
    
    //             setTimeout(done, 100);
    //         });
    
    //         specify("trying to reject then immediately fulfill", function (done) {
    //             var tuple = pending();
    //             var onRejectedCalled = false;
    
    //             tuple.promise.then(function onFulfilled() {
    //                 assert.strictEqual(onRejectedCalled, false);
    //                 done();
    //             }, function onRejected() {
    //                 onRejectedCalled = true;
    //             });
    
    //             tuple.reject(dummy);
    //             tuple.fulfill(dummy);
    //             setTimeout(done, 100);
    //         });
    
    //         specify("trying to reject then fulfill, delayed", function (done) {
    //             var tuple = pending();
    //             var onRejectedCalled = false;
    
    //             tuple.promise.then(function onFulfilled() {
    //                 assert.strictEqual(onRejectedCalled, false);
    //                 done();
    //             }, function onRejected() {
    //                 onRejectedCalled = true;
    //             });
    
    //             setTimeout(function () {
    //                 tuple.reject(dummy);
    //                 tuple.fulfill(dummy);
    //             }, 50);
    //             setTimeout(done, 100);
    //         });
    
    //         specify("trying to reject immediately then fulfill delayed", function (done) {
    //             var tuple = pending();
    //             var onRejectedCalled = false;
    
    //             tuple.promise.then(function onFulfilled() {
    //                 assert.strictEqual(onRejectedCalled, false);
    //                 done();
    //             }, function onRejected() {
    //                 onRejectedCalled = true;
    //             });
    
    //             tuple.reject(dummy);
    //             setTimeout(function () {
    //                 tuple.fulfill(dummy);
    //             }, 50);
    //             setTimeout(done, 100);
    //         });
    //     });
    // });