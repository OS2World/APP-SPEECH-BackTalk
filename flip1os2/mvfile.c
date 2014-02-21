#include <stdio.h>

int MVFILE (src, dest)
char *src;
char *dest;
{
   unlink (dest);
   return(rename (src, dest));
}
