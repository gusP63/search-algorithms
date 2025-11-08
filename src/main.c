#include <stdio.h>
#include <stdlib.h>

#include "algorithms.h"
#include "graph.h"

node_list *list;
node *a;
node *b;
node *c;
node *d;
node *e;
node *f;
node *g;

void setup();
void cleanup();

int main() {
  setup();
  connectNodes(a, b, 1);
  connectNodes(a, c, 1);
  connectNodes(b, d, 1);
  connectNodes(b, e, 1);
  connectNodes(b, f, 1);
  connectNodes(c, g, 1);

  printf("All Nodes:\n");
  showNodes(*list);

  node *start = a;
  node *goal = f;

  printf("\n-- Breadth first: %c -> %c --\n", start->id, goal->id);
  breadthFirst(start, goal);

  cleanup();
}

void createAndAdd(node **n) {
  *n = createNode();
  addNodeTo(list, *n);
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
