//
//  Promise.m
//  Promise
//
//  Created by Klaas Pieter Annema on 13-06-13.
//
//

#import "PRMPromise.h"

@interface PRMPromise ()
@property (nonatomic, readwrite, strong) id value;
@property (nonatomic, readwrite, assign) BOOL isFulfilled;
@property (nonatomic, readwrite, strong) PRMFulfilledHandler onFulfilled;

@property (nonatomic, readwrite, strong) NSError *error;
@property (nonatomic, readwrite, assign) BOOL isRejected;
@property (nonatomic, readwrite, strong) PRMRejectedHandler onRejected;
@end

@implementation PRMPromise

- (ThenMethod)then;
{
    return ^(PRMFulfilledHandler onFulfilled, PRMRejectedHandler onReject) {
        
        if (self.isRejected)
            onReject(self.error);
        
        if (self.isFulfilled)
            onFulfilled(self.value);
        
        return self;
    };
}

- (PRMPromise *)rejectWithError:(NSError *)theError;
{
    if (self.onRejected)
        self.onRejected(theError);
    
    self.error = theError;
    self.isRejected = YES;
    
    return self;
}

- (PRMPromise *)fulfillWithValue:(id)theValue;
{
    if (theValue == self)
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:nil userInfo:nil];
    
    if (self.onFulfilled)
        self.onFulfilled(theValue);
    
    self.value = theValue;
    self.isFulfilled = YES;
    
    return self;
}

@end
