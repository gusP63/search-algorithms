#include "depthFirst.h"
#include <stdio.h>
#include <stdlib.h>

void depthFirst(node *start, node *goal) {
  bool found = false;
  int cost = 0;
  node_list *pathTaken = createNodeList();

  expandD(start, goal->id, &cost, &found, pathTaken);

  if (found) {
    printf("Found %c! Cost: %d\n", goal->id, cost);
    printSolution(*pathTaken);
  } else
    printf("\nCould not find a solution...");

  free(pathTaken);
}

void expandD(node *n, char goal, int *cost, bool *didFind, node_list *pathTaken) {
  if (n->id == goal) {
    *didFind = true;
    addNodeTo(pathTaken, n);
    return;
  }

  if (*didFind) return;

  n->isExpanded = true;
  int nodesToExpand = 0;
  for (int i = 0; i < n->connections->count; i++) {
    if (!n->connections->elements[i].n->isExpanded) nodesToExpand++;
  }

  if (nodesToExpand == 0) {
    return;
  }

  for (int i = 0; i < n->connections->count; i++) {
    // find first node that is not yet expanded and expand it
    if (!n->connections->elements[i].n->isExpanded) {
      *cost += n->connections->elements[i].cost;
      expandD(n->connections->elements[i].n, goal, cost, didFind, pathTaken);

      if (*didFind) {
        addNodeTo(pathTaken, n);
        return;
      }
    }
  }
}
