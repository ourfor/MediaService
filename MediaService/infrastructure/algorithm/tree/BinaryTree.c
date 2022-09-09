//
//  BinaryTree.c
//  MediaService
//
//  Created by 梁甜 on 2022/9/5.
//

#include "BinaryTree.h"


void OHBinaryTreePreOrder(OHBinaryTree *tree, OHBinaryTreeNodeVisit visit) {
    if (tree) {
        visit(tree);
        OHBinaryTreePreOrder(tree->left, visit);
        OHBinaryTreePreOrder(tree->right, visit);
    }
}

void OHBinaryTreeInOrder(OHBinaryTree *tree, OHBinaryTreeNodeVisit visit) {
    if (tree) {
        OHBinaryTreeInOrder(tree->left, visit);
        visit(tree);
        OHBinaryTreeInOrder(tree->right, visit);
    }
}

void OHBinaryTreePostOrder(OHBinaryTree *tree, OHBinaryTreeNodeVisit visit) {
    if (tree) {
        OHBinaryTreePostOrder(tree->left, visit);
        OHBinaryTreePostOrder(tree->right, visit);
        visit(tree);
    }
}

void OHBinarySearchTreeInsert(OHBinaryTree *tree, OHBinaryTreeNodeCompare compare, id value) {
    if (tree) {
        OHBinaryTree node = {
            .left = nil,
            .right = nil,
            .value = value
        };
        
        OHBinaryTree *prev = nil;
        OHBinaryTreeNodeCompareResult result;
        while (tree) {
            result = compare(tree, &node);
            if (result == OHBinaryTreeNodeEqual) {
                break;
            }
            prev = tree;
            tree = result == OHBinaryTreeNodeGreat ? tree->left : tree->right;
        }
        
        if (result != OHBinaryTreeNodeEqual && prev) {
            OHBinaryTree *newNode = malloc(sizeof(OHBinaryTreeNode));
            memcpy(newNode, &node, sizeof(OHBinaryTreeNode));
            if (result == OHBinaryTreeNodeLess) prev->right = newNode;
            else prev->left = newNode;
        }
    }
}
