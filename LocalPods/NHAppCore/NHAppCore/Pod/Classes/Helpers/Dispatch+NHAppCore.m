//
//  Dispatch+NHAppCore.m
//  Pods
//
//  Created by Sergey Minakov on 01.10.15.
//
//

#import "Dispatch+NHAppCore.h"

void main_async(dispatch_block_t block, BOOL syncMainThread) {
    if (syncMainThread
        && [NSThread isMainThread]
        && block) {
        block();
    }
    else if (block) {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

void queue_main(dispatch_block_t block) {
    dispatch_async(dispatch_get_main_queue(), block);
}

void queue_async(dispatch_queue_priority_t queueIdentifier, dispatch_block_t block) {
    dispatch_async(dispatch_get_global_queue(queueIdentifier, 0), block);
}

dispatch_time_t dispatch_get_time(NSTimeInterval timeInterval)
{
    return dispatch_time(DISPATCH_TIME_NOW,
                         (int64_t)(timeInterval * NSEC_PER_SEC));
}

void delay(NSTimeInterval time, dispatch_block_t block) {
    dispatch_after(dispatch_get_time(time),
                   dispatch_get_main_queue(),
                   block);
}

void delay_async(NSTimeInterval time, dispatch_queue_priority_t queueIdentifier, dispatch_block_t block) {
    dispatch_after(dispatch_get_time(time),
                   dispatch_get_global_queue(queueIdentifier, 0),
                   block);
}