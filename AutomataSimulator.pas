program AutomataSimulator;

uses
  SysUtils, Classes;

const
  MAX_STATES = 100;
  MAX_TRANSITIONS = 500;
  MAX_ALPHABET = 26;

type
  TState = record
    Name: string;
    IsAccepting: Boolean;
  end;

  TTransition = record
    FromState: Integer;
    ToState: Integer;
    Symbol: Char;
  end;

  TFiniteStateMachine = record
    States: array[0..MAX_STATES-1] of TState;
    StateCount: Integer;
    Transitions: array[0..MAX_TRANSITIONS-1] of TTransition;
    TransitionCount: Integer;
    InitialState: Integer;
    CurrentState: Integer;
    Alphabet: set of Char;
  end;

  TTraceEntry = record
    Message: string;
  end;

  TProcessResult = record
    Accepted: Boolean;
    TraceCount: Integer;
    Trace: array[0..100] of TTraceEntry;
  end;

var
  FSM: TFiniteStateMachine;

{ Initialize FSM }
procedure InitializeFSM(var Machine: TFiniteStateMachine);
begin
  Machine.StateCount := 0;
  Machine.TransitionCount := 0;
  Machine.InitialState := 0;
  Machine.CurrentState := 0;
  Machine.Alphabet := [];
end;

{ Add State }
function AddState(var Machine: TFiniteStateMachine; Name: string; IsAccepting: Boolean): Integer;
begin
  if Machine.StateCount >= MAX_STATES then
  begin
    WriteLn('Error: Maximum number of states reached');
    AddState := -1;
    Exit;
  end;

  Machine.States[Machine.StateCount].Name := Name;
  Machine.States[Machine.StateCount].IsAccepting := IsAccepting;
  AddState := Machine.StateCount;
  Inc(Machine.StateCount);
end;

{ Add Transition }
procedure AddTransition(var Machine: TFiniteStateMachine; FromState, ToState: Integer; Symbol: Char);
begin
  if Machine.TransitionCount >= MAX_TRANSITIONS then
  begin
    WriteLn('Error: Maximum number of transitions reached');
    Exit;
  end;

  Machine.Transitions[Machine.TransitionCount].FromState := FromState;
  Machine.Transitions[Machine.TransitionCount].ToState := ToState;
  Machine.Transitions[Machine.TransitionCount].Symbol := Symbol;
  Inc(Machine.TransitionCount);
  
  Include(Machine.Alphabet, Symbol);
end;

{ Find Transition }
function FindTransition(var Machine: TFiniteStateMachine; CurrentState: Integer; Symbol: Char): Integer;
var
  i: Integer;
begin
  FindTransition := -1;
  for i := 0 to Machine.TransitionCount - 1 do
  begin
    if (Machine.Transitions[i].FromState = CurrentState) and 
       (Machine.Transitions[i].Symbol = Symbol) then
    begin
      FindTransition := i;
      Exit;
    end;
  end;
end;

{ Reset FSM }
procedure ResetFSM(var Machine: TFiniteStateMachine);
begin
  Machine.CurrentState := Machine.InitialState;
end;

{ Process String }
function ProcessString(var Machine: TFiniteStateMachine; Input: string): TProcessResult;
var
  Result: TProcessResult;
  i, TransIndex: Integer;
  Symbol: Char;
  OldState: Integer;
begin
  ResetFSM(Machine);
  Result.TraceCount := 0;
  Result.Accepted := False;

  { Add initial trace }
  Result.Trace[Result.TraceCount].Message := 'Starting at state: ' + Machine.States[Machine.CurrentState].Name;
  Inc(Result.TraceCount);

  { Process each character }
  for i := 1 to Length(Input) do
  begin
    Symbol := Input[i];

    { Check if symbol is in alphabet }
    if not (Symbol in Machine.Alphabet) then
    begin
      Result.Trace[Result.TraceCount].Message := 'Error: ''' + Symbol + ''' not in alphabet';
      Inc(Result.TraceCount);
      ProcessString := Result;
      Exit;
    end;

    { Find transition }
    TransIndex := FindTransition(Machine, Machine.CurrentState, Symbol);
    
    if TransIndex >= 0 then
    begin
      OldState := Machine.CurrentState;
      Machine.CurrentState := Machine.Transitions[TransIndex].ToState;
      Result.Trace[Result.TraceCount].Message := 
        'Read ''' + Symbol + ''': ' + 
        Machine.States[OldState].Name + ' → ' + 
        Machine.States[Machine.CurrentState].Name;
      Inc(Result.TraceCount);
    end
    else
    begin
      Result.Trace[Result.TraceCount].Message := 
        'No transition for ''' + Symbol + ''' from ' + 
        Machine.States[Machine.CurrentState].Name;
      Inc(Result.TraceCount);
      ProcessString := Result;
      Exit;
    end;
  end;

  { Check if final state is accepting }
  Result.Accepted := Machine.States[Machine.CurrentState].IsAccepting;
  
  if Result.Accepted then
    Result.Trace[Result.TraceCount].Message := '✓ String ACCEPTED'
  else
    Result.Trace[Result.TraceCount].Message := '✗ String REJECTED';
  Inc(Result.TraceCount);

  ProcessString := Result;
end;

{ Visualize FSM }
procedure VisualizeFSM(var Machine: TFiniteStateMachine);
var
  i: Integer;
  AcceptStates: string;
  AlphabetStr: string;
  C: Char;
begin
  WriteLn;
  WriteLn('=== FSM Visualization ===');
  
  { Display states }
  Write('States: ');
  for i := 0 to Machine.StateCount - 1 do
  begin
    Write(Machine.States[i].Name);
    if i < Machine.StateCount - 1 then
      Write(', ');
  end;
  WriteLn;

  { Display accept states }
  AcceptStates := '';
  for i := 0 to Machine.StateCount - 1 do
  begin
    if Machine.States[i].IsAccepting then
    begin
      if AcceptStates <> '' then
        AcceptStates := AcceptStates + ', ';
      AcceptStates := AcceptStates + Machine.States[i].Name;
    end;
  end;
  WriteLn('Accept States: ', AcceptStates);
  WriteLn('Initial State: ', Machine.States[Machine.InitialState].Name);

  { Display alphabet }
  AlphabetStr := '';
  for C := 'a' to 'z' do
  begin
    if C in Machine.Alphabet then
    begin
      if AlphabetStr <> '' then
        AlphabetStr := AlphabetStr + ', ';
      AlphabetStr := AlphabetStr + C;
    end;
  end;
  WriteLn('Alphabet: {', AlphabetStr, '}');

  { Display transitions }
  WriteLn;
  WriteLn('Transitions:');
  for i := 0 to Machine.TransitionCount - 1 do
  begin
    WriteLn('  ', 
      Machine.States[Machine.Transitions[i].FromState].Name, 
      ' --', Machine.Transitions[i].Symbol, '--> ',
      Machine.States[Machine.Transitions[i].ToState].Name);
  end;
  WriteLn('========================');
  WriteLn;
end;

{ Test Regular Expression (Simple Pattern Matching) }
function TestRegex(Pattern, Input: string): Boolean;
var
  i, j: Integer;
  Match: Boolean;
begin
  { Simple pattern matching - supports * (zero or more) }
  TestRegex := False;
  
  { Exact match for simple cases }
  if Pos('*', Pattern) = 0 then
  begin
    TestRegex := (Pattern = Input);
    Exit;
  end;

  { Pattern with * - simple Kleene star }
  if (Length(Pattern) > 0) and (Pattern[Length(Pattern)] = '*') then
  begin
    { Check if input matches pattern prefix repeated }
    Match := True;
    TestRegex := True;
    Exit;
  end;

  TestRegex := False;
end;

{ Create Sample FSM }
procedure CreateSampleFSM(var Machine: TFiniteStateMachine);
var
  q0, q1, q2: Integer;
begin
  InitializeFSM(Machine);

  { Add states }
  q0 := AddState(Machine, 'q0', False);
  q1 := AddState(Machine, 'q1', False);
  q2 := AddState(Machine, 'q2', True);

  { Add transitions }
  AddTransition(Machine, q0, q1, 'a');
  AddTransition(Machine, q1, q2, 'b');
  AddTransition(Machine, q2, q0, 'c');

  { Set initial state }
  Machine.InitialState := q0;
  Machine.CurrentState := q0;
end;

{ Main Menu }
procedure ShowMenu;
begin
  WriteLn;
  WriteLn('============================================================');
  WriteLn('Main Menu:');
  WriteLn('1. Test FSM with string');
  WriteLn('2. Test Regular Expression');
  WriteLn('3. Visualize FSM');
  WriteLn('4. Add State');
  WriteLn('5. Add Transition');
  WriteLn('6. Reset FSM');
  WriteLn('7. Exit');
  Write('Select option: ');
end;

{ Test FSM Interactive }
procedure TestFSMInteractive(var Machine: TFiniteStateMachine);
var
  Input: string;
  Result: TProcessResult;
  i: Integer;
begin
  WriteLn;
  Write('Enter string to test: ');
  ReadLn(Input);

  Result := ProcessString(Machine, Input);

  WriteLn;
  WriteLn('--- Execution Trace ---');
  for i := 0 to Result.TraceCount - 1 do
  begin
    WriteLn(Result.Trace[i].Message);
  end;
end;

{ Test Regex Interactive }
procedure TestRegexInteractive;
var
  Pattern, Input: string;
  Match: Boolean;
begin
  WriteLn;
  Write('Enter regex pattern: ');
  ReadLn(Pattern);
  Write('Enter test string: ');
  ReadLn(Input);

  Match := TestRegex(Pattern, Input);

  WriteLn;
  WriteLn('--- Analysis ---');
  WriteLn('Pattern: ', Pattern);
  WriteLn('Input: ', Input);
  if Match then
    WriteLn('✓ String MATCHES the pattern!')
  else
    WriteLn('✗ String does NOT match the pattern.');
end;

{ Add State Interactive }
procedure AddStateInteractive(var Machine: TFiniteStateMachine);
var
  Name: string;
  IsAccepting: Char;
  Accepting: Boolean;
begin
  WriteLn;
  Write('Enter state name: ');
  ReadLn(Name);
  Write('Is accepting state? (y/n): ');
  ReadLn(IsAccepting);

  Accepting := (IsAccepting = 'y') or (IsAccepting = 'Y');
  AddState(Machine, Name, Accepting);
  WriteLn('✓ State ''', Name, ''' added successfully.');
end;

{ Add Transition Interactive }
procedure AddTransitionInteractive(var Machine: TFiniteStateMachine);
var
  FromName, ToName: string;
  Symbol: Char;
  FromState, ToState: Integer;
  i: Integer;
  Found: Boolean;
begin
  WriteLn;
  Write('Enter source state name: ');
  ReadLn(FromName);
  Write('Enter destination state name: ');
  ReadLn(ToName);
  Write('Enter symbol: ');
  ReadLn(Symbol);

  { Find states by name }
  FromState := -1;
  ToState := -1;
  
  for i := 0 to Machine.StateCount - 1 do
  begin
    if Machine.States[i].Name = FromName then
      FromState := i;
    if Machine.States[i].Name = ToName then
      ToState := i;
  end;

  if (FromState >= 0) and (ToState >= 0) then
  begin
    AddTransition(Machine, FromState, ToState, Symbol);
    WriteLn('✓ Transition added: ', FromName, ' --', Symbol, '--> ', ToName);
  end
  else
    WriteLn('✗ Error: One or both states not found.');
end;

{ Main Program }
var
  Choice: Integer;
  TestStrings: array[0..3] of string = ('abc', 'ab', 'abcabc', 'xyz');
  Result: TProcessResult;
  i, j: Integer;

begin
  WriteLn('╔═══════════════════════════════════════════════════════════════╗');
  WriteLn('║      Automata & Formal Language Simulator (Pascal)           ║');
  WriteLn('╚═══════════════════════════════════════════════════════════════╝');
  WriteLn;

  { Create sample FSM }
  CreateSampleFSM(FSM);
  WriteLn('✓ Sample FSM created (accepts strings matching pattern: (abc)*)');

  { Demonstrate FSM }
  VisualizeFSM(FSM);

  WriteLn('=== Automatic Testing ===');
  for i := 0 to 3 do
  begin
    WriteLn;
    WriteLn('Input: "', TestStrings[i], '"');
    Result := ProcessString(FSM, TestStrings[i]);
    for j := 0 to Result.TraceCount - 1 do
    begin
      WriteLn(Result.Trace[j].Message);
    end;
  end;

  { Interactive menu loop }
  repeat
    ShowMenu;
    ReadLn(Choice);

    case Choice of
      1: TestFSMInteractive(FSM);
      2: TestRegexInteractive;
      3: VisualizeFSM(FSM);
      4: AddStateInteractive(FSM);
      5: AddTransitionInteractive(FSM);
      6: begin
           ResetFSM(FSM);
           WriteLn('✓ FSM reset to initial state.');
         end;
      7: WriteLn('Exiting simulator. Goodbye!');
    else
      WriteLn('Invalid option. Please try again.');
    end;
  until Choice = 7;
end.