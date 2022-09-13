//
//  OHStack.h
//  MediaService
//
//  Created by 梁甜 on 2022/9/6.
//

#ifndef OHStack_h
#define OHStack_h

#import <stdio.h>
#import <Foundation/Foundation.h>

typedef struct OHStack {
    id elements;
    int length;
} OHStack;

/// init stack
void OHStackInit(OHStack *stack);
/// return the top element of given stack
id OHStackTop(OHStack *stack);
/// push the given element to stack
void OHStackPush(OHStack *stack, id element);
/// return the top element of stack and remove it from stack
id OHStackPop(OHStack *stack);

/// check if stack is empty or not
BOOL OHStackIsEmpty(OHStack *stack);

/// return element size of given stack
int OHStackLength(OHStack *stack);

#endif /* OHStack_h */
