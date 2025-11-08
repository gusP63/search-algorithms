/* #include <stdio.h> */
#include <stdlib.h>

#include "graph.h"

node_list *list;
node *a;
node *b;
node *c;
node *d;
node *e;
node *f;

void setup();
void cleanup();

int main() {
  setup();
  connectNodes(a, b, 10);

  showNodes(*list);

  cleanup();
}

void setup() {
  list = createNodeList();
  a = createNode();
  b = createNode();
  c = createNode();
  d = createNode();
  e = createNode();
  f = createNode();

  addNodeTo(list, a);
  addNodeTo(list, b);
  addNodeTo(list, c);
  addNodeTo(list, d);
  addNodeTo(list, e);
  addNodeTo(list, f);
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
