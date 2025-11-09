#ifndef depthFirst_H
#define depthFirst_H

#include "../graph/methods.h"
#include "../graph/types.h"

void depthFirst(node *start, node *goal);
void expandD(node *start, char goal, int *cost, bool *didFind, node_list *path);

#endif
