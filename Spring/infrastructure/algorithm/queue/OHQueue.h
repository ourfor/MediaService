//
//  OHQueue.h
//  MediaService
//
//  Created by 梁甜 on 2022/9/7.
//

#ifndef OHQueue_h
#define OHQueue_h

#import <stdio.h>
#import <Foundation/Foundation.h>

typedef struct OHQueue {
    id elements;
    int length;
} OHQueue;

void OHQueueInit(OHQueue *queue);

/// return given queue elements size
int OHQueueLength(OHQueue *queue);

void OHEnQueue(OHQueue *queue, id element);

id OHDeQueue(OHQueue *queue);

BOOL OHIsEmptyQueue(OHQueue *queue);

#endif /* OHQueue_h */
