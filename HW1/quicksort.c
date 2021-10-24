#include <stdio.h>
#define numsize 10
void quick_sort(int* number, int lb, int rb);
int main(void){

    int arr[numsize] = {10, 9, 8, 7, 6, 5, 4, 3, 2, 1};
    printf("Before sorting: ");
    for(int i = 0; i < numsize; i++)
        printf("%d\t", *(arr + i));
    
    printf("\nAfter sorting: ");
    quick_sort(arr, 0, numsize - 1);
    for(int i = 0; i < numsize; i++)
        printf("%d\t", *(arr + i));
    
    printf("\n");

    return 0;
}

void quick_sort(int* number, int lb, int rb){
    if(lb >= rb) return ;
    int pivot = number[lb], l = lb, r = rb;
    while(l != r){
        while( pivot < *(number + r) && l < r)  r--; 
        while( pivot >= *(number + l) && l < r) l++; 
        if(l < r){
            *(number + l) ^= *(number + r);
            *(number + r) ^= *(number + l);
            *(number + l) ^= *(number + r);
        }
    }
    *(number + lb) = *(number + l);
    *(number + l) = pivot;
    quick_sort(number, lb, l - 1);
    quick_sort(number, l + 1, rb);
}