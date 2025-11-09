#include "types.h"

#ifndef methods_H
#define methods_H

static char current_id = 'A';

node *createNode();
node_list *createNodeList();
connections_list *createConnectionsList();

void connectNodes(node *n1, node *n2, const int cost);
void expandNode(node *n);
void appendTo(connections_list *connections, const connection c);
void addNodeTo(node_list *nodes, node *node);
void showNodes(const node_list n);
void printSolution(const node_list n);

#endif // methods_H
