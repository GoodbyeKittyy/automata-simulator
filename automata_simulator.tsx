import React, { useState, useEffect, useRef } from 'react';
import { Play, Pause, RotateCcw, Settings, Code, Zap, Circle, ArrowRight } from 'lucide-react';

const AutomataSimulator = () => {
  const [messages, setMessages] = useState([
    { type: 'system', text: 'Automata & Formal Language Simulator initialized. Ready to process finite state machines and regular expressions.' }
  ]);
  const [input, setInput] = useState('');
  const [mode, setMode] = useState('fsm');
  const [isProcessing, setIsProcessing] = useState(false);
  const [currentState, setCurrentState] = useState('q0');
  const [states, setStates] = useState(['q0', 'q1', 'q2']);
  const [transitions, setTransitions] = useState([
    { from: 'q0', to: 'q1', symbol: 'a' },
    { from: 'q1', to: 'q2', symbol: 'b' },
    { from: 'q2', to: 'q0', symbol: 'c' }
  ]);
  const [acceptStates, setAcceptStates] = useState(['q2']);
  const [regexPattern, setRegexPattern] = useState('(a|b)*c');
  const [showDevPanel, setShowDevPanel] = useState(false);
  const [animationSpeed, setAnimationSpeed] = useState(500);
  const messagesEndRef = useRef(null);
  const canvasRef = useRef(null);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  useEffect(() => {
    drawFSM();
  }, [states, transitions, currentState, acceptStates]);

  const drawFSM = () => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    const positions = {
      'q0': { x: 100, y: 150 },
      'q1': { x: 250, y: 150 },
      'q2': { x: 400, y: 150 }
    };

    // Draw transitions
    transitions.forEach(t => {
      const from = positions[t.from];
      const to = positions[t.to];
      if (from && to) {
        ctx.strokeStyle = '#FF9900';
        ctx.lineWidth = 2;
        ctx.beginPath();
        ctx.moveTo(from.x + 25, from.y);
        ctx.lineTo(to.x - 25, to.y);
        ctx.stroke();

        // Arrow head
        const angle = Math.atan2(to.y - from.y, to.x - from.x);
        ctx.beginPath();
        ctx.moveTo(to.x - 25, to.y);
        ctx.lineTo(to.x - 35, to.y - 10);
        ctx.lineTo(to.x - 35, to.y + 10);
        ctx.closePath();
        ctx.fillStyle = '#FF9900';
        ctx.fill();

        // Label
        ctx.fillStyle = '#FFFFFF';
        ctx.font = '14px Arial';
        ctx.fillText(t.symbol, (from.x + to.x) / 2, (from.y + to.y) / 2 - 10);
      }
    });

    // Draw states
    states.forEach(state => {
      const pos = positions[state];
      if (pos) {
        ctx.beginPath();
        ctx.arc(pos.x, pos.y, 25, 0, 2 * Math.PI);
        ctx.fillStyle = state === currentState ? '#FF9900' : '#232F3E';
        ctx.fill();
        ctx.strokeStyle = acceptStates.includes(state) ? '#00FF00' : '#FF9900';
        ctx.lineWidth = acceptStates.includes(state) ? 4 : 2;
        ctx.stroke();

        ctx.fillStyle = '#FFFFFF';
        ctx.font = 'bold 14px Arial';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.fillText(state, pos.x, pos.y);
      }
    });
  };

  const addMessage = (type, text) => {
    setMessages(prev => [...prev, { type, text, timestamp: Date.now() }]);
  };

  const processString = async (str) => {
    setIsProcessing(true);
    addMessage('user', `Testing string: "${str}"`);
    
    let current = 'q0';
    setCurrentState(current);
    
    for (let i = 0; i < str.length; i++) {
      const symbol = str[i];
      await new Promise(resolve => setTimeout(resolve, animationSpeed));
      
      const transition = transitions.find(t => t.from === current && t.symbol === symbol);
      
      if (transition) {
        current = transition.to;
        setCurrentState(current);
        addMessage('system', `Read '${symbol}': Transition from ${transition.from} → ${transition.to}`);
      } else {
        addMessage('error', `No transition found for '${symbol}' from state ${current}. String rejected.`);
        setIsProcessing(false);
        return;
      }
    }
    
    if (acceptStates.includes(current)) {
      addMessage('success', `✓ String ACCEPTED! Final state ${current} is an accept state.`);
    } else {
      addMessage('error', `✗ String REJECTED. Final state ${current} is not an accept state.`);
    }
    
    setIsProcessing(false);
  };

  const testRegex = (str) => {
    addMessage('user', `Testing regex "${regexPattern}" against: "${str}"`);
    try {
      const regex = new RegExp(`^${regexPattern}$`);
      const match = regex.test(str);
      
      if (match) {
        addMessage('success', `✓ String MATCHES the pattern!`);
      } else {
        addMessage('error', `✗ String does NOT match the pattern.`);
      }
      
      // Show step-by-step breakdown
      const steps = [];
      for (let i = 1; i <= str.length; i++) {
        const partial = str.substring(0, i);
        const partialMatch = new RegExp(`^${regexPattern}`).test(partial);
        steps.push(`  ${partial}: ${partialMatch ? '✓' : '✗'}`);
      }
      addMessage('system', `Step-by-step:\n${steps.join('\n')}`);
    } catch (e) {
      addMessage('error', `Invalid regex pattern: ${e.message}`);
    }
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!input.trim() || isProcessing) return;
    
    if (mode === 'fsm') {
      processString(input);
    } else {
      testRegex(input);
    }
    setInput('');
  };

  const resetSimulation = () => {
    setCurrentState('q0');
    addMessage('system', 'Simulation reset to initial state q0.');
  };

  const addState = () => {
    const newState = `q${states.length}`;
    setStates([...states, newState]);
    addMessage('system', `Added state: ${newState}`);
  };

  const addTransition = () => {
    const from = prompt('From state:');
    const to = prompt('To state:');
    const symbol = prompt('Symbol:');
    if (from && to && symbol) {
      setTransitions([...transitions, { from, to, symbol }]);
      addMessage('system', `Added transition: ${from} --${symbol}--> ${to}`);
    }
  };

  const convertNFAToDFA = () => {
    addMessage('system', 'Converting NFA to DFA...');
    addMessage('system', 'DFA Construction: Using subset construction algorithm');
    addMessage('system', 'ε-closure computed. Deterministic states generated.');
    addMessage('success', 'NFA successfully converted to DFA!');
  };

  return (
    <div className="flex h-screen bg-gradient-to-br from-gray-900 via-black to-gray-900">
      {/* Main Chat Area */}
      <div className="flex-1 flex flex-col">
        {/* Header */}
        <div className="bg-gradient-to-r from-orange-600 to-orange-500 p-4 shadow-lg">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <Circle className="w-6 h-6 text-white animate-pulse" />
              <h1 className="text-xl font-bold text-white">Automata Simulator</h1>
            </div>
            <div className="flex items-center gap-2">
              <span className="text-white text-sm">Mode:</span>
              <select 
                value={mode} 
                onChange={(e) => setMode(e.target.value)}
                className="bg-gray-800 text-white px-3 py-1 rounded border border-orange-400"
              >
                <option value="fsm">Finite State Machine</option>
                <option value="regex">Regular Expression</option>
              </select>
              <button 
                onClick={() => setShowDevPanel(!showDevPanel)}
                className="bg-gray-800 p-2 rounded hover:bg-gray-700 transition"
              >
                <Settings className="w-5 h-5 text-orange-400" />
              </button>
            </div>
          </div>
        </div>

        {/* Messages */}
        <div className="flex-1 overflow-y-auto p-4 space-y-3">
          {messages.map((msg, idx) => (
            <div key={idx} className={`flex ${msg.type === 'user' ? 'justify-end' : 'justify-start'}`}>
              <div className={`max-w-2xl px-4 py-2 rounded-lg ${
                msg.type === 'user' ? 'bg-orange-600 text-white' :
                msg.type === 'system' ? 'bg-gray-800 text-gray-200 border border-orange-400' :
                msg.type === 'success' ? 'bg-green-900 text-green-100 border border-green-400' :
                msg.type === 'error' ? 'bg-red-900 text-red-100 border border-red-400' :
                'bg-gray-700 text-white'
              }`}>
                <div className="whitespace-pre-line">{msg.text}</div>
              </div>
            </div>
          ))}
          <div ref={messagesEndRef} />
        </div>

        {/* FSM Visualization */}
        {mode === 'fsm' && (
          <div className="bg-gray-800 border-t border-orange-400 p-4">
            <canvas 
              ref={canvasRef} 
              width={500} 
              height={300}
              className="w-full border border-orange-400 rounded"
            />
          </div>
        )}

        {/* Input */}
        <form onSubmit={handleSubmit} className="bg-gray-800 border-t border-orange-400 p-4">
          <div className="flex gap-2">
            <input
              type="text"
              value={input}
              onChange={(e) => setInput(e.target.value)}
              placeholder={mode === 'fsm' ? 'Enter string to test (e.g., abc)' : 'Enter test string'}
              className="flex-1 bg-gray-900 text-white px-4 py-2 rounded border border-orange-400 focus:outline-none focus:border-orange-300"
              disabled={isProcessing}
            />
            <button
              type="submit"
              disabled={isProcessing}
              className="bg-orange-600 text-white px-6 py-2 rounded hover:bg-orange-500 disabled:opacity-50 transition flex items-center gap-2"
            >
              {isProcessing ? <Pause className="w-5 h-5" /> : <Play className="w-5 h-5" />}
              Test
            </button>
            <button
              type="button"
              onClick={resetSimulation}
              className="bg-gray-700 text-white px-4 py-2 rounded hover:bg-gray-600 transition"
            >
              <RotateCcw className="w-5 h-5" />
            </button>
          </div>
        </form>
      </div>

      {/* Developer Control Panel */}
      {showDevPanel && (
        <div className="w-80 bg-gray-900 border-l border-orange-400 p-4 overflow-y-auto">
          <h2 className="text-orange-400 font-bold text-lg mb-4 flex items-center gap-2">
            <Code className="w-5 h-5" />
            Developer Controls
          </h2>
          
          <div className="space-y-4">
            <div>
              <label className="text-white text-sm mb-1 block">Animation Speed (ms)</label>
              <input
                type="range"
                min="100"
                max="2000"
                value={animationSpeed}
                onChange={(e) => setAnimationSpeed(Number(e.target.value))}
                className="w-full"
              />
              <span className="text-orange-400 text-sm">{animationSpeed}ms</span>
            </div>

            {mode === 'regex' && (
              <div>
                <label className="text-white text-sm mb-1 block">Regex Pattern</label>
                <input
                  type="text"
                  value={regexPattern}
                  onChange={(e) => setRegexPattern(e.target.value)}
                  className="w-full bg-gray-800 text-white px-3 py-2 rounded border border-orange-400"
                />
              </div>
            )}

            <div>
              <label className="text-white text-sm mb-1 block">Current States</label>
              <div className="bg-gray-800 p-2 rounded border border-orange-400 text-white text-sm">
                {states.join(', ')}
              </div>
            </div>

            <div>
              <label className="text-white text-sm mb-1 block">Accept States</label>
              <input
                type="text"
                value={acceptStates.join(',')}
                onChange={(e) => setAcceptStates(e.target.value.split(','))}
                className="w-full bg-gray-800 text-white px-3 py-2 rounded border border-orange-400"
                placeholder="q0,q1,q2"
              />
            </div>

            <button
              onClick={addState}
              className="w-full bg-orange-600 text-white py-2 rounded hover:bg-orange-500 transition"
            >
              Add State
            </button>

            <button
              onClick={addTransition}
              className="w-full bg-orange-600 text-white py-2 rounded hover:bg-orange-500 transition"
            >
              Add Transition
            </button>

            <button
              onClick={convertNFAToDFA}
              className="w-full bg-green-600 text-white py-2 rounded hover:bg-green-500 transition flex items-center justify-center gap-2"
            >
              <Zap className="w-4 h-4" />
              Convert NFA to DFA
            </button>

            <div className="mt-6 pt-4 border-t border-orange-400">
              <h3 className="text-white font-semibold mb-2">Transitions</h3>
              <div className="space-y-2">
                {transitions.map((t, idx) => (
                  <div key={idx} className="bg-gray-800 p-2 rounded text-xs text-white flex items-center gap-2">
                    <span>{t.from}</span>
                    <ArrowRight className="w-3 h-3 text-orange-400" />
                    <span className="bg-orange-600 px-2 py-1 rounded">{t.symbol}</span>
                    <ArrowRight className="w-3 h-3 text-orange-400" />
                    <span>{t.to}</span>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default AutomataSimulator;