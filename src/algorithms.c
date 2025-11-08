#include "algorithms.h"
#include <stdio.h>
#include <stdlib.h>

void breadthFirst(node *start, node *goal) {
  node_list *currentLevel = createNodeList();
  addNodeTo(currentLevel, start);

  node_list *nextLevel = NULL;

  int cost = 0;

  bool reachedEnd = false;

  while (!reachedEnd) {
    nextLevel = createNodeList();

    for (int i = 0; i < currentLevel->count; i++) // [A]
    {
      node *head = currentLevel->elements[i];

      if (head->id == goal->id) { // verificar quando expande?
        printf("\nFound %c!\nTravel cost: %d\n", goal->id, cost);
        // getPath (if isExpanded (go up) until start)
        /* char* */
        return;
      }

      for (int j = 0; j < head->connections->count; j++) // [B, C]
      {
        const connection child = head->connections->elements[j];

        if (child.n->isExpanded) continue; // prevent loops

        cost += child.cost;
        /* if (child.n->id == goalId) { */ // ou verificar logo?
        /*   printf("\nFound %c!\nTravel cost: %d\n", goalId, cost); */
        /*   // getPath (if isExpanded (go up) until start) */
        /*   /1* char* *1/ */
        /*   return; */
        /* } */

        addNodeTo(nextLevel, child.n);
      }

      head->isExpanded = true;
    }

    free(currentLevel);
    currentLevel = nextLevel;
    nextLevel = NULL;

    reachedEnd = true;
    for (int i = 0; i < currentLevel->count; i++) {
      if (currentLevel->elements[i]->connections->count > 0) reachedEnd = false; // check if there is another level
    }
  }

  if (currentLevel) free(currentLevel);
  if (nextLevel) free(nextLevel);
}

void depthFirst(node *start, node *goal) {}

bool exists(char id) {
  return true;
  /* return (id >= 'A' && id < current_id); */
}
