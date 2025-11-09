#ifndef breadthFirst_H
#define breadthFirst_H

#include "../graph/methods.h"
#include "../graph/types.h"

void breadthFirst(node *start, node *goal);
void expand(node *start, char goal, int *cost, bool *didFind, node_list *path);

#endif
