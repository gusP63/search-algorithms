#ifndef types_H
#define types_H

#include <stdbool.h>

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

#endif // methods_H
