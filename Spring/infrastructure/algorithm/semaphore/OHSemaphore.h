//
//  OHSemaphore.h
//  Spring
//
//  Created by 梁甜 on 2022/10/13.
//

#ifndef OHSemaphore_h
#define OHSemaphore_h

#include <stdio.h>
#include <semaphore.h>

typedef int semaphore;

/// wait semaphore
void P(semaphore sem);

/// signal semaphore
void V(semaphore sem);

#endif /* OHSemaphore_h */
