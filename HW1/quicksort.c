#include <stdio.h>

int* quick_sort(int* number, int lb, int rb);
int main(void){

    int arr[10] = {5, 6, 8, 4, 2, -1, -2, 10, -4, -6};
    int* res = quick_sort(arr, 0, 9);
    for(int i = 0; i < 10; i++){
        printf("%d\t", *(arr + i));
    }

    return 0;
}

int* quick_sort(int* number, int lb, int rb){
    if(lb >= rb) return number;
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
    return number;
}