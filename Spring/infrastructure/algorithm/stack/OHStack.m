//
//  OHStack.c
//  MediaService
//
//  Created by 梁甜 on 2022/9/6.
//

#include "OHStack.h"

/// init stack
void OHStackInit(OHStack *stack) {
    stack->elements = [NSMutableArray arrayWithCapacity:16];
    stack->length = 0;
}

/// return the top element of given stack
id OHStackTop(OHStack *stack) {
    if (stack->elements && [stack->elements isKindOfClass:NSArray.class]) {
        NSArray *array = (NSArray *)stack->elements;
        return array.lastObject;
    }
    return nil;
}

/// push the given element to stack
void OHStackPush(OHStack *stack, id element) {
    if (stack->elements && [stack->elements isKindOfClass:NSMutableArray.class]) {
        NSMutableArray *array = (NSMutableArray *)stack->elements;
        if (element) {
            [array addObject:element];
            (stack->length)++;
        }
    }
}
/// return the top element of stack and remove it from stack
id OHStackPop(OHStack *stack) {
    if (stack->elements && [stack->elements isKindOfClass:NSMutableArray.class]) {
        NSMutableArray *array = (NSMutableArray *)stack->elements;
        if (array.count) {
            id element = array.lastObject;
            [array removeLastObject];
            (stack->length)--;
            return element;
        }
    }
    return nil;
}

/// return element size of given stack
int OHStackLength(OHStack *stack) {
    return stack->length;
}

BOOL OHStackIsEmpty(OHStack *stack) {
    if (stack) {
        return stack->length != 0;
    }
    
    return NO;
}
