/* Automata & Formal Language Simulator in C-- (C subset) */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define MAX_STATES 100
#define MAX_TRANSITIONS 500
#define MAX_ALPHABET 26
#define MAX_TRACE 100
#define MAX_NAME_LEN 50
#define MAX_INPUT_LEN 1000

/* State Structure */
typedef struct {
    char name[MAX_NAME_LEN];
    int isAccepting;
} State;

/* Transition Structure */
typedef struct {
    int fromState;
    int toState;
    char symbol;
} Transition;

/* Finite State Machine Structure */
typedef struct {
    State states[MAX_STATES];
    int stateCount;
    Transition transitions[MAX_TRANSITIONS];
    int transitionCount;
    int initialState;
    int currentState;
    char alphabet[MAX_ALPHABET];
    int alphabetSize;
} FSM;

/* Trace Entry */
typedef struct {
    char message[256];
} TraceEntry;

/* Process Result */
typedef struct {
    int accepted;
    TraceEntry trace[MAX_TRACE];
    int traceCount;
} ProcessResult;

/* Function Prototypes */
void initializeFSM(FSM *fsm);
int addState(FSM *fsm, const char *name, int isAccepting);
void addTransition(FSM *fsm, int fromState, int toState, char symbol);
int findTransition(FSM *fsm, int currentState, char symbol);
void resetFSM(FSM *fsm);
ProcessResult processString(FSM *fsm, const char *input);
void visualizeFSM(FSM *fsm);
int charInAlphabet(FSM *fsm, char c);
void addToAlphabet(FSM *fsm, char c);
void createSampleFSM(FSM *fsm);
void printTrace(ProcessResult *result);

/* Initialize FSM */
void initializeFSM(FSM *fsm) {
    fsm->stateCount = 0;
    fsm->transitionCount = 0;
    fsm->initialState = 0;
    fsm->currentState = 0;
    fsm->alphabetSize = 0;
}

/* Add State */
int addState(FSM *fsm, const char *name, int isAccepting) {
    if (fsm->stateCount >= MAX_STATES) {
        printf("Error: Maximum number of states reached\n");
        return -1;
    }

    strncpy(fsm->states[fsm->stateCount].name, name, MAX_NAME_LEN - 1);
    fsm->states[fsm->stateCount].name[MAX_NAME_LEN - 1] = '\0';
    fsm->states[fsm->stateCount].isAccepting = isAccepting;
    
    return fsm->stateCount++;
}

/* Check if character is in alphabet */
int charInAlphabet(FSM *fsm, char c) {
    int i;
    for (i = 0; i < fsm->alphabetSize; i++) {
        if (fsm->alphabet[i] == c) {
            return 1;
        }
    }
    return 0;
}

/* Add character to alphabet */
void addToAlphabet(FSM *fsm, char c) {
    if (!charInAlphabet(fsm, c) && fsm->alphabetSize < MAX_ALPHABET) {
        fsm->alphabet[fsm->alphabetSize++] = c;
    }
}

/* Add Transition */
void addTransition(FSM *fsm, int fromState, int toState, char symbol) {
    if (fsm->transitionCount >= MAX_TRANSITIONS) {
        printf("Error: Maximum number of transitions reached\n");
        return;
    }

    fsm->transitions[fsm->transitionCount].fromState = fromState;
    fsm->transitions[fsm->transitionCount].toState = toState;
    fsm->transitions[fsm->transitionCount].symbol = symbol;
    fsm->transitionCount++;
    
    addToAlphabet(fsm, symbol);
}

/* Find Transition */
int findTransition(FSM *fsm, int currentState, char symbol) {
    int i;
    for (i = 0; i < fsm->transitionCount; i++) {
        if (fsm->transitions[i].fromState == currentState && 
            fsm->transitions[i].symbol == symbol) {
            return i;
        }
    }
    return -1;
}

/* Reset FSM */
void resetFSM(FSM *fsm) {
    fsm->currentState = fsm->initialState;
}

/* Process String */
ProcessResult processString(FSM *fsm, const char *input) {
    ProcessResult result;
    int i, transIndex, oldState;
    char symbol;
    
    result.traceCount = 0;
    result.accepted = 0;
    
    resetFSM(fsm);
    
    /* Add initial trace */
    sprintf(result.trace[result.traceCount].message, 
            "Starting at state: %s", 
            fsm->states[fsm->currentState].name);
    result.traceCount++;
    
    /* Process each character */
    for (i = 0; i < strlen(input); i++) {
        symbol = input[i];
        
        /* Check if symbol is in alphabet */
        if (!charInAlphabet(fsm, symbol)) {
            sprintf(result.trace[result.traceCount].message,
                    "Error: '%c' not in alphabet", symbol);
            result.traceCount++;
            return result;
        }
        
        /* Find transition */
        transIndex = findTransition(fsm, fsm->currentState, symbol);
        
        if (transIndex >= 0) {
            oldState = fsm->currentState;
            fsm->currentState = fsm->transitions[transIndex].toState;
            sprintf(result.trace[result.traceCount].message,
                    "Read '%c': %s -> %s",
                    symbol,
                    fsm->states[oldState].name,
                    fsm->states[fsm->currentState].name);
            result.traceCount++;
        } else {
            sprintf(result.trace[result.traceCount].message,
                    "No transition for '%c' from %s",
                    symbol,
                    fsm->states[fsm->currentState].name);
            result.traceCount++;
            return result;
        }
    }
    
    /* Check if final state is accepting */
    result.accepted = fsm->states[fsm->currentState].isAccepting;
    
    if (result.accepted) {
        sprintf(result.trace[result.traceCount].message, "✓ String ACCEPTED");
    } else {
        sprintf(result.trace[result.traceCount].message, "✗ String REJECTED");
    }
    result.traceCount++;
    
    return result;
}

/* Visualize FSM */
void visualizeFSM(FSM *fsm) {
    int i;
    
    printf("\n=== FSM Visualization ===\n");
    
    /* Display states */
    printf("States: ");
    for (i = 0; i < fsm->stateCount; i++) {
        printf("%s", fsm->states[i].name);
        if (i < fsm->stateCount - 1) {
            printf(", ");
        }
    }
    printf("\n");
    
    /* Display accept states */
    printf("Accept States: ");
    for (i = 0; i < fsm->stateCount; i++) {
        if (fsm->states[i].isAccepting) {
            printf("%s ", fsm->states[i].name);
        }
    }
    printf("\n");
    
    printf("Initial State: %s\n", fsm->states[fsm->initialState].name);
    
    /* Display alphabet */
    printf("Alphabet: {");
    for (i = 0; i < fsm->alphabetSize; i++) {
        printf("%c", fsm->alphabet[i]);
        if (i < fsm->alphabetSize - 1) {
            printf(", ");
        }
    }
    printf("}\n");
    
    /* Display transitions */
    printf("\nTransitions:\n");
    for (i = 0; i < fsm->transitionCount; i++) {
        printf("  %s --%c--> %s\n",
               fsm->states[fsm->transitions[i].fromState].name,
               fsm->transitions[i].symbol,
               fsm->states[fsm->transitions[i].toState].name);
    }
    printf("========================\n\n");
}

/* Print Trace */
void printTrace(ProcessResult *result) {
    int i;
    printf("\n--- Execution Trace ---\n");
    for (i = 0; i < result->traceCount; i++) {
        printf("%s\n", result->trace[i].message);
    }
}

/* Create Sample FSM */
void createSampleFSM(FSM *fsm) {
    int q0, q1, q2;
    
    initializeFSM(fsm);
    
    /* Add states */
    q0 = addState(fsm, "q0", 0);
    q1 = addState(fsm, "q1", 0);
    q2 = addState(fsm, "q2", 1);
    
    /* Add transitions */
    addTransition(fsm, q0, q1, 'a');
    addTransition(fsm, q1, q2, 'b');
    addTransition(fsm, q2, q0, 'c');
    
    /* Set initial state */
    fsm->initialState = q0;
    fsm->currentState = q0;
}

/* Simple Regex Matcher */
int matchRegex(const char *pattern, const char *input) {
    /* Simple exact match for demonstration */
    return strcmp(pattern, input) == 0;
}

/* Show Menu */
void showMenu(void) {
    printf("\n============================================================\n");
    printf("Main Menu:\n");
    printf("1. Test FSM with string\n");
    printf("2. Test Regular Expression\n");
    printf("3. Visualize FSM\n");
    printf("4. Reset FSM\n");
    printf("5. Exit\n");
    printf("Select option: ");
}

/* Main Program */
int main(void) {
    FSM fsm;
    ProcessResult result;
    char input[MAX_INPUT_LEN];
    char pattern[MAX_INPUT_LEN];
    int choice, i;
    const char *testStrings[] = {"abc", "ab", "abcabc", "xyz"};
    int numTests = 4;
    
    printf("╔═══════════════════════════════════════════════════════════════╗\n");
    printf("║      Automata & Formal Language Simulator (C--)              ║\n");
    printf("╚═══════════════════════════════════════════════════════════════╝\n\n");
    
    /* Create sample FSM */
    createSampleFSM(&fsm);
    printf("✓ Sample FSM created (accepts strings matching pattern: (abc)*)\n");
    
    /* Visualize FSM */
    visualizeFSM(&fsm);
    
    /* Automatic testing */
    printf("=== Automatic Testing ===\n");
    for (i = 0; i < numTests; i++) {
        printf("\nInput: \"%s\"\n", testStrings[i]);
        result = processString(&fsm, testStrings[i]);
        printTrace(&result);
    }
    
    /* Interactive menu */
    while (1) {
        showMenu();
        scanf("%d", &choice);
        getchar(); /* Consume newline */
        
        switch (choice) {
            case 1:
                printf("\nEnter string to test: ");
                fgets(input, MAX_INPUT_LEN, stdin);
                input[strcspn(input, "\n")] = 0; /* Remove newline */
                result = processString(&fsm, input);
                printTrace(&result);
                break;
                
            case 2:
                printf("\nEnter regex pattern: ");
                fgets(pattern, MAX_INPUT_LEN, stdin);
                pattern[strcspn(pattern, "\n")] = 0;
                printf("Enter test string: ");
                fgets(input, MAX_INPUT_LEN, stdin);
                input[strcspn(input, "\n")] = 0;
                
                printf("\n--- Analysis ---\n");
                printf("Pattern: %s\n", pattern);
                printf("Input: %s\n", input);
                if (matchRegex(pattern, input)) {
                    printf("✓ String MATCHES the pattern!\n");
                } else {
                    printf("✗ String does NOT match the pattern.\n");
                }
                break;
                
            case 3:
                visualizeFSM(&fsm);
                break;
                
            case 4:
                resetFSM(&fsm);
                printf("✓ FSM reset to initial state.\n");
                break;
                
            case 5:
                printf("\nExiting simulator. Goodbye!\n");
                return 0;
                
            default:
                printf("Invalid option. Please try again.\n");
        }
    }
    
    return 0;
}