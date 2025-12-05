# Automata & Formal Language Simulator

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Language: Multi](https://img.shields.io/badge/Languages-Swift%20|%20Ruby%20|%20Obj--C%20|%20Pascal%20|%20C-blue.svg)]()
[![Platform: Cross-Platform](https://img.shields.io/badge/Platform-Cross--Platform-green.svg)]()

A comprehensive, multi-language implementation of formal language theory concepts featuring finite state machines (FSM), regular expression matching, and automata visualization. This project demonstrates advanced algorithm design and compiler theory principles through interactive simulations.

---

## 🎯 Project Overview

This simulator provides a complete toolkit for understanding and working with formal languages and automata theory. It includes:

- **Visual FSM Designer**: Interactive state machine creation with real-time visualization
- **Step-by-Step Execution**: Animated string processing with detailed execution traces
- **Regex Engine**: Pattern matching with granular step-by-step analysis
- **NFA to DFA Conversion**: Implementation of subset construction algorithm
- **Multi-Language Support**: Implementations in Swift, Ruby, Objective-C, Pascal, and C--

---

## 🚀 Features

### Core Capabilities

- **Finite State Machine Simulation**
  - Create and modify states dynamically
  - Define transitions with custom alphabets
  - Specify accepting states for language recognition
  - Visual representation of state transitions
  - Real-time state highlighting during execution

- **String Acceptance Testing**
  - Process input strings character-by-character
  - Display complete execution trace
  - Identify transition paths and dead states
  - Accept/reject determination with explanations

- **Regular Expression Engine**
  - Pattern matching with support for:
    - Concatenation
    - Alternation (|)
    - Kleene star (*)
    - Plus operator (+)
    - Optional operator (?)
  - Step-by-step match visualization
  - Partial string analysis

- **NFA to DFA Conversion**
  - Epsilon-closure computation
  - Subset construction algorithm
  - Deterministic state generation
  - Visual comparison of NFA vs DFA

### Interactive Web Interface

- **Amazon-Themed UI**: Professional orange/black/white color scheme
- **Chatbot-Style Interface**: Natural conversation flow for commands
- **Developer Control Panel**: Advanced configuration options
  - Animation speed adjustment
  - State management
  - Transition editing
  - Alphabet configuration
  - Real-time FSM visualization

---

## 📁 Directory Structure

```
automata-simulator/
├── README.md
├── AutomataSimulator.swift          # Swift implementation
├── automata_simulator.rb            # Ruby implementation
├── AutomataSimulator.m              # Objective-C implementation
├── AutomataSimulator.pas            # Pascal implementation
└── automata_simulator.c             # C-- implementation
```

---

## 🛠️ Technologies & Skills

### Programming Languages
- **Swift**: iOS/macOS development with strong type safety
- **Ruby**: Dynamic scripting with elegant syntax
- **Objective-C**: Foundation frameworks and Cocoa integration
- **Pascal**: Structured programming and algorithmic design
- **C--**: Low-level systems programming

### Computer Science Concepts
- Finite State Machines (DFA/NFA)
- Regular Expressions & Pattern Matching
- Automata Theory & Formal Languages
- Algorithm Design & Complexity Analysis
- Compiler Design Principles
- Graph Theory & State Diagrams

### Software Engineering
- Object-Oriented Design
- Data Structures (Sets, Graphs, State Machines)
- Algorithm Optimization
- Cross-Platform Development
- Interactive UI/UX Design

---

## 💻 Installation & Usage

### Web Interface (React)

The interactive web simulator requires no installation:

1. Open the artifact in your browser
2. Choose between FSM or Regex mode
3. Enter test strings to process
4. Use developer controls for advanced configuration

### Swift Implementation

```bash
# Compile and run
swiftc AutomataSimulator.swift -o automata_swift
./automata_swift
```

### Ruby Implementation

```bash
# Run directly
ruby automata_simulator.rb
```

### Objective-C Implementation

```bash
# Compile with Clang
clang -framework Foundation AutomataSimulator.m -o automata_objc
./automata_objc
```

### Pascal Implementation

```bash
# Compile with Free Pascal
fpc AutomataSimulator.pas
./AutomataSimulator
```

### C-- Implementation

```bash
# Compile with GCC
gcc -o automata_c automata_simulator.c
./automata_c
```

---

## 📚 Usage Examples

### Example 1: Binary Number Validator

Create an FSM that accepts binary strings ending in "01":

```
States: q0 (start), q1, q2 (accept)
Transitions:
  q0 --0--> q1
  q0 --1--> q0
  q1 --0--> q1
  q1 --1--> q2
  q2 --0--> q1
  q2 --1--> q0
```

Test strings: "101", "1001", "1101" ✓ | "100", "110" ✗

### Example 2: Email Pattern Matcher

Regex pattern: `[a-zA-Z0-9]+@[a-zA-Z]+\.[a-z]{2,}`

- Matches: "user@example.com", "test123@domain.org"
- Rejects: "@invalid.com", "no-at-sign.com"

### Example 3: Compiler Lexer Simulation

Use FSM to tokenize programming language constructs:

```
Identifier: [a-zA-Z][a-zA-Z0-9]*
Number: [0-9]+
Operator: [+\-*/=]
```

---

## 🎓 Real-World Applications

### Compiler Design
- **Lexical Analysis**: Tokenization of source code
- **Syntax Checking**: Grammar validation
- **Code Generation**: Optimization patterns

### Text Processing
- **Search & Replace**: Pattern-based transformations
- **Input Validation**: Email, phone, URL validation
- **Data Extraction**: Log parsing, web scraping

### AI & Game Development
- **Behavior Trees**: NPC state machines
- **Game Logic**: State-based gameplay
- **Pathfinding**: Transition-based navigation

### Protocol Validation
- **Network Protocols**: State-based communication
- **API Testing**: Request/response validation
- **Security**: Input sanitization

---

## 🔬 Algorithm Details

### NFA to DFA Conversion (Subset Construction)

**Time Complexity**: O(2^n) where n is number of NFA states  
**Space Complexity**: O(2^n) for worst-case state explosion

**Algorithm Steps**:
1. Compute ε-closure of initial state
2. For each unmarked DFA state:
   - For each input symbol:
     - Compute target NFA states
     - Compute ε-closure of targets
     - Create new DFA state if needed
3. Mark states as accepting if they contain NFA accept states

### Regex Matching Engine

**Approach**: Recursive descent parsing with backtracking  
**Time Complexity**: O(m*n) for pattern length m and input length n  

**Supported Operators**:
- Literal matching: Direct character comparison
- Alternation (|): Try each alternative
- Kleene star (*): Match zero or more occurrences
- Plus (+): Match one or more occurrences
- Optional (?): Match zero or one occurrence

---

## 🎨 Interactive Features

### Developer Control Panel

- **Animation Speed**: 100ms - 2000ms adjustable delay
- **State Management**: Add/remove states dynamically
- **Transition Editor**: Visual transition creation
- **Alphabet Configuration**: Define custom input symbols
- **Accept States**: Toggle accepting state status
- **Real-Time Visualization**: Canvas-based FSM rendering

### Visual Feedback

- **State Highlighting**: Current state shown in orange
- **Accept States**: Green border indication
- **Transition Animation**: Smooth state changes
- **Execution Trace**: Detailed step-by-step log
- **Error Handling**: Clear rejection messages

---

## 🧪 Testing

Each implementation includes built-in test cases:

```
Test String: "abc" → ACCEPTED (matches (abc)* with n=1)
Test String: "ab" → REJECTED (incomplete pattern)
Test String: "abcabc" → ACCEPTED (matches (abc)* with n=2)
Test String: "xyz" → REJECTED (invalid symbols)
```

### Regex Test Suite

```
Pattern: (a|b)*c
Input: "aaac" → MATCH
Input: "bbbbc" → MATCH
Input: "aaab" → NO MATCH

Pattern: a+b*
Input: "aaa" → MATCH
Input: "aaabbb" → MATCH
Input: "bbb" → NO MATCH
```

---

## 🤝 Contributing

This project demonstrates advanced CS concepts for educational and portfolio purposes. Suggestions for improvements:

1. **Extended Regex Support**: Lookahead/lookbehind assertions
2. **Minimization Algorithms**: Hopcroft's algorithm for DFA minimization
3. **Pushdown Automata**: Context-free grammar support
4. **Performance Optimization**: Memoization for regex matching
5. **Additional Languages**: Python, Java, JavaScript implementations

---

## 📖 Educational Value

### Learning Objectives

- **Theoretical Foundations**: Understanding formal language hierarchy
- **Practical Implementation**: Translating theory to working code
- **Algorithm Analysis**: Complexity evaluation and optimization
- **Software Design**: Multi-language architecture patterns
- **Visual Communication**: Interactive educational tools

### Suitable For

- Computer Science students studying automata theory
- Compiler design course projects
- Algorithm interview preparation
- Software engineering portfolios
- Teaching formal languages interactively

---

## 📊 Performance Metrics

| Operation | Time Complexity | Space Complexity |
|-----------|----------------|------------------|
| FSM String Processing | O(n) | O(1) |
| NFA to DFA Conversion | O(2^n) | O(2^n) |
| Regex Matching | O(m*n) | O(m) |
| State Addition | O(1) | O(1) |
| Transition Addition | O(1) | O(1) |

Where:
- n = input string length / number of states
- m = pattern length

---

## 🔗 Related Concepts

- **Turing Machines**: Universal computation models
- **Context-Free Grammars**: Parsing and syntax trees
- **Lambda Calculus**: Functional computation foundations
- **Type Systems**: Formal verification and type theory
- **Model Checking**: Automated verification techniques

---

## 📄 License

MIT License - Feel free to use this project for educational and portfolio purposes.

---

## 👨‍💻 Author

Created as a comprehensive demonstration of formal language theory, algorithm design, and multi-language programming proficiency.

**Skills Demonstrated**:
- Finite State Machines & Automata Theory
- Regular Expression Engines
- Algorithm Design & Analysis
- Multi-Language Proficiency
- Interactive UI Development
- Compiler Design Principles
- Software Architecture
- Technical Documentation

---

## 🌟 Acknowledgments

This project synthesizes concepts from:
- *Introduction to the Theory of Computation* by Michael Sipser
- *Compilers: Principles, Techniques, and Tools* by Aho, Lam, Sethi, Ullman
- Classical automata theory and formal language research

---

## 📞 Contact & Portfolio

This project is part of a comprehensive software engineering portfolio demonstrating:
- Theoretical computer science expertise
- Practical algorithm implementation
- Multi-paradigm programming proficiency
- Interactive software design
- Educational technology development

For inquiries about implementation details or technical discussions, please reach out via GitHub.

---

**Version**: 1.0.0  
**Last Updated**: 2025  
**Status**: Production-Ready Educational Tool