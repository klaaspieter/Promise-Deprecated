//
//  PRMHandler.h
//  Promise
//
//  Created by Klaas Pieter Annema on 16-06-13.
//
//

#import <Foundation/Foundation.h>

#import "PRMPromise.h"

@interface PRMHandler : NSObject

@property (nonatomic, readonly, strong) PRMPromiseResolverBlock onFulfilled;
@property (nonatomic, readonly, strong) PRMPromiseResolverBlock onRejected;
@property (nonatomic, readonly, strong) PRMPromiseResolverBlock resolver;
@property (nonatomic, readonly, strong) PRMPromiseResolverBlock rejector;

- (id)initWithFulfilledHandler:(PRMPromiseResolverBlock)onFulfilled
               rejectedHandler:(PRMPromiseResolverBlock)onRejected
                      resolver:(PRMPromiseResolverBlock)theResolver
                      rejector:(PRMPromiseResolverBlock)theRejector;

@end
