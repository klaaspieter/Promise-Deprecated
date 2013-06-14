//
//  Promise.h
//  Promise
//
//  Created by Klaas Pieter Annema on 13-06-13.
//
//

#import <Foundation/Foundation.h>

@class PRMPromise;

typedef void (^PRMFulfilledHandler)(id theResult);
typedef void (^PRMRejectedHandler)(NSError *theError);
typedef PRMPromise *(^ThenMethod)(PRMFulfilledHandler onFulfilled, PRMRejectedHandler onRejected);

typedef void (^PRMPromiseResolverBlock)();
typedef void (^PRMPromiseResolver)(PRMPromiseResolverBlock resolve, PRMPromiseResolverBlock reject);

@interface PRMPromise : NSObject

- (ThenMethod)then;

@end