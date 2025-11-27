#include <stdio.h>
#include <stdlib.h>
#include <limits.h>

// Overflow interrupt handler
void overflow_interrupt_handler() {
    printf("\n*** Overflow Interrupt Triggered! ***\n");
    printf("*** Arithmetic overflow detected, executing safe handling ***\n");
}

// Check for overflow using inline assembly (without JO/JNO)
int check_overflow_asm(int a, int b, int* result) {
    int overflow = 0;
    
    // GCC inline assembly
    __asm__ (
        "movl %2, %%eax\n\t"      // Move a to eax
        "addl %3, %%eax\n\t"      // Perform addition a + b
        "movl %%eax, %0\n\t"      // Save result to *result
        
        // Check overflow flag without using JO/JNO
        // Manually detect overflow by checking sign changes
        "xorl %%ebx, %%ebx\n\t"   // Clear ebx
        "sets %%bl\n\t"           // Set BL if SF=1
        "movl %%ebx, %1\n\t"      // Save sign flag
        
        : "=r" (*result), "=r" (overflow)
        : "r" (a), "r" (b)
        : "%eax", "%ebx", "cc"
    );
    
    // Manually check for overflow (without JO/JNO)
    if ((a > 0 && b > 0 && *result < 0) || 
        (a < 0 && b < 0 && *result > 0)) {
        return 1; // Overflow
    }
    return 0; // Normal
}

int main() {
    printf("=== Overflow Interrupt Service Program Demo (Inline Assembly Version) ===\n\n");
    
    // Test cases
    int tests[][2] = {
        {100, 200},
        {2147483647, 1},
        {-2147483648, -1},
        {500, 500},
        {2000000000, 2000000000}
    };
    
    const char* descriptions[] = {
        "Normal Addition",
        "Positive Overflow",
        "Negative Overflow", 
        "Normal Addition",
        "Obvious Overflow"
    };
    
    for (int i = 0; i < 5; i++) {
        int a = tests[i][0];
        int b = tests[i][1];
        int result;
        
        printf("Test %d: %s\n", i + 1, descriptions[i]);
        printf("Calculation: %d + %d\n", a, b);
        
        // Check for overflow using inline assembly
        int overflow = check_overflow_asm(a, b, &result);
        
        if (overflow) {
            printf("Inline assembly detected overflow!\n");
            printf("Actual result: %d (overflow)\n", result);
            overflow_interrupt_handler(); // Simulate interrupt handling
        } else {
            printf("Result: %d (normal)\n", result);
        }
        printf("---\n");
    }
    
    printf("Demo completed!\n");
    return 0;
}
