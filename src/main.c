#include <stdio.h>
#include <stdlib.h>

typedef struct {
  int **list;
  int count;
} int_list; // list to pointers (only holds values, doesn't make any copies)

int_list *createList() {
  int_list *new = (int_list *)malloc(sizeof(int_list));
  new->count = 0;

  return new;
}

void appendTo(int_list *list, int *num) {
  if (!list) return;

  int **new = (int **)malloc((list->count + 1) * sizeof(int *));

  for (int i = 0; i < list->count; i++) {
    new[i] = list->list[i];
    list->list[i] = NULL;
  }

  if (list->list) free(list->list);
  list->list = new;

  new[list->count] = num;
  list->count++;
}

int getValue(int_list *list, int index) {
  if (index >= list->count) return 0;
  if (!list->list[index]) return 0;

  return *list->list[index];
}

int main() {
  int_list *myList = createList();
  int a = 10, b = 20, c = 30;

  appendTo(myList, &a);
  appendTo(myList, &b);

  for (int i = 0; i < myList->count; i++) {
    printf("el %d: %d\n", i, getValue(myList, i));
  }

  b = 10;
  appendTo(myList, &c);

  for (int i = 0; i < myList->count; i++) {
    printf("el %d: %d\n", i, getValue(myList, i));
  }

  free(myList);
}
