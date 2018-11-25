#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/time.h>

int main(int argc, const char *argv[])
{

  int timeout;
  FILE *file;
  file = fopen(argv[1], "r");
  if (file)
  {
    while (fscanf(file, "%d\n", &timeout) != EOF)
    {
      struct timeval st, et;

      gettimeofday(&st, NULL);
      nanosleep((const struct timespec[]){{0, timeout * 1000}}, NULL);
      gettimeofday(&et, NULL);

      int elapsed = (((et.tv_sec - st.tv_sec) * 1000000) + (et.tv_usec - st.tv_usec));

      printf("%d;%d;%.4f\n",
             elapsed,
             elapsed - timeout,
             (double)(elapsed - timeout) / (double)timeout);
    }
    fclose(file);
  }

  return 0;
}
