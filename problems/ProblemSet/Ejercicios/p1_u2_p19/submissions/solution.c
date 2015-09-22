#include <stdio.h>
#include <math.h>

int main()
{
    int i=0,n=0, sign=0, odd=0;
    float pi=0;
    scanf("%d", &n);

    sign=1;
    for (i=0; i<n; i++)
    {
        odd=(i*2)+1;
        pi+=(sign*1.0)/odd;
        printf("%d \t%d \t%f \n", sign, odd, 4*pi);
        sign*=-1;
    }
    pi*=4;

    printf("%f \n",pi);
    return 0;
}

