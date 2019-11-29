#include<iostream>

// This is bugprone code (missing parentheses in macro arguments)
#define sum_bugprone(a,b) (a+b)

int main(int argc, char *argv[]){
   std::cout << "Hello World!" << std::endl;
   return 0;
}
