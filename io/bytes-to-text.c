#include <stdio.h>
#include <stdlib.h>

void main() {
  int bytes_amount;
  scanf("%d", &bytes_amount);

  char *bytes = calloc(bytes_amount + 1, sizeof(char));
  for (int i = 0; i < bytes_amount; i++) {
    int input;
    scanf("%d", &input);
    bytes[i] = (char)input;
  }

  printf("%s", bytes);
  free(bytes);
}
