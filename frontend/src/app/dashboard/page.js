"use client";

import React, { useEffect, useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { getUser, logout } from '../../utils/auth';
import apiClient from '../../utils/apiClient';

export default function DashboardPage() {
  const router = useRouter();
  const [user, setUser] = useState(null);
  const [history, setHistory] = useState([]);
  const [stats, setStats] = useState(null);
  const [scoreHistory, setScoreHistory] = useState([]);
  const [partAccuracy, setPartAccuracy] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const init = async () => {
      const currentUser = getUser();
      if (!currentUser) {
        router.push('/login');
        return;
      }
      setUser(currentUser);

      try {
        const [histRes, statsRes, scoreHistRes, partAccRes] = await Promise.all([
          apiClient.get('/analytics/history'),
          apiClient.get('/analytics/stats'),
          apiClient.get('/analytics/score-history'),
          apiClient.get('/analytics/part-accuracy'),
        ]);
        const histData = Array.isArray(histRes.data) ? histRes.data : (histRes.data?.content || []);
        const scoreHistData = Array.isArray(scoreHistRes.data) ? scoreHistRes.data : (scoreHistRes.data?.content || []);

        setHistory(histData);
        setStats(statsRes.data);
        setScoreHistory(scoreHistData.slice(0, 20).reverse());
        setPartAccuracy(partAccRes.data);
      } catch (err) {
        console.error("Error fetching dashboard data", err);
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

  if (!user || loading) return null;

  // ── Chart helpers ──
  const chartWidth = 600;
  const chartHeight = 160;
  const chartPad = { top: 16, right: 16, bottom: 32, left: 40 };

  const buildLineChart = () => {
    if (scoreHistory.length < 2) return null;
    const vals = scoreHistory.map(s => s.accuracy);
    const minV = Math.min(...vals);
    const maxV = Math.max(...vals);
    const range = maxV - minV || 10;

    const scaleX = i => chartPad.left + (i / (vals.length - 1)) * (chartWidth - chartPad.left - chartPad.right);
    const scaleY = v => chartPad.top + (1 - (v - minV) / range) * (chartHeight - chartPad.top - chartPad.bottom);

    const points = vals.map((v, i) => `${scaleX(i)},${scaleY(v)}`).join(' ');
    const areaPoints = `${scaleX(0)},${chartHeight - chartPad.bottom} ${points} ${scaleX(vals.length - 1)},${chartHeight - chartPad.bottom}`;

    return { points, areaPoints, scaleX, scaleY, vals, minV, maxV };
  };

  const chart = buildLineChart();

  const PART_COLORS = ['#3b82f6', '#8b5cf6', '#10b981', '#f59e0b', '#ef4444', '#ec4899', '#06b6d4'];
  const PART_NAMES = ['Part 1\nPhotos', 'Part 2\nQ-Response', 'Part 3\nConversation', 'Part 4\nShort Talks', 'Part 5\nIncomplete', 'Part 6\nText Compl.', 'Part 7\nPassages'];

  return (
    <div style={{ minHeight: '100vh', background: 'var(--bg-main)', color: 'var(--text-main)', fontFamily: 'var(--font-body)' }}>

      {/* Header */}
      <header style={{ maxWidth: '1200px', margin: '0 auto', padding: '1.5rem 24px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderBottom: '1px solid var(--border)' }}>
        <div style={{ fontFamily: 'var(--font-heading)', fontSize: '1.5rem', fontWeight: 800 }}>
          <span style={{ background: 'linear-gradient(135deg,#60a5fa,#a78bfa)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>TOEIC</span> Master
        </div>
        <nav style={{ display: 'flex', gap: '1.5rem', alignItems: 'center' }}>
          <span style={{ fontWeight: 600, color: 'var(--primary)' }}>Hi, {user.name}</span>
          <Link href="/tests" style={{ color: 'var(--text-muted)', fontWeight: 500, textDecoration: 'none' }}>Practice</Link>
          <Link href="/history" style={{ color: 'var(--text-muted)', fontWeight: 500, textDecoration: 'none' }}>History</Link>
          <Link href="/review" style={{ color: 'var(--text-muted)', fontWeight: 500, textDecoration: 'none' }}>Review</Link>
          <button onClick={handleLogout} style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer', fontFamily: 'inherit', fontSize: '1rem', fontWeight: 500 }}>Logout</button>
        </nav>
      </header>

      <main style={{ maxWidth: '1200px', margin: '0 auto', padding: '2rem 24px 4rem' }}>

        {/* Page title */}
        <div style={{ marginBottom: '2.5rem' }}>
          <h1 style={{ fontFamily: 'var(--font-heading)', fontSize: '2.5rem', fontWeight: 800, marginBottom: '0.25rem' }}>
            Your <span style={{ background: 'linear-gradient(135deg,#60a5fa,#a78bfa)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>Dashboard</span>
          </h1>
          <p style={{ color: 'var(--text-muted)' }}>Track your progress and identify areas to improve.</p>
        </div>

        {/* Stats cards */}
        {stats && (
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))', gap: '1rem', marginBottom: '2rem' }}>
            {[
              { label: 'Total Attempts', value: stats.totalAttempts, icon: '📋', color: '#3b82f6', sub: `${stats.totalFullTests} full · ${stats.totalPartPractices} part` },
              { label: 'Avg Accuracy', value: `${stats.averageAccuracy ?? 0}%`, icon: '🎯', color: '#10b981', sub: 'of answered questions' },
              { label: 'Best Score', value: stats.bestScore ?? 0, icon: '🏆', color: '#f59e0b', sub: 'correct answers' },
              { label: 'Study Streak', value: `${stats.currentStreak ?? 0}d`, icon: '🔥', color: '#ef4444', sub: 'consecutive days' },
            ].map(card => (
              <div key={card.label} style={{
                background: 'var(--bg-panel)', border: '1px solid var(--border)', borderRadius: 'var(--radius-lg)',
                padding: '1.25rem', backdropFilter: 'blur(16px)', position: 'relative', overflow: 'hidden'
              }}>
                <div style={{ position: 'absolute', top: 0, left: 0, right: 0, height: '3px', background: card.color, opacity: 0.7 }}></div>
                <div style={{ fontSize: '1.5rem', marginBottom: '0.5rem' }}>{card.icon}</div>
                <div style={{ fontSize: '2rem', fontWeight: 800, color: card.color, lineHeight: 1, marginBottom: '0.25rem' }}>{card.value}</div>
                <div style={{ fontWeight: 600, fontSize: '0.875rem', marginBottom: '0.25rem' }}>{card.label}</div>
                <div style={{ color: 'var(--text-muted)', fontSize: '0.75rem' }}>{card.sub}</div>
              </div>
            ))}
          </div>
        )}

        {/* Quick actions */}
        <div style={{ display: 'flex', gap: '0.75rem', marginBottom: '2rem', flexWrap: 'wrap' }}>
          {[
            { href: '/tests', label: '🎯 Start Practice', primary: true },
            { href: '/review', label: '❌ Review Mistakes' },
            { href: '/review#bookmarks', label: '🔖 My Bookmarks' },
          ].map(btn => (
            <Link
              key={btn.href}
              href={btn.href}
              style={{
                display: 'inline-block', padding: '0.625rem 1.25rem',
                background: btn.primary ? 'var(--primary)' : 'rgba(255,255,255,0.05)',
                border: `1px solid ${btn.primary ? 'var(--primary)' : 'var(--border)'}`,
                borderRadius: '10px', color: 'white', fontWeight: 600, fontSize: '0.875rem',
                textDecoration: 'none', transition: 'all 0.2s',
                boxShadow: btn.primary ? '0 4px 14px rgba(59,130,246,0.3)' : 'none',
              }}
            >
              {btn.label}
            </Link>
          ))}
        </div>

        {/* Charts row */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1.5rem', marginBottom: '2rem' }}>

          {/* Score History Line Chart */}
          <div style={{ background: 'var(--bg-panel)', border: '1px solid var(--border)', borderRadius: 'var(--radius-lg)', padding: '1.5rem', backdropFilter: 'blur(16px)' }}>
            <h3 style={{ fontFamily: 'var(--font-heading)', marginBottom: '0.25rem', fontSize: '1.1rem' }}>Accuracy Over Time</h3>
            <p style={{ color: 'var(--text-muted)', fontSize: '0.8rem', marginBottom: '1rem' }}>Last {scoreHistory.length} attempts</p>

            {chart ? (
              <svg width="100%" viewBox={`0 0 ${chartWidth} ${chartHeight}`} style={{ overflow: 'visible' }}>
                {/* Grid lines */}
                {[0, 25, 50, 75, 100].map(pct => {
                  const y = chartPad.top + (1 - pct / 100) * (chartHeight - chartPad.top - chartPad.bottom);
                  return (
                    <g key={pct}>
                      <line x1={chartPad.left} y1={y} x2={chartWidth - chartPad.right} y2={y} stroke="rgba(255,255,255,0.05)" strokeWidth="1" />
                      <text x={chartPad.left - 4} y={y + 4} textAnchor="end" fill="#94a3b8" fontSize="10">{pct}%</text>
                    </g>
                  );
                })}

                {/* Area fill */}
                <polygon points={chart.areaPoints} fill="url(#areaGrad)" />
                <defs>
                  <linearGradient id="areaGrad" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stopColor="#3b82f6" stopOpacity="0.3" />
                    <stop offset="100%" stopColor="#3b82f6" stopOpacity="0" />
                  </linearGradient>
                </defs>

                {/* Line */}
                <polyline points={chart.points} fill="none" stroke="#3b82f6" strokeWidth="2.5" strokeLinejoin="round" strokeLinecap="round" />

                {/* Data points */}
                {chart.vals.map((v, i) => (
                  <circle key={i} cx={chart.scaleX(i)} cy={chart.scaleY(v)} r="4" fill="#3b82f6" stroke="white" strokeWidth="2">
                    <title>{`${scoreHistory[i]?.testTitle}: ${v}%`}</title>
                  </circle>
                ))}
              </svg>
            ) : (
              <div style={{ textAlign: 'center', color: 'var(--text-muted)', padding: '2rem' }}>
                <div style={{ fontSize: '2rem', marginBottom: '0.5rem' }}>📊</div>
                <p style={{ fontSize: '0.875rem' }}>Complete at least 2 tests to see your progress chart.</p>
              </div>
            )}
          </div>

          {/* Part Accuracy Bar Chart */}
          <div style={{ background: 'var(--bg-panel)', border: '1px solid var(--border)', borderRadius: 'var(--radius-lg)', padding: '1.5rem', backdropFilter: 'blur(16px)' }}>
            <h3 style={{ fontFamily: 'var(--font-heading)', marginBottom: '0.25rem', fontSize: '1.1rem' }}>Accuracy by Part</h3>
            <p style={{ color: 'var(--text-muted)', fontSize: '0.8rem', marginBottom: '1rem' }}>Your strengths and weaknesses</p>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
              {partAccuracy.map((p, i) => {
                const acc = p.accuracy || 0;
                const barColor = acc >= 70 ? '#10b981' : acc >= 40 ? '#f59e0b' : '#ef4444';
                return (
                  <div key={p.partNumber} style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                    <div style={{ width: '50px', fontSize: '0.75rem', fontWeight: 700, color: PART_COLORS[i] || '#666', flexShrink: 0 }}>P{p.partNumber}</div>
                    <div style={{ flex: 1, background: 'rgba(255,255,255,0.05)', borderRadius: '4px', height: '18px', overflow: 'hidden' }}>
                      <div style={{
                        width: `${acc}%`, height: '100%', borderRadius: '4px',
                        background: `linear-gradient(90deg, ${barColor}bb, ${barColor})`,
                        transition: 'width 0.6s ease',
                        display: 'flex', alignItems: 'center', justifyContent: 'flex-end', paddingRight: '4px'
                      }}>
                        {acc >= 20 && <span style={{ fontSize: '0.65rem', fontWeight: 700, color: 'white' }}>{acc}%</span>}
                      </div>
                    </div>
                    <div style={{ width: '45px', fontSize: '0.7rem', color: 'var(--text-muted)', textAlign: 'right', flexShrink: 0 }}>
                      {p.totalAnswered > 0 ? `${p.totalCorrect}/${p.totalAnswered}` : 'N/A'}
                    </div>
                  </div>
                );
              })}
            </div>

            {partAccuracy.every(p => p.totalAnswered === 0) && (
              <div style={{ textAlign: 'center', color: 'var(--text-muted)', padding: '2rem' }}>
                <div style={{ fontSize: '2rem', marginBottom: '0.5rem' }}>📈</div>
                <p style={{ fontSize: '0.875rem' }}>Complete tests to see your accuracy by part.</p>
              </div>
            )}
          </div>
        </div>

        {/* Recent History Table */}
        <div style={{ background: 'var(--bg-panel)', border: '1px solid var(--border)', borderRadius: 'var(--radius-lg)', padding: '1.5rem', backdropFilter: 'blur(16px)' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.25rem' }}>
            <h3 style={{ fontFamily: 'var(--font-heading)', fontSize: '1.1rem', margin: 0 }}>Recent Attempts</h3>
            <Link href="/history" style={{
              fontSize: '0.8rem', color: '#60a5fa', fontWeight: 600, textDecoration: 'none',
              padding: '0.3rem 0.75rem', borderRadius: '8px',
              border: '1px solid rgba(96,165,250,0.3)', background: 'rgba(96,165,250,0.08)',
              transition: 'background 0.15s',
            }}>Xem toàn bộ lịch sử →</Link>
          </div>

          {history.length > 0 ? (
            <div style={{ overflowX: 'auto' }}>
              <table style={{ width: '100%', borderCollapse: 'separate', borderSpacing: 0, textAlign: 'left' }}>
                <thead>
                  <tr>
                    {['Test', 'Type', 'Date', 'Duration', 'Correct', 'Accuracy', 'Action'].map(h => (
                      <th key={h} style={{ padding: '0.75rem 1rem', color: 'var(--text-muted)', fontWeight: 600, textTransform: 'uppercase', fontSize: '0.7rem', letterSpacing: '0.05em', borderBottom: '1px solid var(--border)' }}>{h}</th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {history.map(attempt => {
                    const dur = attempt.durationSeconds
                      ? `${Math.floor(attempt.durationSeconds / 60)}m ${attempt.durationSeconds % 60}s`
                      : '—';
                    const acc = attempt.totalCorrect != null && attempt.totalCorrect + (attempt.totalIncorrect || 0) > 0
                      ? Math.round(attempt.totalCorrect / (attempt.totalCorrect + (attempt.totalIncorrect || 0)) * 100)
                      : null;
                    return (
                      <tr key={attempt.id}
                        onClick={() => router.push(`/test/${attempt.testId || 1}?attemptId=${attempt.id}`)}
                        style={{ cursor: 'pointer', transition: 'background 0.15s' }}
                        onMouseOver={e => e.currentTarget.style.background = 'rgba(255,255,255,0.06)'}
                        onMouseOut={e => e.currentTarget.style.background = 'transparent'}>
                        <td style={{ padding: '0.75rem 1rem', borderBottom: '1px solid rgba(255,255,255,0.05)', fontWeight: 500 }}>{attempt.testTitle}</td>
                        <td style={{ padding: '0.75rem 1rem', borderBottom: '1px solid rgba(255,255,255,0.05)' }}>
                          <span style={{
                            padding: '2px 8px', borderRadius: '9999px', fontSize: '0.7rem', fontWeight: 700,
                            background: attempt.attemptType === 'FULL' ? 'rgba(59,130,246,0.2)' : 'rgba(139,92,246,0.2)',
                            color: attempt.attemptType === 'FULL' ? '#60a5fa' : '#a78bfa'
                          }}>
                            {attempt.attemptType}
                          </span>
                        </td>
                        <td style={{ padding: '0.75rem 1rem', borderBottom: '1px solid rgba(255,255,255,0.05)', color: 'var(--text-muted)', fontSize: '0.875rem' }}>
                          {new Date(attempt.startedAt).toLocaleDateString('vi-VN')}
                        </td>
                        <td style={{ padding: '0.75rem 1rem', borderBottom: '1px solid rgba(255,255,255,0.05)', color: 'var(--text-muted)', fontSize: '0.875rem' }}>{dur}</td>
                        <td style={{ padding: '0.75rem 1rem', borderBottom: '1px solid rgba(255,255,255,0.05)' }}>
                          <span style={{ padding: '2px 8px', borderRadius: '4px', background: 'rgba(16,185,129,0.15)', color: '#34d399', fontWeight: 700, fontSize: '0.875rem' }}>
                            {attempt.totalCorrect ?? '—'}
                          </span>
                        </td>
                        <td style={{ padding: '0.75rem 1rem', borderBottom: '1px solid rgba(255,255,255,0.05)', fontWeight: 600 }}>
                          {acc != null ? (
                            <span style={{ color: acc >= 70 ? '#4ade80' : acc >= 40 ? '#fbbf24' : '#f87171' }}>{acc}%</span>
                          ) : '—'}
                        </td>
                        <td style={{ padding: '0.75rem 1rem', borderBottom: '1px solid rgba(255,255,255,0.05)' }}>
                          <span style={{ color: '#60a5fa', fontSize: '0.85rem', fontWeight: 600 }}>Xem lại ➔</span>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          ) : (
            <div style={{ textAlign: 'center', padding: '3rem', color: 'var(--text-muted)' }}>
              <div style={{ fontSize: '3rem', marginBottom: '1rem' }}>📝</div>
              <p style={{ marginBottom: '1.5rem' }}>You haven&apos;t taken any tests yet.</p>
              <Link href="/tests" style={{ display: 'inline-block', padding: '0.75rem 2rem', background: 'var(--primary)', borderRadius: '10px', color: 'white', fontWeight: 600, textDecoration: 'none' }}>
                Start Practicing
              </Link>
            </div>
          )}
        </div>
      </main>
    </div>
  );
}
