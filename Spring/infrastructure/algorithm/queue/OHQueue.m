//
//  OHQueue.c
//  MediaService
//
//  Created by 梁甜 on 2022/9/7.
//

#include "OHQueue.h"

void OHQueueInit(OHQueue *queue) {
    if (!queue) {
        return;
    }
    
    queue->length = 0;
    queue->elements = [NSMutableArray arrayWithCapacity:32];
}

/// return given queue elements size
int OHQueueLength(OHQueue *queue) {
    if (!queue) {
        return 0;
    }
    
    return queue->length;
}

void OHEnQueue(OHQueue *queue, id element) {
    if (!queue) {
        return;
    }
    if ([queue->elements isKindOfClass:NSMutableArray.class]) {
        NSMutableArray *elements = (NSMutableArray *)queue->elements;
        [elements addObject:element];
    }
}

id OHDeQueue(OHQueue *queue) {
    if (!queue) {
        return nil;
    }
    
    if ([queue->elements isKindOfClass:NSMutableArray.class]) {
        NSMutableArray *elements = (NSMutableArray *)queue->elements;
        id element = [elements firstObject];
        [elements removeObjectAtIndex:0];
        return element;
    }
    
    return nil;
}

BOOL OHIsEmptyQueue(OHQueue *queue) {
    if (queue) {
        return queue->length == 0;
    }
    
    return YES;
}
