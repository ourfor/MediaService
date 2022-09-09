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
typedef struct OHBinaryTree {
    /// left child
    struct OHBinaryTree *left;
    /// right child;
    struct OHBinaryTree *right;
    /// value
    id value;
} OHBinaryTree, OHBinaryTreeNode;

typedef NS_ENUM(NSUInteger, OHBinaryThreadTag) {
    OHBinaryThreadLink,
    OHBinaryThreadThread
};

typedef struct OHBinaryThreadTree {
    struct OHBinaryThreadTree *left;
    struct OHBinaryThreadTree *right;
    id value;
    OHBinaryThreadTag leftTag;
    OHBinaryThreadTag rightTag;
} OHBinaryThreadTree;


typedef NS_ENUM(NSUInteger, OHBinaryTreeNodeCompareResult) {
    OHBinaryTreeNodeEqual,
    OHBinaryTreeNodeGreat,
    OHBinaryTreeNodeLess
};

typedef void (^OHBinaryTreeNodeVisit)(OHBinaryTree *);
typedef OHBinaryTreeNodeCompareResult (^OHBinaryTreeNodeCompare)(OHBinaryTreeNode *front, OHBinaryTreeNode *rear);
/// Binary Tree PreOrder
void OHBinaryTreePreOrder(OHBinaryTree *tree, OHBinaryTreeNodeVisit visit);
void OHBinaryTreeInOrder(OHBinaryTree *tree, OHBinaryTreeNodeVisit visit);
void OHBinaryTreePostOrder(OHBinaryTree *tree, OHBinaryTreeNodeVisit visit);
void OHBinarySearchTreeInsert(OHBinaryTree *tree, OHBinaryTreeNodeCompare compare, id value);

#endif /* BinaryTree_h */
