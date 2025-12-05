import Foundation

// MARK: - State Representation
struct State: Hashable, Codable {
    let name: String
    let isAccepting: Bool
    
    init(_ name: String, accepting: Bool = false) {
        self.name = name
        self.isAccepting = accepting
    }
}

// MARK: - Transition
struct Transition: Hashable, Codable {
    let from: State
    let to: State
    let symbol: Character
    
    func matches(currentState: State, input: Character) -> Bool {
        return from == currentState && symbol == input
    }
}

// MARK: - Finite State Machine
class FiniteStateMachine {
    private var states: Set<State>
    private var transitions: [Transition]
    private var initialState: State
    private var currentState: State
    private var alphabet: Set<Character>
    
    init(states: Set<State>, transitions: [Transition], initialState: State, alphabet: Set<Character>) {
        self.states = states
        self.transitions = transitions
        self.initialState = initialState
        self.currentState = initialState
        self.alphabet = alphabet
    }
    
    func reset() {
        currentState = initialState
    }
    
    func processString(_ input: String) -> (accepted: Bool, trace: [String]) {
        reset()
        var trace: [String] = ["Starting at state: \(currentState.name)"]
        
        for char in input {
            guard alphabet.contains(char) else {
                trace.append("Error: '\(char)' not in alphabet")
                return (false, trace)
            }
            
            if let transition = transitions.first(where: { $0.matches(currentState: currentState, input: char) }) {
                let oldState = currentState.name
                currentState = transition.to
                trace.append("Read '\(char)': \(oldState) → \(currentState.name)")
            } else {
                trace.append("No transition for '\(char)' from \(currentState.name)")
                return (false, trace)
            }
        }
        
        let accepted = currentState.isAccepting
        trace.append(accepted ? "✓ String ACCEPTED" : "✗ String REJECTED")
        return (accepted, trace)
    }
    
    func getCurrentState() -> State {
        return currentState
    }
}

// MARK: - NFA to DFA Converter
class NFAConverter {
    struct NFAState {
        let name: String
        var epsilonTransitions: Set<String> = []
        var transitions: [Character: Set<String>] = [:]
    }
    
    static func convertToDFA(nfaStates: [String: NFAState], initialState: String, acceptStates: Set<String>) -> FiniteStateMachine {
        var dfaStates: Set<State> = []
        var dfaTransitions: [Transition] = []
        var alphabet: Set<Character> = []
        
        // Compute epsilon closure
        func epsilonClosure(_ states: Set<String>) -> Set<String> {
            var closure = states
            var stack = Array(states)
            
            while !stack.isEmpty {
                let state = stack.removeLast()
                if let nfaState = nfaStates[state] {
                    for epsilonTarget in nfaState.epsilonTransitions {
                        if !closure.contains(epsilonTarget) {
                            closure.insert(epsilonTarget)
                            stack.append(epsilonTarget)
                        }
                    }
                }
            }
            return closure
        }
        
        // Build DFA using subset construction
        var unmarkedStates: [Set<String>] = [epsilonClosure([initialState])]
        var markedStates: Set<Set<String>> = []
        
        while !unmarkedStates.isEmpty {
            let currentDFAState = unmarkedStates.removeFirst()
            markedStates.insert(currentDFAState)
            
            let isAccepting = !currentDFAState.intersection(acceptStates).isEmpty
            let dfaStateName = currentDFAState.sorted().joined(separator: ",")
            dfaStates.insert(State(dfaStateName, accepting: isAccepting))
            
            // Find all possible transitions
            var symbolTransitions: [Character: Set<String>] = [:]
            for nfaStateName in currentDFAState {
                if let nfaState = nfaStates[nfaStateName] {
                    for (symbol, targets) in nfaState.transitions {
                        alphabet.insert(symbol)
                        symbolTransitions[symbol, default: []].formUnion(targets)
                    }
                }
            }
            
            // Create DFA transitions
            for (symbol, targets) in symbolTransitions {
                let targetClosure = epsilonClosure(targets)
                if !markedStates.contains(targetClosure) && !unmarkedStates.contains(targetClosure) {
                    unmarkedStates.append(targetClosure)
                }
                
                let targetStateName = targetClosure.sorted().joined(separator: ",")
                dfaTransitions.append(Transition(
                    from: State(dfaStateName, accepting: isAccepting),
                    to: State(targetStateName, accepting: !targetClosure.intersection(acceptStates).isEmpty),
                    symbol: symbol
                ))
            }
        }
        
        let initialDFAState = State(epsilonClosure([initialState]).sorted().joined(separator: ","), accepting: false)
        return FiniteStateMachine(states: dfaStates, transitions: dfaTransitions, initialState: initialDFAState, alphabet: alphabet)
    }
}

// MARK: - Regular Expression Engine
class RegexEngine {
    enum RegexNode {
        case literal(Character)
        case concatenation([RegexNode])
        case alternation([RegexNode])
        case kleeneStar(RegexNode)
        case plus(RegexNode)
        case optional(RegexNode)
    }
    
    static func parse(_ pattern: String) -> RegexNode? {
        var index = pattern.startIndex
        return parseAlternation(pattern, &index)
    }
    
    private static func parseAlternation(_ pattern: String, _ index: inout String.Index) -> RegexNode? {
        var nodes: [RegexNode] = []
        
        while index < pattern.endIndex {
            if let node = parseConcatenation(pattern, &index) {
                nodes.append(node)
            }
            
            if index < pattern.endIndex && pattern[index] == "|" {
                index = pattern.index(after: index)
                continue
            }
            break
        }
        
        return nodes.count == 1 ? nodes[0] : .alternation(nodes)
    }
    
    private static func parseConcatenation(_ pattern: String, _ index: inout String.Index) -> RegexNode? {
        var nodes: [RegexNode] = []
        
        while index < pattern.endIndex {
            guard let node = parsePrimary(pattern, &index) else { break }
            nodes.append(node)
        }
        
        return nodes.count == 1 ? nodes[0] : .concatenation(nodes)
    }
    
    private static func parsePrimary(_ pattern: String, _ index: inout String.Index) -> RegexNode? {
        guard index < pattern.endIndex else { return nil }
        
        let char = pattern[index]
        index = pattern.index(after: index)
        
        var node: RegexNode
        
        switch char {
        case "(":
            node = parseAlternation(pattern, &index) ?? .literal(" ")
            if index < pattern.endIndex && pattern[index] == ")" {
                index = pattern.index(after: index)
            }
        case ")":
            return nil
        default:
            node = .literal(char)
        }
        
        // Handle postfix operators
        if index < pattern.endIndex {
            switch pattern[index] {
            case "*":
                node = .kleeneStar(node)
                index = pattern.index(after: index)
            case "+":
                node = .plus(node)
                index = pattern.index(after: index)
            case "?":
                node = .optional(node)
                index = pattern.index(after: index)
            default:
                break
            }
        }
        
        return node
    }
    
    static func match(_ pattern: String, _ input: String) -> Bool {
        guard let ast = parse(pattern) else { return false }
        var index = input.startIndex
        return matchNode(ast, input, &index) && index == input.endIndex
    }
    
    private static func matchNode(_ node: RegexNode, _ input: String, _ index: inout String.Index) -> Bool {
        switch node {
        case .literal(let char):
            if index < input.endIndex && input[index] == char {
                index = input.index(after: index)
                return true
            }
            return false
            
        case .concatenation(let nodes):
            for n in nodes {
                if !matchNode(n, input, &index) {
                    return false
                }
            }
            return true
            
        case .alternation(let nodes):
            let startIndex = index
            for n in nodes {
                index = startIndex
                if matchNode(n, input, &index) {
                    return true
                }
            }
            return false
            
        case .kleeneStar(let innerNode):
            while matchNode(innerNode, input, &index) {}
            return true
            
        case .plus(let innerNode):
            guard matchNode(innerNode, input, &index) else { return false }
            while matchNode(innerNode, input, &index) {}
            return true
            
        case .optional(let innerNode):
            _ = matchNode(innerNode, input, &index)
            return true
        }
    }
}

// MARK: - Example Usage
func runAutomataSimulator() {
    print("=== Automata & Formal Language Simulator ===\n")
    
    // Create a simple FSM that accepts strings ending in "c"
    let q0 = State("q0")
    let q1 = State("q1")
    let q2 = State("q2", accepting: true)
    
    let states: Set<State> = [q0, q1, q2]
    let transitions = [
        Transition(from: q0, to: q1, symbol: "a"),
        Transition(from: q1, to: q2, symbol: "b"),
        Transition(from: q2, to: q0, symbol: "c")
    ]
    
    let fsm = FiniteStateMachine(states: states, transitions: transitions, initialState: q0, alphabet: ["a", "b", "c"])
    
    print("Testing FSM:")
    let testStrings = ["abc", "ab", "abcabc", "xyz"]
    for testString in testStrings {
        let result = fsm.processString(testString)
        print("\nInput: \"\(testString)\"")
        result.trace.forEach { print($0) }
    }
    
    print("\n\n=== Regular Expression Matching ===\n")
    let regexPatterns = ["(a|b)*c", "a+b*", "(ab)+"]
    let testInputs = ["aaac", "abb", "abab"]
    
    for (pattern, input) in zip(regexPatterns, testInputs) {
        let matches = RegexEngine.match(pattern, input)
        print("Pattern: \(pattern)")
        print("Input: \(input)")
        print("Result: \(matches ? "✓ MATCH" : "✗ NO MATCH")\n")
    }
}

runAutomataSimulator()