#include <iostream>

using namespace std;

int getcount(int n){
    int count=0;
    while(n!=1){
//        cout<< n<<" ";
        if(n%2==1)
            n=3*n+1;
        else
            n=n/2;
        count++;
    }
//    cout<< n;
    count++;
    return count;
}

int main(){
    int i=0,j=0;
    int n=0;
    int min=0,max=0;
    int maxcount=0,count=0;

    cin>>i;
    cin>>j;
    if (i<j)
    { 
        min=i; 
        max=j;
    }
    else{
        min=j; 
        max=i;
    }

    for(i=min;i<=max;i++){
        count=getcount(i);
        if(maxcount<count)
            maxcount= count;
    }
    cout<<endl<<min<<" "<<max<<" "<<" "<< maxcount;

}