"use client";

import React, { useEffect, useState, useCallback } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { getUser, logout } from '../../utils/auth';
import apiClient from '../../utils/apiClient';

// ── Constants ─────────────────────────────────────────────────────────────────
const PART_COLORS = ['#3b82f6', '#8b5cf6', '#10b981', '#f59e0b', '#ef4444', '#ec4899', '#06b6d4'];
const PART_NAMES = ['Photos', 'Q-Response', 'Conversation', 'Short Talks', 'Incomplete', 'Text Compl.', 'Passages'];
const PART_ICONS = ['🖼️', '💬', '🗣️', '📢', '✏️', '📝', '📖'];

function accColor(acc) {
  if (acc >= 70) return '#4ade80';
  if (acc >= 40) return '#fbbf24';
  return '#f87171';
}

// ── Mini chart (line trend) ───────────────────────────────────────────────────
function TrendChart({ data, width = 500, height = 130 }) {
  if (!data || data.length < 2) {
    return (
      <div style={{ textAlign: 'center', color: 'var(--text-muted)', padding: '2rem 0' }}>
        <div style={{ fontSize: '2rem', marginBottom: '0.5rem' }}>📊</div>
        <p style={{ fontSize: '0.85rem' }}>Cần ít nhất 2 lần luyện để hiện biểu đồ.</p>
      </div>
    );
  }
  const pad = { top: 16, right: 16, bottom: 32, left: 40 };
  const vals = data.map(d => d.accuracy);
  const minV = Math.min(...vals);
  const maxV = Math.max(...vals);
  const range = maxV - minV || 10;
  const sx = i => pad.left + (i / (vals.length - 1)) * (width - pad.left - pad.right);
  const sy = v => pad.top + (1 - (v - minV) / range) * (height - pad.top - pad.bottom);
  const points = vals.map((v, i) => `${sx(i)},${sy(v)}`).join(' ');
  const area = `${sx(0)},${height - pad.bottom} ${points} ${sx(vals.length - 1)},${height - pad.bottom}`;

  return (
    <svg width="100%" viewBox={`0 0 ${width} ${height}`} style={{ overflow: 'visible' }}>
      {[0, 25, 50, 75, 100].map(pct => {
        const y = pad.top + (1 - pct / 100) * (height - pad.top - pad.bottom);
        return (
          <g key={pct}>
            <line x1={pad.left} y1={y} x2={width - pad.right} y2={y} stroke="rgba(255,255,255,0.06)" strokeWidth="1" />
            <text x={pad.left - 5} y={y + 4} textAnchor="end" fill="#64748b" fontSize="10">{pct}%</text>
          </g>
        );
      })}
      <defs>
        <linearGradient id="trendGrad" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor="#60a5fa" stopOpacity="0.35" />
          <stop offset="100%" stopColor="#60a5fa" stopOpacity="0" />
        </linearGradient>
      </defs>
      <polygon points={area} fill="url(#trendGrad)" />
      <polyline points={points} fill="none" stroke="#60a5fa" strokeWidth="2.5" strokeLinejoin="round" strokeLinecap="round" />
      {vals.map((v, i) => (
        <circle key={i} cx={sx(i)} cy={sy(v)} r="4" fill={accColor(v)} stroke="white" strokeWidth="2">
          <title>{`Lần ${i + 1}: ${v}%`}</title>
        </circle>
      ))}
    </svg>
  );
}

// ── Part accuracy bar ─────────────────────────────────────────────────────────
function PartBar({ p, index, onClick, clickable }) {
  const acc = p.accuracy || 0;
  const barColor = acc >= 70 ? '#10b981' : acc >= 40 ? '#f59e0b' : '#ef4444';
  return (
    <div
      onClick={onClick}
      style={{
        display: 'flex', alignItems: 'center', gap: '0.6rem',
        padding: '0.4rem 0.5rem', borderRadius: '8px',
        cursor: clickable ? 'pointer' : 'default',
        transition: 'background 0.15s',
      }}
      onMouseOver={e => { if (clickable) e.currentTarget.style.background = 'rgba(255,255,255,0.06)'; }}
      onMouseOut={e => { e.currentTarget.style.background = 'transparent'; }}
    >
      <div style={{ width: '24px', fontSize: '0.8rem', flexShrink: 0 }}>{PART_ICONS[index]}</div>
      <div style={{ width: '60px', fontSize: '0.72rem', fontWeight: 700, color: PART_COLORS[index], flexShrink: 0 }}>
        P{p.partNumber}
      </div>
      <div style={{ flex: 1, background: 'rgba(255,255,255,0.07)', borderRadius: '4px', height: '18px', overflow: 'hidden' }}>
        <div style={{
          width: `${acc}%`, height: '100%', borderRadius: '4px',
          background: `linear-gradient(90deg,${barColor}bb,${barColor})`,
          transition: 'width 0.6s ease',
          display: 'flex', alignItems: 'center', justifyContent: 'flex-end', paddingRight: '4px',
        }}>
          {acc >= 20 && <span style={{ fontSize: '0.65rem', fontWeight: 700, color: 'white' }}>{acc}%</span>}
        </div>
      </div>
      <div style={{ width: '50px', fontSize: '0.7rem', color: 'var(--text-muted)', textAlign: 'right', flexShrink: 0 }}>
        {p.totalAnswered > 0 ? `${p.totalCorrect}/${p.totalAnswered}` : 'N/A'}
      </div>
      {clickable && <div style={{ fontSize: '0.7rem', color: '#60a5fa', flexShrink: 0 }}>→</div>}
    </div>
  );
}

// ── Stat card ─────────────────────────────────────────────────────────────────
function StatCard({ icon, label, value, sub, color }) {
  return (
    <div style={{
      background: 'var(--bg-panel)', border: '1px solid var(--border)', borderRadius: 'var(--radius-lg)',
      padding: '1.1rem 1.25rem', backdropFilter: 'blur(16px)', position: 'relative', overflow: 'hidden',
    }}>
      <div style={{ position: 'absolute', top: 0, left: 0, right: 0, height: '3px', background: color, opacity: 0.75 }} />
      <div style={{ fontSize: '1.3rem', marginBottom: '0.4rem' }}>{icon}</div>
      <div style={{ fontSize: '1.8rem', fontWeight: 800, color, lineHeight: 1, marginBottom: '0.2rem' }}>{value}</div>
      <div style={{ fontWeight: 600, fontSize: '0.82rem', marginBottom: '0.15rem' }}>{label}</div>
      {sub && <div style={{ color: 'var(--text-muted)', fontSize: '0.72rem' }}>{sub}</div>}
    </div>
  );
}

// ── Main Page ─────────────────────────────────────────────────────────────────
export default function DashboardPage() {
  const router = useRouter();
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  // Overview data
  const [history, setHistory] = useState([]);
  const [stats, setStats] = useState(null);
  const [scoreHistory, setScoreHistory] = useState([]);
  const [partAccuracy, setPartAccuracy] = useState([]);

  // By-Test data
  const [attemptedTests, setAttemptedTests] = useState([]);
  const [selectedTestId, setSelectedTestId] = useState(null);
  const [testAnalytics, setTestAnalytics] = useState(null);
  const [testAnalyticsLoading, setTestAnalyticsLoading] = useState(false);

  // Part detail
  const [selectedPart, setSelectedPart] = useState(null);
  const [partDetail, setPartDetail] = useState(null);
  const [partDetailLoading, setPartDetailLoading] = useState(false);

  // Tab: 'overview' | 'by-test'
  const [activeTab, setActiveTab] = useState('overview');

  useEffect(() => {
    const init = async () => {
      const currentUser = getUser();
      if (!currentUser) { router.push('/login'); return; }
      setUser(currentUser);

      try {
        const [histRes, statsRes, scoreHistRes, partAccRes, testsRes] = await Promise.all([
          apiClient.get('/analytics/history'),
          apiClient.get('/analytics/stats'),
          apiClient.get('/analytics/score-history'),
          apiClient.get('/analytics/part-accuracy'),
          apiClient.get('/analytics/tests'),
        ]);
        setHistory(Array.isArray(histRes.data) ? histRes.data : (histRes.data?.content || []));
        setStats(statsRes.data);
        const scoreHistData = Array.isArray(scoreHistRes.data) ? scoreHistRes.data : (scoreHistRes.data?.content || []);
        setScoreHistory(scoreHistData.slice(0, 20).reverse());
        setPartAccuracy(partAccRes.data);
        setAttemptedTests(Array.isArray(testsRes.data) ? testsRes.data : []);
      } catch (err) {
        console.error('Dashboard fetch error', err);
      } finally {
        setLoading(false);
      }
    };
    init();
  }, [router]);

  // Load test analytics khi chọn đề
  const loadTestAnalytics = useCallback(async (testId) => {
    setSelectedTestId(testId);
    setSelectedPart(null);
    setPartDetail(null);
    setTestAnalyticsLoading(true);
    try {
      const res = await apiClient.get(`/analytics/by-test/${testId}`);
      setTestAnalytics(res.data);
    } catch (err) {
      console.error('Test analytics fetch error', err);
    } finally {
      setTestAnalyticsLoading(false);
    }
  }, []);

  // Load part detail khi click vào part
  const loadPartDetail = useCallback(async (testId, partNumber) => {
    setSelectedPart(partNumber);
    setPartDetailLoading(true);
    try {
      const res = await apiClient.get(`/analytics/by-test/${testId}/part/${partNumber}`);
      setPartDetail(res.data);
    } catch (err) {
      console.error('Part detail fetch error', err);
    } finally {
      setPartDetailLoading(false);
    }
  }, []);

  const handleLogout = () => { logout(); router.push('/login'); };

  if (!user || loading) return null;

  // ── Overview chart ────────────────────────────────────────────────────────
  const chartW = 600, chartH = 160;
  const chartPad = { top: 16, right: 16, bottom: 32, left: 40 };
  const buildOverviewChart = () => {
    if (scoreHistory.length < 2) return null;
    const vals = scoreHistory.map(s => s.accuracy);
    const minV = Math.min(...vals), maxV = Math.max(...vals);
    const range = maxV - minV || 10;
    const sx = i => chartPad.left + (i / (vals.length - 1)) * (chartW - chartPad.left - chartPad.right);
    const sy = v => chartPad.top + (1 - (v - minV) / range) * (chartH - chartPad.top - chartPad.bottom);
    const points = vals.map((v, i) => `${sx(i)},${sy(v)}`).join(' ');
    const area = `${sx(0)},${chartH - chartPad.bottom} ${points} ${sx(vals.length - 1)},${chartH - chartPad.bottom}`;
    return { points, area, sx, sy, vals };
  };
  const overviewChart = buildOverviewChart();

  // ── Tab styles ────────────────────────────────────────────────────────────
  const tabStyle = (active) => ({
    padding: '0.5rem 1.25rem', borderRadius: '10px', fontWeight: 600, fontSize: '0.875rem',
    cursor: 'pointer', border: 'none', fontFamily: 'inherit', transition: 'all 0.2s',
    background: active ? 'var(--primary)' : 'rgba(255,255,255,0.06)',
    color: active ? 'white' : 'var(--text-muted)',
    boxShadow: active ? '0 4px 14px rgba(59,130,246,0.3)' : 'none',
  });

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
        <div style={{ marginBottom: '2rem' }}>
          <h1 style={{ fontFamily: 'var(--font-heading)', fontSize: '2.4rem', fontWeight: 800, marginBottom: '0.25rem' }}>
            Your <span style={{ background: 'linear-gradient(135deg,#60a5fa,#a78bfa)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>Dashboard</span>
          </h1>
          <p style={{ color: 'var(--text-muted)' }}>Theo dõi tiến độ và phân tích chi tiết theo từng đề, từng part.</p>
        </div>

        {/* Tabs */}
        <div style={{ display: 'flex', gap: '0.6rem', marginBottom: '2rem', flexWrap: 'wrap', alignItems: 'center' }}>
          <button id="tab-overview" style={tabStyle(activeTab === 'overview')} onClick={() => setActiveTab('overview')}>
            📊 Tổng quan
          </button>
          <button id="tab-by-test" style={tabStyle(activeTab === 'by-test')} onClick={() => setActiveTab('by-test')}>
            📋 Theo từng đề
          </button>
          {/* Quick actions */}
          <div style={{ flex: 1 }} />
          {[
            { href: '/tests', label: '🎯 Luyện tập', primary: true },
            { href: '/review', label: '❌ Sai nhiều' },
            { href: '/review#bookmarks', label: '🔖 Bookmark' },
          ].map(btn => (
            <Link key={btn.href} href={btn.href} style={{
              display: 'inline-block', padding: '0.5rem 1rem',
              background: btn.primary ? 'var(--primary)' : 'rgba(255,255,255,0.05)',
              border: `1px solid ${btn.primary ? 'var(--primary)' : 'var(--border)'}`,
              borderRadius: '10px', color: 'white', fontWeight: 600, fontSize: '0.82rem',
              textDecoration: 'none', transition: 'all 0.2s',
              boxShadow: btn.primary ? '0 4px 14px rgba(59,130,246,0.3)' : 'none',
            }}>{btn.label}</Link>
          ))}
        </div>

        {/* ════════════════ TAB: OVERVIEW ════════════════ */}
        {activeTab === 'overview' && (
          <>
            {/* Stats cards */}
            {stats && (
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(175px, 1fr))', gap: '1rem', marginBottom: '2rem' }}>
                <StatCard icon="📋" label="Tổng số lần làm" value={stats.totalAttempts} color="#3b82f6" sub={`${stats.totalFullTests} full · ${stats.totalPartPractices} part`} />
                <StatCard icon="🎯" label="Accuracy TB" value={`${stats.averageAccuracy ?? 0}%`} color="#10b981" sub="trên toàn bộ câu hỏi" />
                <StatCard icon="🏆" label="Best Score" value={stats.bestScore ?? 0} color="#f59e0b" sub="câu đúng nhiều nhất" />
                <StatCard icon="🔥" label="Study Streak" value={`${stats.currentStreak ?? 0}d`} color="#ef4444" sub="ngày liên tiếp" />
              </div>
            )}

            {/* Charts row */}
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1.5rem', marginBottom: '2rem' }}>

              {/* Accuracy over time */}
              <div style={{ background: 'var(--bg-panel)', border: '1px solid var(--border)', borderRadius: 'var(--radius-lg)', padding: '1.5rem', backdropFilter: 'blur(16px)' }}>
                <h3 style={{ fontFamily: 'var(--font-heading)', marginBottom: '0.2rem', fontSize: '1.05rem' }}>Accuracy theo thời gian</h3>
                <p style={{ color: 'var(--text-muted)', fontSize: '0.78rem', marginBottom: '1rem' }}>{scoreHistory.length} lần gần nhất</p>
                {overviewChart ? (
                  <svg width="100%" viewBox={`0 0 ${chartW} ${chartH}`} style={{ overflow: 'visible' }}>
                    {[0, 25, 50, 75, 100].map(pct => {
                      const y = chartPad.top + (1 - pct / 100) * (chartH - chartPad.top - chartPad.bottom);
                      return (
                        <g key={pct}>
                          <line x1={chartPad.left} y1={y} x2={chartW - chartPad.right} y2={y} stroke="rgba(255,255,255,0.05)" strokeWidth="1" />
                          <text x={chartPad.left - 4} y={y + 4} textAnchor="end" fill="#94a3b8" fontSize="10">{pct}%</text>
                        </g>
                      );
                    })}
                    <defs>
                      <linearGradient id="areaGrad" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="0%" stopColor="#3b82f6" stopOpacity="0.3" />
                        <stop offset="100%" stopColor="#3b82f6" stopOpacity="0" />
                      </linearGradient>
                    </defs>
                    <polygon points={overviewChart.area} fill="url(#areaGrad)" />
                    <polyline points={overviewChart.points} fill="none" stroke="#3b82f6" strokeWidth="2.5" strokeLinejoin="round" strokeLinecap="round" />
                    {overviewChart.vals.map((v, i) => (
                      <circle key={i} cx={overviewChart.sx(i)} cy={overviewChart.sy(v)} r="4" fill="#3b82f6" stroke="white" strokeWidth="2">
                        <title>{`${scoreHistory[i]?.testTitle}: ${v}%`}</title>
                      </circle>
                    ))}
                  </svg>
                ) : (
                  <div style={{ textAlign: 'center', color: 'var(--text-muted)', padding: '2rem' }}>
                    <div style={{ fontSize: '2rem', marginBottom: '0.5rem' }}>📊</div>
                    <p style={{ fontSize: '0.875rem' }}>Hoàn thành ít nhất 2 bài để thấy biểu đồ.</p>
                  </div>
                )}
              </div>

              {/* Part accuracy (overall) */}
              <div style={{ background: 'var(--bg-panel)', border: '1px solid var(--border)', borderRadius: 'var(--radius-lg)', padding: '1.5rem', backdropFilter: 'blur(16px)' }}>
                <h3 style={{ fontFamily: 'var(--font-heading)', marginBottom: '0.2rem', fontSize: '1.05rem' }}>Accuracy theo Part (tổng)</h3>
                <p style={{ color: 'var(--text-muted)', fontSize: '0.78rem', marginBottom: '1rem' }}>Điểm mạnh và điểm yếu tổng hợp</p>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '0.15rem' }}>
                  {partAccuracy.map((p, i) => (
                    <PartBar key={p.partNumber} p={p} index={i} clickable={false} />
                  ))}
                </div>
                {partAccuracy.every(p => p.totalAnswered === 0) && (
                  <div style={{ textAlign: 'center', color: 'var(--text-muted)', padding: '1.5rem' }}>
                    <p style={{ fontSize: '0.875rem' }}>Chưa có dữ liệu. Hãy bắt đầu luyện tập!</p>
                  </div>
                )}
              </div>
            </div>

            {/* Recent history */}
            <div style={{ background: 'var(--bg-panel)', border: '1px solid var(--border)', borderRadius: 'var(--radius-lg)', padding: '1.5rem', backdropFilter: 'blur(16px)' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.25rem' }}>
                <h3 style={{ fontFamily: 'var(--font-heading)', fontSize: '1.05rem', margin: 0 }}>Lịch sử gần đây</h3>
                <Link href="/history" style={{ fontSize: '0.8rem', color: '#60a5fa', fontWeight: 600, textDecoration: 'none', padding: '0.3rem 0.75rem', borderRadius: '8px', border: '1px solid rgba(96,165,250,0.3)', background: 'rgba(96,165,250,0.08)' }}>
                  Xem toàn bộ →
                </Link>
              </div>
              {history.length > 0 ? (
                <div style={{ overflowX: 'auto' }}>
                  <table style={{ width: '100%', borderCollapse: 'separate', borderSpacing: 0, textAlign: 'left' }}>
                    <thead>
                      <tr>
                        {['Đề thi', 'Loại', 'Ngày', 'Thời gian', 'Đúng', 'Accuracy', ''].map(h => (
                          <th key={h} style={{ padding: '0.75rem 1rem', color: 'var(--text-muted)', fontWeight: 600, textTransform: 'uppercase', fontSize: '0.7rem', letterSpacing: '0.05em', borderBottom: '1px solid var(--border)' }}>{h}</th>
                        ))}
                      </tr>
                    </thead>
                    <tbody>
                      {history.map(attempt => {
                        const dur = attempt.durationSeconds ? `${Math.floor(attempt.durationSeconds / 60)}m ${attempt.durationSeconds % 60}s` : '—';
                        const acc = attempt.totalCorrect != null && attempt.totalCorrect + (attempt.totalIncorrect || 0) > 0
                          ? Math.round(attempt.totalCorrect / (attempt.totalCorrect + (attempt.totalIncorrect || 0)) * 100) : null;
                        return (
                          <tr key={attempt.id} onClick={() => router.push(`/test/${attempt.testId || 1}?attemptId=${attempt.id}`)}
                            style={{ cursor: 'pointer', transition: 'background 0.15s' }}
                            onMouseOver={e => e.currentTarget.style.background = 'rgba(255,255,255,0.06)'}
                            onMouseOut={e => e.currentTarget.style.background = 'transparent'}>
                            <td style={{ padding: '0.75rem 1rem', borderBottom: '1px solid rgba(255,255,255,0.05)', fontWeight: 500, maxWidth: '200px' }}>
                              <div style={{ whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{attempt.testTitle}</div>
                              {attempt.partNumber && <div style={{ fontSize: '0.72rem', color: '#a78bfa', marginTop: '2px' }}>Part {attempt.partNumber}</div>}
                            </td>
                            <td style={{ padding: '0.75rem 1rem', borderBottom: '1px solid rgba(255,255,255,0.05)' }}>
                              <span style={{ padding: '2px 8px', borderRadius: '9999px', fontSize: '0.7rem', fontWeight: 700, background: attempt.attemptType === 'FULL' ? 'rgba(59,130,246,0.2)' : 'rgba(139,92,246,0.2)', color: attempt.attemptType === 'FULL' ? '#60a5fa' : '#a78bfa' }}>
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
                              {acc != null ? <span style={{ color: accColor(acc) }}>{acc}%</span> : '—'}
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
                  <p style={{ marginBottom: '1.5rem' }}>Chưa có lịch sử luyện tập.</p>
                  <Link href="/tests" style={{ display: 'inline-block', padding: '0.75rem 2rem', background: 'var(--primary)', borderRadius: '10px', color: 'white', fontWeight: 600, textDecoration: 'none' }}>
                    Bắt đầu luyện tập
                  </Link>
                </div>
              )}
            </div>
          </>
        )}

        {/* ════════════════ TAB: BY TEST ════════════════ */}
        {activeTab === 'by-test' && (
          <>
            {attemptedTests.length === 0 ? (
              <div style={{ textAlign: 'center', padding: '4rem', color: 'var(--text-muted)' }}>
                <div style={{ fontSize: '3.5rem', marginBottom: '1rem' }}>📋</div>
                <p style={{ marginBottom: '1.5rem', fontSize: '1rem' }}>Chưa có đề nào được luyện tập.</p>
                <Link href="/tests" style={{ display: 'inline-block', padding: '0.75rem 2rem', background: 'var(--primary)', borderRadius: '10px', color: 'white', fontWeight: 600, textDecoration: 'none' }}>
                  Chọn đề để luyện
                </Link>
              </div>
            ) : (
              <div style={{ display: 'grid', gridTemplateColumns: selectedTestId ? '280px 1fr' : '1fr', gap: '1.5rem' }}>

                {/* Left: Test list */}
                <div style={{ display: 'flex', flexDirection: 'column', gap: '0.6rem' }}>
                  <div style={{ fontSize: '0.78rem', fontWeight: 700, color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.05em', marginBottom: '0.25rem' }}>
                    Đề đã luyện ({attemptedTests.length})
                  </div>
                  {attemptedTests.map(t => {
                    const isSelected = selectedTestId === t.testId;
                    return (
                      <div
                        key={t.testId}
                        id={`test-item-${t.testId}`}
                        onClick={() => loadTestAnalytics(t.testId)}
                        style={{
                          background: isSelected ? 'rgba(59,130,246,0.15)' : 'var(--bg-panel)',
                          border: `1px solid ${isSelected ? '#3b82f6' : 'var(--border)'}`,
                          borderRadius: '12px', padding: '0.9rem 1rem',
                          cursor: 'pointer', transition: 'all 0.2s',
                          boxShadow: isSelected ? '0 0 0 2px rgba(59,130,246,0.3)' : 'none',
                        }}
                        onMouseOver={e => { if (!isSelected) e.currentTarget.style.background = 'rgba(255,255,255,0.06)'; }}
                        onMouseOut={e => { if (!isSelected) e.currentTarget.style.background = 'var(--bg-panel)'; }}
                      >
                        <div style={{ fontWeight: 700, fontSize: '0.9rem', marginBottom: '0.3rem', color: isSelected ? '#60a5fa' : 'var(--text-main)' }}>
                          {t.testTitle}
                        </div>
                        <div style={{ display: 'flex', gap: '0.75rem', fontSize: '0.72rem', color: 'var(--text-muted)' }}>
                          <span>🔁 {t.totalAttempts} lần</span>
                          <span>🎯 TB {t.averageAccuracy}%</span>
                        </div>
                        <div style={{ fontSize: '0.7rem', color: 'var(--text-muted)', marginTop: '0.2rem' }}>
                          🏆 Best: <span style={{ color: accColor(t.bestAccuracy), fontWeight: 700 }}>{t.bestAccuracy}%</span>
                        </div>
                      </div>
                    );
                  })}
                </div>

                {/* Right: Test detail OR Part detail */}
                {selectedTestId && (
                  <div>
                    {testAnalyticsLoading ? (
                      <div style={{ textAlign: 'center', padding: '3rem', color: 'var(--text-muted)' }}>
                        <div style={{ fontSize: '2rem', marginBottom: '0.5rem', animation: 'spin 1s linear infinite' }}>⏳</div>
                        <p>Đang tải...</p>
                      </div>
                    ) : testAnalytics ? (
                      <>
                        {/* Breadcrumb */}
                        <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', fontSize: '0.8rem', color: 'var(--text-muted)', marginBottom: '1.25rem' }}>
                          <span style={{ cursor: 'pointer', color: '#60a5fa' }} onClick={() => { setSelectedPart(null); setPartDetail(null); }}>
                            {testAnalytics.testTitle}
                          </span>
                          {selectedPart && (
                            <>
                              <span>›</span>
                              <span style={{ color: PART_COLORS[selectedPart - 1] }}>Part {selectedPart} — {PART_NAMES[selectedPart - 1]}</span>
                            </>
                          )}
                        </div>

                        {/* ── Part Detail View ── */}
                        {selectedPart && partDetail ? (
                          partDetailLoading ? (
                            <div style={{ textAlign: 'center', padding: '2rem', color: 'var(--text-muted)' }}><p>Đang tải...</p></div>
                          ) : (
                            <div style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
                              {/* Back btn */}
                              <button
                                onClick={() => { setSelectedPart(null); setPartDetail(null); }}
                                style={{ alignSelf: 'flex-start', background: 'rgba(255,255,255,0.06)', border: '1px solid var(--border)', borderRadius: '8px', padding: '0.35rem 0.85rem', color: 'var(--text-muted)', cursor: 'pointer', fontFamily: 'inherit', fontSize: '0.8rem' }}
                              >
                                ← Quay lại {testAnalytics.testTitle}
                              </button>

                              {/* Part header */}
                              <div style={{ background: 'var(--bg-panel)', border: `1px solid ${PART_COLORS[selectedPart - 1]}44`, borderRadius: 'var(--radius-lg)', padding: '1.25rem 1.5rem', backdropFilter: 'blur(16px)' }}>
                                <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginBottom: '1rem' }}>
                                  <span style={{ fontSize: '2rem' }}>{PART_ICONS[selectedPart - 1]}</span>
                                  <div>
                                    <div style={{ fontFamily: 'var(--font-heading)', fontSize: '1.2rem', fontWeight: 800 }}>
                                      Part {selectedPart} — {partDetail.partName}
                                    </div>
                                    <div style={{ color: 'var(--text-muted)', fontSize: '0.8rem' }}>{testAnalytics.testTitle}</div>
                                  </div>
                                </div>
                                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '0.75rem' }}>
                                  <StatCard icon="🔁" label="Số lần luyện" value={partDetail.totalAttempts} color={PART_COLORS[selectedPart - 1]} />
                                  <StatCard icon="🎯" label="Accuracy TB" value={`${partDetail.averageAccuracy}%`} color="#10b981" />
                                  <StatCard icon="🏆" label="Best" value={`${partDetail.bestAccuracy}%`} color="#f59e0b" />
                                  <StatCard icon="✅" label="Tổng đúng" value={`${partDetail.totalCorrect}/${partDetail.totalAnswered}`} color="#3b82f6" />
                                </div>
                              </div>

                              {/* Trend chart */}
                              <div style={{ background: 'var(--bg-panel)', border: '1px solid var(--border)', borderRadius: 'var(--radius-lg)', padding: '1.25rem 1.5rem', backdropFilter: 'blur(16px)' }}>
                                <h3 style={{ fontFamily: 'var(--font-heading)', fontSize: '1rem', marginBottom: '0.25rem' }}>Xu hướng Accuracy theo thời gian</h3>
                                <p style={{ color: 'var(--text-muted)', fontSize: '0.78rem', marginBottom: '1rem' }}>{partDetail.attemptHistory.length} lần luyện</p>
                                <TrendChart data={partDetail.attemptHistory} />
                              </div>

                              {/* Attempt history table */}
                              {partDetail.attemptHistory.length > 0 && (
                                <div style={{ background: 'var(--bg-panel)', border: '1px solid var(--border)', borderRadius: 'var(--radius-lg)', padding: '1.25rem 1.5rem', backdropFilter: 'blur(16px)' }}>
                                  <h3 style={{ fontFamily: 'var(--font-heading)', fontSize: '1rem', marginBottom: '1rem' }}>Chi tiết từng lần luyện</h3>
                                  <table style={{ width: '100%', borderCollapse: 'separate', borderSpacing: 0, textAlign: 'left' }}>
                                    <thead>
                                      <tr>
                                        {['Lần', 'Ngày', 'Đúng/Tổng', 'Accuracy', 'Thời gian'].map(h => (
                                          <th key={h} style={{ padding: '0.6rem 0.75rem', color: 'var(--text-muted)', fontWeight: 600, textTransform: 'uppercase', fontSize: '0.68rem', letterSpacing: '0.05em', borderBottom: '1px solid var(--border)' }}>{h}</th>
                                        ))}
                                      </tr>
                                    </thead>
                                    <tbody>
                                      {[...partDetail.attemptHistory].reverse().map((h, idx) => (
                                        <tr key={h.attemptId} onMouseOver={e => e.currentTarget.style.background = 'rgba(255,255,255,0.04)'} onMouseOut={e => e.currentTarget.style.background = 'transparent'}>
                                          <td style={{ padding: '0.6rem 0.75rem', borderBottom: '1px solid rgba(255,255,255,0.04)', color: 'var(--text-muted)', fontSize: '0.8rem' }}>
                                            #{partDetail.attemptHistory.length - idx}
                                          </td>
                                          <td style={{ padding: '0.6rem 0.75rem', borderBottom: '1px solid rgba(255,255,255,0.04)', fontSize: '0.8rem' }}>
                                            {new Date(h.date).toLocaleDateString('vi-VN')}
                                            <div style={{ fontSize: '0.68rem', color: 'var(--text-muted)' }}>
                                              {new Date(h.date).toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' })}
                                            </div>
                                          </td>
                                          <td style={{ padding: '0.6rem 0.75rem', borderBottom: '1px solid rgba(255,255,255,0.04)', fontWeight: 600 }}>
                                            <span style={{ color: '#34d399' }}>{h.totalCorrect}</span>
                                            <span style={{ color: 'var(--text-muted)' }}>/{h.totalAnswered}</span>
                                          </td>
                                          <td style={{ padding: '0.6rem 0.75rem', borderBottom: '1px solid rgba(255,255,255,0.04)', fontWeight: 700 }}>
                                            <span style={{ color: accColor(h.accuracy) }}>{h.accuracy}%</span>
                                          </td>
                                          <td style={{ padding: '0.6rem 0.75rem', borderBottom: '1px solid rgba(255,255,255,0.04)', color: 'var(--text-muted)', fontSize: '0.8rem' }}>
                                            {h.durationSeconds ? `${Math.floor(h.durationSeconds / 60)}m ${h.durationSeconds % 60}s` : '—'}
                                          </td>
                                        </tr>
                                      ))}
                                    </tbody>
                                  </table>
                                </div>
                              )}
                            </div>
                          )
                        ) : (

                        /* ── Test Analytics View ── */
                        <div style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>

                          {/* Test stats cards */}
                          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '0.75rem' }}>
                            <StatCard icon="🔁" label="Tổng lần làm" value={testAnalytics.totalAttempts} color="#3b82f6" sub={`${testAnalytics.totalFullAttempts} full · ${testAnalytics.totalPartAttempts} part`} />
                            <StatCard icon="🎯" label="Accuracy TB" value={`${testAnalytics.averageAccuracy}%`} color="#10b981" />
                            <StatCard icon="🏆" label="Best Accuracy" value={`${testAnalytics.bestAccuracy}%`} color="#f59e0b" />
                            <StatCard icon="📅" label="Lần cuối" color="#8b5cf6"
                              value={testAnalytics.lastAttemptDate ? new Date(testAnalytics.lastAttemptDate).toLocaleDateString('vi-VN') : '—'}
                            />
                          </div>

                          {/* Part accuracy for this test */}
                          <div style={{ background: 'var(--bg-panel)', border: '1px solid var(--border)', borderRadius: 'var(--radius-lg)', padding: '1.25rem 1.5rem', backdropFilter: 'blur(16px)' }}>
                            <h3 style={{ fontFamily: 'var(--font-heading)', fontSize: '1rem', marginBottom: '0.25rem' }}>Accuracy từng Part</h3>
                            <p style={{ color: 'var(--text-muted)', fontSize: '0.78rem', marginBottom: '1rem' }}>
                              Click vào part để xem chi tiết từng lần luyện
                            </p>
                            <div style={{ display: 'flex', flexDirection: 'column', gap: '0.2rem' }}>
                              {testAnalytics.partStats.map((p, i) => (
                                <PartBar
                                  key={p.partNumber}
                                  p={p}
                                  index={i}
                                  clickable={p.totalAnswered > 0}
                                  onClick={() => {
                                    if (p.totalAnswered > 0) loadPartDetail(testAnalytics.testId, p.partNumber);
                                  }}
                                />
                              ))}
                            </div>
                            {testAnalytics.partStats.every(p => p.totalAnswered === 0) && (
                              <div style={{ textAlign: 'center', color: 'var(--text-muted)', padding: '1.5rem', fontSize: '0.875rem' }}>
                                Chưa có dữ liệu chi tiết cho đề này.
                              </div>
                            )}
                          </div>

                          {/* Hint */}
                          <div style={{ background: 'rgba(59,130,246,0.08)', border: '1px solid rgba(59,130,246,0.2)', borderRadius: '10px', padding: '0.85rem 1.1rem', fontSize: '0.82rem', color: '#93c5fd' }}>
                            💡 <strong>Tip:</strong> Click vào bất kỳ Part nào (có dữ liệu) để xem xu hướng cải thiện chi tiết theo từng lần luyện.
                          </div>
                        </div>
                        )}
                      </>
                    ) : null}
                  </div>
                )}

                {/* Prompt to select a test */}
                {!selectedTestId && (
                  <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', background: 'var(--bg-panel)', border: '1px dashed var(--border)', borderRadius: 'var(--radius-lg)', minHeight: '300px', color: 'var(--text-muted)', textAlign: 'center', padding: '2rem' }}>
                    <div>
                      <div style={{ fontSize: '3rem', marginBottom: '1rem' }}>👈</div>
                      <p style={{ fontSize: '1rem', fontWeight: 500 }}>Chọn một đề để xem chi tiết</p>
                      <p style={{ fontSize: '0.82rem', marginTop: '0.5rem' }}>Accuracy từng part, lịch sử từng lần luyện</p>
                    </div>
                  </div>
                )}
              </div>
            )}
          </>
        )}
      </main>
    </div>
  );
}
