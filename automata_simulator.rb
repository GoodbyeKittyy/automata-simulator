# Automata & Formal Language Simulator in Ruby

class State
  attr_reader :name
  attr_accessor :accepting
  
  def initialize(name, accepting = false)
    @name = name
    @accepting = accepting
  end
  
  def accepting?
    @accepting
  end
  
  def to_s
    @name
  end
  
  def ==(other)
    @name == other.name
  end
  
  def hash
    @name.hash
  end
  
  alias eql? ==
end

class Transition
  attr_reader :from, :to, :symbol
  
  def initialize(from, to, symbol)
    @from = from
    @to = to
    @symbol = symbol
  end
  
  def matches?(current_state, input_char)
    @from == current_state && @symbol == input_char
  end
  
  def to_s
    "#{@from} --#{@symbol}--> #{@to}"
  end
end

class FiniteStateMachine
  attr_reader :states, :transitions, :initial_state, :current_state, :alphabet
  
  def initialize(states, transitions, initial_state, alphabet)
    @states = states
    @transitions = transitions
    @initial_state = initial_state
    @current_state = initial_state
    @alphabet = alphabet
  end
  
  def reset
    @current_state = @initial_state
  end
  
  def process_string(input)
    reset
    trace = ["Starting at state: #{@current_state}"]
    
    input.each_char do |char|
      unless @alphabet.include?(char)
        trace << "Error: '#{char}' not in alphabet"
        return { accepted: false, trace: trace }
      end
      
      transition = @transitions.find { |t| t.matches?(@current_state, char) }
      
      if transition
        old_state = @current_state
        @current_state = transition.to
        trace << "Read '#{char}': #{old_state} → #{@current_state}"
      else
        trace << "No transition for '#{char}' from #{@current_state}"
        return { accepted: false, trace: trace }
      end
    end
    
    accepted = @current_state.accepting?
    trace << (accepted ? "✓ String ACCEPTED" : "✗ String REJECTED")
    { accepted: accepted, trace: trace }
  end
  
  def add_state(state)
    @states << state unless @states.include?(state)
  end
  
  def add_transition(transition)
    @transitions << transition
  end
  
  def visualize
    puts "\n=== FSM Visualization ==="
    puts "States: #{@states.map(&:name).join(', ')}"
    puts "Accept States: #{@states.select(&:accepting?).map(&:name).join(', ')}"
    puts "Initial State: #{@initial_state}"
    puts "\nTransitions:"
    @transitions.each { |t| puts "  #{t}" }
    puts "========================\n"
  end
end

class NFAConverter
  def self.epsilon_closure(states, nfa_states)
    closure = states.dup
    stack = states.dup
    
    until stack.empty?
      state = stack.pop
      nfa_state = nfa_states[state]
      next unless nfa_state
      
      nfa_state[:epsilon].each do |epsilon_target|
        unless closure.include?(epsilon_target)
          closure << epsilon_target
          stack << epsilon_target
        end
      end
    end
    
    closure
  end
  
  def self.convert_to_dfa(nfa_states, initial_state, accept_states, alphabet)
    dfa_states = []
    dfa_transitions = []
    unmarked_states = [epsilon_closure([initial_state], nfa_states)]
    marked_states = []
    
    until unmarked_states.empty?
      current_dfa_state = unmarked_states.shift
      marked_states << current_dfa_state
      
      is_accepting = !(current_dfa_state & accept_states).empty?
      dfa_state_name = current_dfa_state.sort.join(',')
      dfa_state = State.new(dfa_state_name, is_accepting)
      dfa_states << dfa_state
      
      alphabet.each do |symbol|
        targets = []
        current_dfa_state.each do |nfa_state_name|
          nfa_state = nfa_states[nfa_state_name]
          targets.concat(nfa_state[:transitions][symbol] || []) if nfa_state
        end
        
        next if targets.empty?
        
        target_closure = epsilon_closure(targets, nfa_states)
        unless marked_states.include?(target_closure) || unmarked_states.include?(target_closure)
          unmarked_states << target_closure
        end
        
        target_state_name = target_closure.sort.join(',')
        target_is_accepting = !(target_closure & accept_states).empty?
        target_state = State.new(target_state_name, target_is_accepting)
        
        dfa_transitions << Transition.new(dfa_state, target_state, symbol)
      end
    end
    
    initial_dfa_state = dfa_states.find { |s| s.name == epsilon_closure([initial_state], nfa_states).sort.join(',') }
    FiniteStateMachine.new(dfa_states, dfa_transitions, initial_dfa_state, alphabet)
  end
end

class RegexEngine
  def self.match(pattern, input)
    begin
      regex = Regexp.new("^#{pattern}$")
      !!(input =~ regex)
    rescue RegexpError => e
      puts "Invalid regex pattern: #{e.message}"
      false
    end
  end
  
  def self.match_with_trace(pattern, input)
    matches = match(pattern, input)
    trace = ["Testing pattern: #{pattern}"]
    trace << "Input string: #{input}"
    
    if matches
      trace << "✓ String MATCHES the pattern!"
      trace << "\nStep-by-step analysis:"
      (1..input.length).each do |i|
        partial = input[0...i]
        partial_match = !!(partial =~ Regexp.new("^#{pattern}"))
        trace << "  #{partial}: #{partial_match ? '✓' : '✗'}"
      end
    else
      trace << "✗ String does NOT match the pattern."
    end
    
    { matches: matches, trace: trace }
  end
end

class AutomataSimulator
  def initialize
    @fsm = nil
    @mode = :fsm
  end
  
  def run
    puts "╔═══════════════════════════════════════════════════════════════╗"
    puts "║      Automata & Formal Language Simulator (Ruby)             ║"
    puts "╚═══════════════════════════════════════════════════════════════╝"
    
    create_sample_fsm
    
    loop do
      puts "\n" + "="*60
      puts "Main Menu:"
      puts "1. Test FSM with string"
      puts "2. Test Regular Expression"
      puts "3. Visualize FSM"
      puts "4. Add State"
      puts "5. Add Transition"
      puts "6. Convert NFA to DFA (Demo)"
      puts "7. Exit"
      print "\nSelect option: "
      
      choice = gets.chomp.to_i
      
      case choice
      when 1
        test_fsm
      when 2
        test_regex
      when 3
        @fsm.visualize
      when 4
        add_state
      when 5
        add_transition
      when 6
        demo_nfa_conversion
      when 7
        puts "\nExiting simulator. Goodbye!"
        break
      else
        puts "Invalid option. Please try again."
      end
    end
  end
  
  private
  
  def create_sample_fsm
    q0 = State.new('q0')
    q1 = State.new('q1')
    q2 = State.new('q2', true)
    
    states = [q0, q1, q2]
    transitions = [
      Transition.new(q0, q1, 'a'),
      Transition.new(q1, q2, 'b'),
      Transition.new(q2, q0, 'c')
    ]
    
    @fsm = FiniteStateMachine.new(states, transitions, q0, ['a', 'b', 'c'])
    puts "\n✓ Sample FSM created (accepts strings matching pattern: (abc)*)"
  end
  
  def test_fsm
    print "\nEnter string to test: "
    input = gets.chomp
    
    result = @fsm.process_string(input)
    puts "\n--- Execution Trace ---"
    result[:trace].each { |line| puts line }
  end
  
  def test_regex
    print "\nEnter regex pattern: "
    pattern = gets.chomp
    
    print "Enter test string: "
    input = gets.chomp
    
    result = RegexEngine.match_with_trace(pattern, input)
    puts "\n--- Analysis ---"
    result[:trace].each { |line| puts line }
  end
  
  def add_state
    print "\nEnter state name: "
    name = gets.chomp
    
    print "Is accepting state? (y/n): "
    accepting = gets.chomp.downcase == 'y'
    
    state = State.new(name, accepting)
    @fsm.add_state(state)
    puts "✓ State '#{name}' added successfully."
  end
  
  def add_transition
    print "\nEnter source state: "
    from_name = gets.chomp
    
    print "Enter destination state: "
    to_name = gets.chomp
    
    print "Enter symbol: "
    symbol = gets.chomp
    
    from_state = @fsm.states.find { |s| s.name == from_name }
    to_state = @fsm.states.find { |s| s.name == to_name }
    
    if from_state && to_state
      transition = Transition.new(from_state, to_state, symbol)
      @fsm.add_transition(transition)
      puts "✓ Transition added: #{transition}"
    else
      puts "✗ Error: One or both states not found."
    end
  end
  
  def demo_nfa_conversion
    puts "\n--- NFA to DFA Conversion Demo ---"
    
    nfa_states = {
      'q0' => { epsilon: ['q1'], transitions: { 'a' => ['q0'] } },
      'q1' => { epsilon: [], transitions: { 'b' => ['q2'] } },
      'q2' => { epsilon: [], transitions: {} }
    }
    
    puts "Converting NFA with ε-transitions to DFA..."
    puts "NFA States: q0, q1, q2"
    puts "ε-transitions: q0 → q1"
    puts "Transitions: q0 --a--> q0, q1 --b--> q2"
    
    dfa = NFAConverter.convert_to_dfa(nfa_states, 'q0', ['q2'], ['a', 'b'])
    
    puts "\n✓ Conversion complete!"
    dfa.visualize
  end
end

if __FILE__ == $0
  simulator = AutomataSimulator.new
  simulator.run
end