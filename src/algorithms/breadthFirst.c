#include "breadthFirst.h"
#include <stdio.h>
#include <stdlib.h>

void breadthFirst(node *start, node *goal) {
  int cost = 0;
  bool found = false;
  node_list *pathTaken = createNodeList();

  expand(start, goal->id, &cost, &found, pathTaken);

  if (found) {
    printf("Found %c! Cost: %d\n", goal->id, cost);
    printSolution(*pathTaken);
  } else
    printf("\nCould not find a solution...");

  free(pathTaken);
}

bool listContains(node_list list, node *n) {
  for (int i = 0; i < list.count; i++) {
    if (list.elements[i] == n) return true;
  }

  return false;
};

void expand(node *start, char goal, int *cost, bool *didFind, node_list *path) {
  node_list *currentLevel = createNodeList();
  addNodeTo(currentLevel, start);

  node_list *nextLevel = NULL;

  bool reachedEnd = false;

  while (!reachedEnd) {
    reachedEnd = true;
    for (int i = 0; i < currentLevel->count; i++) {
      const connections_list *children = currentLevel->elements[i]->connections;

      for (int i = 0; i < children->count; i++)
        if (!children->elements[i].n->isExpanded) reachedEnd = false; // check if there are still nodes to expand
    }

    nextLevel = createNodeList();

    for (int i = 0; i < currentLevel->count; i++) // [A]
    {
      node *head = currentLevel->elements[i];

      /* if (head->id == goal) { // verificar quando expande? */
      /*   *didFind = true; */

      /*   if (currentLevel) free(currentLevel); */
      /*   if (nextLevel) free(nextLevel); */
      /*   return; */
      /* } */

      for (int j = 0; j < head->connections->count; j++) // [B, C]
      {
        const connection child = head->connections->elements[j];

        if (child.n->isExpanded) continue; // prevent loops

        *cost += child.cost;

        if (child.n->id == goal) { // verificar logo?
          *didFind = true;

          addNodeTo(path, child.n); // child
          addNodeTo(path, head);    // parent

          node *ref = head;
          while (ref != start) // volta atras até chegar ao inicio
          {
            for (int x = 0; x < ref->connections->count; x++) {
              // clang-format off
              // make sure it goes to a node of the level above
              if (
                  ref->connections->elements[x].n->isExpanded &&
                  !listContains(
                    *currentLevel,                    
                    ref->connections->elements[x].n)
                  )
              {
                ref = ref->connections->elements[x].n;
                addNodeTo(path, ref);
                break;
              }
              // clang-format on
            }
          }

          if (currentLevel) free(currentLevel);
          if (nextLevel) free(nextLevel);
          return;
        }

        addNodeTo(nextLevel, child.n);
      }

      head->isExpanded = true;
    }

    free(currentLevel);
    currentLevel = nextLevel;
    nextLevel = NULL;
  }

  /* *didFind = false; */
  if (currentLevel) free(currentLevel);
  if (nextLevel) free(nextLevel);
}
