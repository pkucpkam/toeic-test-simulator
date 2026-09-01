"use client";

import React, { useEffect, useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { getUser, logout } from '../../utils/auth';
import { ExplanationView } from '../../components/QuestionViews';
import '../globals.css';

export default function ReviewPage() {
  const router = useRouter();
  const [user, setUser] = useState(null);
  const [activeTab, setActiveTab] = useState('incorrect'); // 'incorrect' | 'bookmarks'

  const [incorrectQuestions, setIncorrectQuestions] = useState([]);
  const [bookmarks, setBookmarks] = useState([]);
  const [loading, setLoading] = useState(true);

  const [expandedIds, setExpandedIds] = useState({});
  const [filterPart, setFilterPart] = useState('all');

  useEffect(() => {
    const init = async () => {
      const currentUser = getUser();
      if (!currentUser) {
        router.push('/login');
        return;
      }
      setUser(currentUser);

      try {
        const [incorrectRes, bookmarkRes] = await Promise.all([
          apiClient.get('/review/incorrect'),
          apiClient.get('/review/bookmarks').catch(() => ({ data: [] })),
        ]);
        setIncorrectQuestions(incorrectRes.data || []);
        setBookmarks(bookmarkRes.data || []);
      } catch (err) {
        console.error("Error fetching review data", err);
      } finally {
        setLoading(false);
      }
    };
    init();
  }, [router]);

  const handleLogout = () => {
    logout();
    router.push('/login');
  };

  const toggleExpand = (id) => {
    setExpandedIds(prev => ({ ...prev, [id]: !prev[id] }));
  };

  const handleRemoveBookmark = async (questionId) => {
    try {
      await apiClient.post('/review/bookmarks', { questionId });
      setBookmarks(prev => prev.filter(b => b.question.id !== questionId));
    } catch (err) {
      console.error("Error removing bookmark", err);
    }
  };

  if (!user || loading) return null;

  const OPTION_LABELS = ['A', 'B', 'C', 'D'];

  const renderQuestion = (item, idx, isBookmark = false) => {
    const q = item.question;
    const isExpanded = expandedIds[item.id];
    const options = [
      { label: 'A', text: q.optionA },
      { label: 'B', text: q.optionB },
      { label: 'C', text: q.optionC },
      { label: 'D', text: q.optionD },
    ].filter(o => o.text);

    return (
      <div
        key={item.id}
        style={{
          background: 'var(--bg-card)', border: '1px solid var(--border)',
          borderRadius: 'var(--radius-md)', overflow: 'hidden',
          transition: 'border-color 0.2s',
        }}
      >
        {/* Question header */}
        <div
          style={{ padding: '1rem 1.25rem', cursor: 'pointer', display: 'flex', alignItems: 'flex-start', gap: '1rem' }}
          onClick={() => toggleExpand(item.id)}
        >
          <div style={{
            width: '32px', height: '32px', borderRadius: '50%', flexShrink: 0,
            background: 'rgba(239,68,68,0.15)', border: '1px solid rgba(239,68,68,0.3)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            color: '#ef4444', fontWeight: 700, fontSize: '0.875rem'
          }}>
            {idx + 1}
          </div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ display: 'flex', gap: '0.5rem', alignItems: 'center', marginBottom: '0.25rem', flexWrap: 'wrap' }}>
              <span style={{
                padding: '2px 8px', borderRadius: '9999px', fontSize: '0.7rem', fontWeight: 700,
                background: 'rgba(59,130,246,0.15)', color: '#60a5fa'
              }}>Q{q.questionNumber}</span>
              <span style={{ color: 'var(--text-muted)', fontSize: '0.8rem' }}>
                Correct answer: <strong style={{ color: '#4ade80' }}>({q.correctAnswer})</strong>
              </span>
            </div>
            <p style={{ color: 'var(--text-main)', fontSize: '0.9rem', margin: 0 }}>
              {q.questionText || `Question ${q.questionNumber}`}
            </p>
          </div>
          <span style={{ color: 'var(--text-muted)', flexShrink: 0, marginTop: '4px' }}>
            {isExpanded ? '▲' : '▼'}
          </span>
        </div>

        {/* Expanded content */}
        {isExpanded && (
          <div style={{ padding: '0 1.25rem 1.25rem', borderTop: '1px solid var(--border)' }}>
            {/* Options */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem', marginTop: '1rem' }}>
              {options.map(opt => {
                const isCorrect = q.correctAnswer === opt.label;
                return (
                  <div key={opt.label} style={{
                    padding: '0.5rem 0.875rem', borderRadius: '6px',
                    background: isCorrect ? 'rgba(74,222,128,0.1)' : 'rgba(255,255,255,0.03)',
                    border: `1px solid ${isCorrect ? 'rgba(74,222,128,0.4)' : 'var(--border)'}`,
                    display: 'flex', alignItems: 'center', gap: '0.75rem', fontSize: '0.875rem'
                  }}>
                    <span style={{
                      width: '24px', height: '24px', borderRadius: '50%', flexShrink: 0,
                      background: isCorrect ? 'rgba(74,222,128,0.2)' : 'rgba(255,255,255,0.05)',
                      border: `1px solid ${isCorrect ? '#4ade80' : 'var(--border)'}`,
                      display: 'flex', alignItems: 'center', justifyContent: 'center',
                      fontWeight: 700, fontSize: '0.8rem', color: isCorrect ? '#4ade80' : 'var(--text-muted)'
                    }}>
                      {opt.label}
                    </span>
                    <span style={{ color: isCorrect ? 'var(--text-main)' : 'var(--text-muted)', fontWeight: isCorrect ? 600 : 400 }}>
                      {opt.text}
                    </span>
                    {isCorrect && <span style={{ marginLeft: 'auto', color: '#4ade80', fontWeight: 700 }}>✓ Correct</span>}
                  </div>
                );
              })}
            </div>

            {/* Explanation */}
            {q.explanation && (
              <ExplanationView explanation={q.explanation} />
            )}

            {/* Remove bookmark button */}
            {isBookmark && (
              <button
                onClick={() => handleRemoveBookmark(q.id)}
                style={{
                  marginTop: '0.75rem', background: 'none', border: '1px solid var(--border)',
                  color: 'var(--text-muted)', padding: '0.375rem 0.875rem', borderRadius: '6px',
                  cursor: 'pointer', fontSize: '0.8rem', transition: 'all 0.2s'
                }}
              >
                🗑 Remove Bookmark
              </button>
            )}
          </div>
        )}
      </div>
    );
  };

  const currentItems = activeTab === 'incorrect' ? incorrectQuestions : bookmarks;
  const filteredItems = filterPart === 'all'
    ? currentItems
    : currentItems.filter(item => item.question?.questionNumber % 7 === parseInt(filterPart) % 7);

  return (
    <div className="premium-container">
      <header className="premium-header">
        <div className="header-brand"><span className="gradient-text">TOEIC</span> Master</div>
        <nav className="header-nav">
          <span className="user-greeting">Hi, {user.name}</span>
          <Link href="/dashboard" className="nav-item">Dashboard</Link>
          <Link href="/tests" className="nav-item">Practice</Link>
          <button onClick={handleLogout} className="nav-item btn-logout">Logout</button>
        </nav>
      </header>

      <main className="premium-main">
        <div className="glass-panel text-center mb-12">
          <h1 className="text-4xl font-extrabold gradient-text">Review & Study</h1>
          <p className="subtitle">Go over your mistakes and bookmarked questions to improve.</p>
        </div>

        {/* Tabs */}
        <div style={{ display: 'flex', gap: '0', marginBottom: '2rem', borderRadius: 'var(--radius-md)', overflow: 'hidden', border: '1px solid var(--border)' }}>
          {[
            { key: 'incorrect', label: `❌ Incorrect (${incorrectQuestions.length})` },
            { key: 'bookmarks', label: `🔖 Bookmarks (${bookmarks.length})` },
          ].map(tab => (
            <button
              key={tab.key}
              onClick={() => { setActiveTab(tab.key); setFilterPart('all'); }}
              style={{
                flex: 1, padding: '0.875rem', border: 'none', cursor: 'pointer',
                background: activeTab === tab.key
                  ? 'linear-gradient(135deg, var(--primary), var(--secondary))'
                  : 'transparent',
                color: activeTab === tab.key ? 'white' : 'var(--text-muted)',
                fontWeight: 600, fontSize: '0.95rem', transition: 'all 0.2s',
                fontFamily: 'inherit',
              }}
            >
              {tab.label}
            </button>
          ))}
        </div>

        {/* Content */}
        {currentItems.length === 0 ? (
          <div className="glass-panel text-center" style={{ padding: '4rem' }}>
            <div style={{ fontSize: '3rem', marginBottom: '1rem' }}>{activeTab === 'incorrect' ? '🎉' : '🔖'}</div>
            <p style={{ fontSize: '1.1rem', color: 'var(--text-main)', marginBottom: '0.5rem' }}>
              {activeTab === 'incorrect' ? 'No incorrect questions yet!' : 'No bookmarks yet!'}
            </p>
            <p style={{ color: 'var(--text-muted)', marginBottom: '1.5rem' }}>
              {activeTab === 'incorrect'
                ? 'Start practicing and your mistakes will appear here.'
                : 'Bookmark questions during practice to review them later.'}
            </p>
            <Link href="/tests" className="premium-btn btn-primary">Start Practicing</Link>
          </div>
        ) : (
          <>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem' }}>
              <span style={{ color: 'var(--text-muted)', fontSize: '0.875rem' }}>
                {currentItems.length} question{currentItems.length !== 1 ? 's' : ''}
              </span>
              <button
                onClick={() => {
                  const allIds = {};
                  currentItems.forEach(item => { allIds[item.id] = true; });
                  setExpandedIds(prev => {
                    const allExpanded = currentItems.every(item => prev[item.id]);
                    if (allExpanded) return {};
                    return allIds;
                  });
                }}
                style={{
                  background: 'none', border: '1px solid var(--border)', color: 'var(--text-muted)',
                  padding: '0.375rem 0.875rem', borderRadius: '6px', cursor: 'pointer',
                  fontSize: '0.8rem', transition: 'all 0.2s'
                }}
              >
                {currentItems.every(item => expandedIds[item.id]) ? 'Collapse All' : 'Expand All'}
              </button>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
              {currentItems.map((item, idx) =>
                renderQuestion(item, idx, activeTab === 'bookmarks')
              )}
            </div>
          </>
        )}
      </main>
    </div>
  );
}
