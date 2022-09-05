//
//  BinaryTree.h
//  MediaService
//
//  Created by 梁甜 on 2022/9/5.
//

#ifndef BinaryTree_h
#define BinaryTree_h

#import <stdio.h>
#import <Foundation/Foundation.h>

/// Binary Tree
typedef struct BinaryTree {
    /// left child
    struct BinaryTree *left;
    /// right child;
    struct BinaryTree *right;
    /// value
    id value;
} BinaryTree;

#endif /* BinaryTree_h */
