#import <Foundation/Foundation.h>

// MARK: - State Interface
@interface FSMState : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL isAccepting;

- (instancetype)initWithName:(NSString *)name accepting:(BOOL)accepting;
@end

@implementation FSMState

- (instancetype)initWithName:(NSString *)name accepting:(BOOL)accepting {
    self = [super init];
    if (self) {
        _name = name;
        _isAccepting = accepting;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"State(%@%@)", _name, _isAccepting ? @"*" : @""];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[FSMState class]]) return NO;
    FSMState *other = (FSMState *)object;
    return [self.name isEqualToString:other.name];
}

- (NSUInteger)hash {
    return [self.name hash];
}

@end

// MARK: - Transition Interface
@interface FSMTransition : NSObject
@property (nonatomic, strong) FSMState *fromState;
@property (nonatomic, strong) FSMState *toState;
@property (nonatomic, assign) unichar symbol;

- (instancetype)initWithFrom:(FSMState *)from to:(FSMState *)to symbol:(unichar)symbol;
- (BOOL)matchesState:(FSMState *)state withSymbol:(unichar)symbol;
@end

@implementation FSMTransition

- (instancetype)initWithFrom:(FSMState *)from to:(FSMState *)to symbol:(unichar)symbol {
    self = [super init];
    if (self) {
        _fromState = from;
        _toState = to;
        _symbol = symbol;
    }
    return self;
}

- (BOOL)matchesState:(FSMState *)state withSymbol:(unichar)symbol {
    return [self.fromState isEqual:state] && self.symbol == symbol;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ --%C--> %@", 
            self.fromState.name, self.symbol, self.toState.name];
}

@end

// MARK: - Finite State Machine Interface
@interface FiniteStateMachine : NSObject
@property (nonatomic, strong) NSMutableSet<FSMState *> *states;
@property (nonatomic, strong) NSMutableArray<FSMTransition *> *transitions;
@property (nonatomic, strong) FSMState *initialState;
@property (nonatomic, strong) FSMState *currentState;
@property (nonatomic, strong) NSMutableSet *alphabet;

- (instancetype)initWithStates:(NSSet<FSMState *> *)states
                   transitions:(NSArray<FSMTransition *> *)transitions
                  initialState:(FSMState *)initialState
                      alphabet:(NSSet *)alphabet;
- (void)reset;
- (NSDictionary *)processString:(NSString *)input;
- (void)visualize;
@end

@implementation FiniteStateMachine

- (instancetype)initWithStates:(NSSet<FSMState *> *)states
                   transitions:(NSArray<FSMTransition *> *)transitions
                  initialState:(FSMState *)initialState
                      alphabet:(NSSet *)alphabet {
    self = [super init];
    if (self) {
        _states = [states mutableCopy];
        _transitions = [transitions mutableCopy];
        _initialState = initialState;
        _currentState = initialState;
        _alphabet = [alphabet mutableCopy];
    }
    return self;
}

- (void)reset {
    self.currentState = self.initialState;
}

- (NSDictionary *)processString:(NSString *)input {
    [self reset];
    NSMutableArray<NSString *> *trace = [NSMutableArray array];
    [trace addObject:[NSString stringWithFormat:@"Starting at state: %@", self.currentState.name]];
    
    for (NSInteger i = 0; i < input.length; i++) {
        unichar symbol = [input characterAtIndex:i];
        NSString *symbolStr = [NSString stringWithFormat:@"%C", symbol];
        
        if (![self.alphabet containsObject:symbolStr]) {
            [trace addObject:[NSString stringWithFormat:@"Error: '%C' not in alphabet", symbol]];
            return @{@"accepted": @NO, @"trace": trace};
        }
        
        FSMTransition *transition = nil;
        for (FSMTransition *t in self.transitions) {
            if ([t matchesState:self.currentState withSymbol:symbol]) {
                transition = t;
                break;
            }
        }
        
        if (transition) {
            NSString *oldState = self.currentState.name;
            self.currentState = transition.toState;
            [trace addObject:[NSString stringWithFormat:@"Read '%C': %@ → %@", 
                            symbol, oldState, self.currentState.name]];
        } else {
            [trace addObject:[NSString stringWithFormat:@"No transition for '%C' from %@", 
                            symbol, self.currentState.name]];
            return @{@"accepted": @NO, @"trace": trace};
        }
    }
    
    BOOL accepted = self.currentState.isAccepting;
    [trace addObject:accepted ? @"✓ String ACCEPTED" : @"✗ String REJECTED"];
    
    return @{@"accepted": @(accepted), @"trace": trace};
}

- (void)visualize {
    NSLog(@"\n=== FSM Visualization ===");
    NSLog(@"States: %@", [[self.states allObjects] componentsJoinedByString:@", "]);
    
    NSMutableArray *acceptStates = [NSMutableArray array];
    for (FSMState *state in self.states) {
        if (state.isAccepting) {
            [acceptStates addObject:state.name];
        }
    }
    NSLog(@"Accept States: %@", [acceptStates componentsJoinedByString:@", "]);
    NSLog(@"Initial State: %@", self.initialState.name);
    NSLog(@"\nTransitions:");
    for (FSMTransition *t in self.transitions) {
        NSLog(@"  %@", t);
    }
    NSLog(@"========================\n");
}

@end

// MARK: - Regular Expression Engine
@interface RegexEngine : NSObject
+ (BOOL)matchPattern:(NSString *)pattern withInput:(NSString *)input;
+ (NSDictionary *)matchPattern:(NSString *)pattern withInput:(NSString *)input trace:(BOOL)withTrace;
@end

@implementation RegexEngine

+ (BOOL)matchPattern:(NSString *)pattern withInput:(NSString *)input {
    NSError *error = nil;
    NSString *fullPattern = [NSString stringWithFormat:@"^%@$", pattern];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:fullPattern
                                                                            options:0
                                                                              error:&error];
    if (error) {
        NSLog(@"Regex error: %@", error.localizedDescription);
        return NO;
    }
    
    NSRange range = NSMakeRange(0, input.length);
    NSTextCheckingResult *match = [regex firstMatchInString:input options:0 range:range];
    return match != nil;
}

+ (NSDictionary *)matchPattern:(NSString *)pattern withInput:(NSString *)input trace:(BOOL)withTrace {
    BOOL matches = [self matchPattern:pattern withInput:input];
    NSMutableArray<NSString *> *trace = [NSMutableArray array];
    
    [trace addObject:[NSString stringWithFormat:@"Testing pattern: %@", pattern]];
    [trace addObject:[NSString stringWithFormat:@"Input string: %@", input]];
    
    if (matches) {
        [trace addObject:@"✓ String MATCHES the pattern!"];
        
        if (withTrace) {
            [trace addObject:@"\nStep-by-step analysis:"];
            for (NSInteger i = 1; i <= input.length; i++) {
                NSString *partial = [input substringToIndex:i];
                BOOL partialMatch = [self matchPattern:pattern withInput:partial];
                [trace addObject:[NSString stringWithFormat:@"  %@: %@", partial, partialMatch ? @"✓" : @"✗"]];
            }
        }
    } else {
        [trace addObject:@"✗ String does NOT match the pattern."];
    }
    
    return @{@"matches": @(matches), @"trace": trace};
}

@end

// MARK: - NFA to DFA Converter
@interface NFAConverter : NSObject
+ (FiniteStateMachine *)convertNFAToDFA:(NSDictionary *)nfaStates
                           initialState:(NSString *)initialState
                           acceptStates:(NSSet *)acceptStates
                               alphabet:(NSSet *)alphabet;
@end

@implementation NFAConverter

+ (NSSet *)epsilonClosure:(NSSet *)states withNFAStates:(NSDictionary *)nfaStates {
    NSMutableSet *closure = [states mutableCopy];
    NSMutableArray *stack = [states.allObjects mutableCopy];
    
    while (stack.count > 0) {
        NSString *state = [stack lastObject];
        [stack removeLastObject];
        
        NSDictionary *nfaState = nfaStates[state];
        if (nfaState) {
            NSArray *epsilonTransitions = nfaState[@"epsilon"];
            for (NSString *epsilonTarget in epsilonTransitions) {
                if (![closure containsObject:epsilonTarget]) {
                    [closure addObject:epsilonTarget];
                    [stack addObject:epsilonTarget];
                }
            }
        }
    }
    
    return closure;
}

+ (FiniteStateMachine *)convertNFAToDFA:(NSDictionary *)nfaStates
                           initialState:(NSString *)initialState
                           acceptStates:(NSSet *)acceptStates
                               alphabet:(NSSet *)alphabet {
    NSMutableSet<FSMState *> *dfaStates = [NSMutableSet set];
    NSMutableArray<FSMTransition *> *dfaTransitions = [NSMutableArray array];
    NSMutableArray<NSSet *> *unmarkedStates = [NSMutableArray array];
    NSMutableArray<NSSet *> *markedStates = [NSMutableArray array];
    
    NSSet *initialClosure = [self epsilonClosure:[NSSet setWithObject:initialState] 
                                   withNFAStates:nfaStates];
    [unmarkedStates addObject:initialClosure];
    
    FSMState *initialDFAState = nil;
    
    while (unmarkedStates.count > 0) {
        NSSet *currentDFAStateSet = [unmarkedStates firstObject];
        [unmarkedStates removeObjectAtIndex:0];
        [markedStates addObject:currentDFAStateSet];
        
        BOOL isAccepting = NO;
        for (NSString *stateName in currentDFAStateSet) {
            if ([acceptStates containsObject:stateName]) {
                isAccepting = YES;
                break;
            }
        }
        
        NSString *dfaStateName = [[currentDFAStateSet.allObjects sortedArrayUsingSelector:@selector(compare:)] 
                                 componentsJoinedByString:@","];
        FSMState *dfaState = [[FSMState alloc] initWithName:dfaStateName accepting:isAccepting];
        [dfaStates addObject:dfaState];
        
        if ([currentDFAStateSet isEqualToSet:initialClosure]) {
            initialDFAState = dfaState;
        }
        
        for (NSString *symbolStr in alphabet) {
            unichar symbol = [symbolStr characterAtIndex:0];
            NSMutableSet *targets = [NSMutableSet set];
            
            for (NSString *nfaStateName in currentDFAStateSet) {
                NSDictionary *nfaState = nfaStates[nfaStateName];
                if (nfaState) {
                    NSDictionary *transitions = nfaState[@"transitions"];
                    NSArray *symbolTargets = transitions[symbolStr];
                    if (symbolTargets) {
                        [targets addObjectsFromArray:symbolTargets];
                    }
                }
            }
            
            if (targets.count > 0) {
                NSSet *targetClosure = [self epsilonClosure:targets withNFAStates:nfaStates];
                
                if (![markedStates containsObject:targetClosure] && 
                    ![unmarkedStates containsObject:targetClosure]) {
                    [unmarkedStates addObject:targetClosure];
                }
                
                NSString *targetStateName = [[targetClosure.allObjects sortedArrayUsingSelector:@selector(compare:)] 
                                           componentsJoinedByString:@","];
                BOOL targetIsAccepting = NO;
                for (NSString *stateName in targetClosure) {
                    if ([acceptStates containsObject:stateName]) {
                        targetIsAccepting = YES;
                        break;
                    }
                }
                FSMState *targetState = [[FSMState alloc] initWithName:targetStateName 
                                                             accepting:targetIsAccepting];
                
                FSMTransition *transition = [[FSMTransition alloc] initWithFrom:dfaState 
                                                                            to:targetState 
                                                                        symbol:symbol];
                [dfaTransitions addObject:transition];
            }
        }
    }
    
    return [[FiniteStateMachine alloc] initWithStates:dfaStates 
                                          transitions:dfaTransitions 
                                         initialState:initialDFAState 
                                             alphabet:alphabet];
}

@end

// MARK: - Main Program
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSLog(@"╔═══════════════════════════════════════════════════════════════╗");
        NSLog(@"║   Automata & Formal Language Simulator (Objective-C)         ║");
        NSLog(@"╚═══════════════════════════════════════════════════════════════╝\n");
        
        // Create sample FSM
        FSMState *q0 = [[FSMState alloc] initWithName:@"q0" accepting:NO];
        FSMState *q1 = [[FSMState alloc] initWithName:@"q1" accepting:NO];
        FSMState *q2 = [[FSMState alloc] initWithName:@"q2" accepting:YES];
        
        NSSet *states = [NSSet setWithObjects:q0, q1, q2, nil];
        NSArray *transitions = @[
            [[FSMTransition alloc] initWithFrom:q0 to:q1 symbol:'a'],
            [[FSMTransition alloc] initWithFrom:q1 to:q2 symbol:'b'],
            [[FSMTransition alloc] initWithFrom:q2 to:q0 symbol:'c']
        ];
        NSSet *alphabet = [NSSet setWithObjects:@"a", @"b", @"c", nil];
        
        FiniteStateMachine *fsm = [[FiniteStateMachine alloc] initWithStates:states
                                                                 transitions:transitions
                                                                initialState:q0
                                                                    alphabet:alphabet];
        
        [fsm visualize];
        
        // Test FSM
        NSLog(@"=== Testing FSM ===\n");
        NSArray *testStrings = @[@"abc", @"ab", @"abcabc", @"xyz"];
        
        for (NSString *testString in testStrings) {
            NSLog(@"Input: \"%@\"", testString);
            NSDictionary *result = [fsm processString:testString];
            for (NSString *line in result[@"trace"]) {
                NSLog(@"%@", line);
            }
            NSLog(@"\n");
        }
        
        // Test Regular Expressions
        NSLog(@"=== Testing Regular Expressions ===\n");
        NSArray *patterns = @[@"(a|b)*c", @"a+b*", @"(ab)+"];
        NSArray *inputs = @[@"aaac", @"abb", @"abab"];
        
        for (NSInteger i = 0; i < patterns.count; i++) {
            NSDictionary *result = [RegexEngine matchPattern:patterns[i] 
                                                   withInput:inputs[i] 
                                                       trace:YES];
            for (NSString *line in result[@"trace"]) {
                NSLog(@"%@", line);
            }
            NSLog(@"\n");
        }
        
        // Demo NFA to DFA conversion
        NSLog(@"=== NFA to DFA Conversion Demo ===\n");
        NSDictionary *nfaStates = @{
            @"q0": @{@"epsilon": @[@"q1"], @"transitions": @{@"a": @[@"q0"]}},
            @"q1": @{@"epsilon": @[], @"transitions": @{@"b": @[@"q2"]}},
            @"q2": @{@"epsilon": @[], @"transitions": @{}}
        };
        
        NSLog(@"Converting NFA with ε-transitions to DFA...");
        FiniteStateMachine *dfa = [NFAConverter convertNFAToDFA:nfaStates
                                                   initialState:@"q0"
                                                   acceptStates:[NSSet setWithObject:@"q2"]
                                                       alphabet:[NSSet setWithObjects:@"a", @"b", nil]];
        
        NSLog(@"\n✓ Conversion complete!");
        [dfa visualize];
    }
    return 0;
}