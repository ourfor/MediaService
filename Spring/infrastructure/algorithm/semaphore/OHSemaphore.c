//
//  OHSemaphore.c
//  Spring
//
//  Created by 梁甜 on 2022/10/13.
//

#include "OHSemaphore.h"

/// mutex access buffer
semaphore mutex = 1;
/// buffer empty size
semaphore empty = 1;
/// buffer full size
semaphore full = 0;
void producer(void *args) {
    while (1) {
        P(empty);
        P(mutex);
        /// put data to buffer
        V(mutex);
        V(full);
    }
}

void consumer(void *args) {
    while (1) {
        P(full);
        P(mutex);
        /// take data from buffer
        V(mutex);
        V(empty);
    }
}


semaphore chopstick[5] = {1, 1, 1, 1, 1};

void Phior(int i) {
    while (1) {
        P(chopstick[i]);
        P(chopstick[(i + 1) % 5]);
        /// eat
        V(chopstick[(i + 1) % 5]);
        V(chopstick[i]);
    }
}


semaphore rmutex = 1;
semaphore wmutex = 1;
int readcount = 0;

void Reader(void *args) {
    while (1) {
        P(rmutex);
        if (readcount == 0) P(wmutex);
        readcount++;
        V(rmutex);
        /// read book
        P(rmutex);
        readcount--;
        if (readcount == 0) V(wmutex);
        V(rmutex);
    }
}


void Writer(void *args) {
    while (1) {
        P(wmutex);
        /// write book
        V(wmutex);
    }
}
