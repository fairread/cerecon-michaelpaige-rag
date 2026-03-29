import React, { useState } from 'react';

type Message = { role: 'user' | 'assistant'; content: string };

function App() {
  const [messages, setMessages] = useState<Message[]>([
    { role: 'assistant', content: 'Welcome to the Enterprise RAG Copilot. How can I assist you with your project data today?' }
  ]);
  const [input, setInput] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const sendMessage = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!input.trim()) return;

    const userMessage: Message = { role: 'user', content: input };
    setMessages(prev => [...prev, userMessage]);
    setInput('');
    setIsLoading(true);

    try {
      const response = await fetch('http://localhost:8000/api/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ message: userMessage.content })
      });

      const data = await response.json();
      setMessages(prev => [...prev, { role: data.role, content: data.content }]);
    } catch (err) {
      setMessages(prev => [...prev, {
        role: 'assistant',
        content: '🚨 **Network Error:** Unable to reach the FastAPI backend container. Please ensure `docker-compose up` is actively running.'
      }]);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', height: '100vh', backgroundColor: '#1e1e1e', color: '#ececec', fontFamily: 'system-ui, sans-serif' }}>
      {/* Header */}
      <header style={{ padding: '20px', backgroundColor: '#2d2d2d', borderBottom: '1px solid #444', textAlign: 'center', fontWeight: 'bold', fontSize: '1.2rem', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>Enterprise RAG Copilot</div>
        <div style={{ fontSize: '0.8rem', backgroundColor: '#0078D4', padding: '4px 10px', borderRadius: '4px' }}>Assessment Mode</div>
      </header>

      {/* Chat History */}
      <div style={{ flex: 1, overflowY: 'auto', padding: '20px', display: 'flex', flexDirection: 'column', gap: '15px' }}>
        {messages.map((msg, idx) => (
          <div key={idx} style={{ alignSelf: msg.role === 'user' ? 'flex-end' : 'flex-start', maxWidth: '75%' }}>
            <div style={{
              padding: '12px 18px',
              borderRadius: '8px',
              backgroundColor: msg.role === 'user' ? '#0078D4' : '#333333',
              color: '#fff',
              lineHeight: '1.5',
              boxShadow: '0 4px 6px rgba(0,0,0,0.1)'
            }}>
              {msg.content}
            </div>
            <div style={{ fontSize: '0.8rem', color: '#888', marginTop: '6px', textAlign: msg.role === 'user' ? 'right' : 'left' }}>
              {msg.role === 'user' ? 'You' : 'AI Assistant'}
            </div>
          </div>
        ))}
        {isLoading && (
          <div style={{ alignSelf: 'flex-start', color: '#888', fontStyle: 'italic', paddingLeft: '10px' }}>Thinking...</div>
        )}
      </div>

      {/* Input Form */}
      <div style={{ padding: '20px', backgroundColor: '#2d2d2d', borderTop: '1px solid #444' }}>
        <form onSubmit={sendMessage} style={{ display: 'flex', gap: '10px', maxWidth: '800px', margin: '0 auto' }}>
          <input
            type="text"
            value={input}
            onChange={(e) => setInput(e.target.value)}
            placeholder="Ask a question about your enterprise data..."
            style={{ flex: 1, padding: '14px', borderRadius: '6px', border: '1px solid #555', backgroundColor: '#1e1e1e', color: '#fff', outline: 'none', fontSize: '1rem' }}
          />
          <button
            type="submit"
            disabled={isLoading}
            style={{ padding: '14px 28px', borderRadius: '6px', border: 'none', backgroundColor: '#0078D4', color: '#fff', cursor: isLoading ? 'not-allowed' : 'pointer', fontWeight: 'bold', fontSize: '1rem', transition: 'background 0.2s' }}>
            Send
          </button>
        </form>
      </div>
    </div>
  );
}

export default App;
