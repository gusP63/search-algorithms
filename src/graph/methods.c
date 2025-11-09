#include <stdio.h>
#include <stdlib.h>

#include "methods.h"

node *createNode() {
  node *new = (node *)malloc(sizeof(node));

  new->connections = createConnectionsList();
  new->id = current_id;
  ++current_id;
  new->isExpanded = false;

  return new;
}

void connectNodes(node *n1, node *n2, const int cost) {
  if (!n1 || !n2) return;

  for (int i = 0; i < n1->connections->count; i++) {
    if (n1->connections->elements[i].n == n2) return; // connection already exists
  }

  connection c1 = {n2, cost}; // n1 -> n2
  connection c2 = {n1, cost}; // n2 -> n1

  appendTo(n1->connections, c1);
  appendTo(n2->connections, c2);
}

void appendTo(connections_list *connections, const connection c) {
  connection *newList = (connection *)malloc((connections->count + 1) * sizeof(connection));

  for (int i = 0; i < connections->count; i++) {
    newList[i] = connections->elements[i];
  }
  if (connections->elements) free(connections->elements);

  newList[connections->count] = c;
  connections->count++;

  connections->elements = newList; // not sure abt this
}

connections_list *createConnectionsList() {
  connections_list *list = (connections_list *)malloc(sizeof(connections_list));
  list->elements = NULL;
  list->count = 0;

  return list;
}

node_list *createNodeList() {
  node_list *list = (node_list *)malloc(sizeof(node_list));
  list->elements = NULL;
  list->count = 0;

  return list;
}

void addNodeTo(node_list *nodes, node *n) {
  node **newList = (node **)malloc((nodes->count + 1) * sizeof(node *));

  for (int i = 0; i < nodes->count; i++) {
    newList[i] = nodes->elements[i];
  }

  nodes->elements = NULL;
  if (nodes->elements) free(nodes->elements);

  newList[nodes->count] = n;
  nodes->count++;

  nodes->elements = newList;
}

void showNodes(const node_list list) {
  for (int i = 0; i < list.count; i++) {
    node *current = list.elements[i];

    printf("node %c: ", current->id);
    printf("{");
    for (int j = 0; j < current->connections->count; j++) {
      printf("{%c, %d}", current->connections->elements[j].n->id, current->connections->elements[j].cost);
    }
    printf("}\n");
  }
}

void printSolution(const node_list list) {
  printf("Solution: ");
  for (int i = list.count - 1; i >= 0; i--) {
    printf("%c", list.elements[i]->id);
    if (i != 0) printf(" -> ");
  }
}

