//
//  helpers.c
//  Promise
//
//  Created by Klaas Pieter Annema on 16-06-13.
//
//

#import "PRMPromise.h"

PRMPromiseResolverBlock fulfilled = ^PRMPromise *(id theReason) {
    return [[PRMPromise alloc] initWithResolver:^(PRMPromiseResolverBlock resolve, PRMPromiseResolverBlock reject) {
            resolve(theReason);
            }];
};

PRMPromiseResolverBlock rejected = ^PRMPromise *(id theReason) {
    return [[PRMPromise alloc] initWithResolver:^(PRMPromiseResolverBlock resolve, PRMPromiseResolverBlock reject) {
            reject(theReason);
            }];
};