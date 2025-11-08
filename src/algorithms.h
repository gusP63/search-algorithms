#include "graph.h"

#ifndef algorithms_H
#define algorithms_H

#define MAX_ITERATIONS 1000

void breadthFirst(node *start, node *goal);
void depthFirst(node *start, node *goal);

bool exists(char id);

#endif
