#include <stdbool.h>

#ifndef graph_H
#define graph_H

struct connection;
struct connections_list;
struct node;
struct node_list;

typedef struct connection {
  struct node *n;
  int cost;
} connection;

typedef struct connections_list {
  struct connection *elements;
  int count;
} connections_list;

typedef struct node {
  struct connections_list *connections;
  char id;
  bool isExpanded;
  // int x,y
} node;

typedef struct node_list { // for visual representation
  // pointer to pointers, so when nodes are expanded on through some algorithm, it updates the list
  struct node **elements;
  int count;
} node_list;

node *createNode();
node_list *createNodeList();
connections_list *createConnectionsList();

void connectNodes(node *n1, node *n2, const int cost);
void expandNode(node *n);
void appendTo(connections_list *connections, const connection c);
void addNodeTo(node_list *nodes, node *node);
void showNodes(const node_list n);

#endif // graph_H
