//
//  Dispatch+NHAppCore.h
//  Pods
//
//  Created by Sergey Minakov on 01.10.15.
//
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

extern void main_async(dispatch_block_t block, BOOL syncMainThread);
extern void queue_main(dispatch_block_t block);
extern void queue_async(dispatch_queue_priority_t queueIdentifier, dispatch_block_t block);

extern dispatch_time_t dispatch_get_time(NSTimeInterval time);

extern void delay(NSTimeInterval time, dispatch_block_t block);
extern void delay_async(NSTimeInterval time, dispatch_queue_priority_t queueIdentifier, dispatch_block_t block);

NS_ASSUME_NONNULL_END