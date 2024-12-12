#include <stdio.h>
#include <stdlib.h>

void main(int argc, char *argv[]) {
  char c;

  if (argc == 1) {
    while (c = getchar()) {
      printf("%d\n", (int)c);
    }

    return;
  }

  int characters_amount = atoi(argv[1]);

  for (int i = 0; i < characters_amount; i++) {
    c = getchar();
    if (!c) break;
    printf("%d\n", (int)c);
  }
}
