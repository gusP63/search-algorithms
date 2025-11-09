#include <stdio.h>
#include <stdlib.h>

#include "algorithms/breadthFirst.h"
#include "algorithms/depthFirst.h"
#include "graph/methods.h"
#include "graph/types.h"

node_list *list;
node *a;
node *b;
node *c;
node *d;
node *e;
node *f;
node *g;
node *h;

void resetNodes();
void setup();
void cleanup();

int main() {
  setup();
  connectNodes(a, h, 1);

  connectNodes(a, b, 1);

  connectNodes(b, h, 1);
  connectNodes(a, c, 1);

  connectNodes(b, d, 1);
  connectNodes(b, e, 1);
  connectNodes(b, f, 1);
  connectNodes(c, g, 1);

  printf("\n----\n\n");
  printf("All Nodes:\n");
  showNodes(*list);

  node *start = a;
  node *goal = e;

  printf("\n- Goal: %c -> %c -", start->id, goal->id);

  printf("\n\n-- Breadth first --\n");
  breadthFirst(start, goal);

  resetNodes();

  printf("\n\n-- Depth first --\n");
  depthFirst(start, goal);

  printf("\n\n----");
  cleanup();
}

void createAndAdd(node **n) {
  *n = createNode();
  addNodeTo(list, *n);
}

void resetNodes() {
  for (int i = 0; i < list->count; i++)
    list->elements[i]->isExpanded = false;
}

void setup() {
  list = createNodeList();

  createAndAdd(&a);
  createAndAdd(&b);
  createAndAdd(&c);
  createAndAdd(&d);
  createAndAdd(&e);
  createAndAdd(&f);
  createAndAdd(&g);
  createAndAdd(&h);
}

void cleanup() {
  free(list);
  free(a);
  free(b);
  free(c);
  free(d);
  free(e);
  free(f);
}
