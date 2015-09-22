#include <stdio.h>

int main()
{
    int x=0;

    scanf("%d",&x);
    if (x<0)
        printf("negativo");
    else if (x==0)
        printf("cero");
    else
        printf("positivo");
    return 0;
}

