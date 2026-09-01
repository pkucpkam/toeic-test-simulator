"use client";

import React, { useEffect, useState, useCallback } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { getUser, logout } from '../../utils/auth';
import apiClient from '../../utils/apiClient';
import '../globals.css';

const PART_INFO = {
  1: { name: 'Photographs', icon: '🖼️', color: '#3b82f6' },
  2: { name: 'Question-Response', icon: '🎙️', color: '#8b5cf6' },
  3: { name: 'Conversations', icon: '💬', color: '#10b981' },
  4: { name: 'Short Talks', icon: '📢', color: '#f59e0b' },
  5: { name: 'Incomplete Sentences', icon: '✏️', color: '#ef4444' },
  6: { name: 'Text Completion', icon: '📝', color: '#ec4899' },
  7: { name: 'Reading Passages', icon: '📖', color: '#06b6d4' },
};

function formatDuration(seconds) {
  if (!seconds) return '—';
  const m = Math.floor(seconds / 60);
  const s = seconds % 60;
  return `${m}m ${s}s`;
}

function formatDate(dateStr) {
  if (!dateStr) return '—';
  const d = new Date(dateStr);
  return d.toLocaleDateString('vi-VN', {
    day: '2-digit', month: '2-digit', year: 'numeric',
    hour: '2-digit', minute: '2-digit',
  });
}

function getAccuracy(attempt) {
  const correct = attempt.totalCorrect ?? 0;
  const incorrect = attempt.totalIncorrect ?? 0;
  const unanswered = attempt.totalUnanswered ?? 0;
  const total = correct + incorrect + unanswered;
  if (total === 0) return null;
  return Math.round((correct / total) * 100);
}

function getAccuracyColor(acc) {
  if (acc == null) return '#94a3b8';
  if (acc >= 70) return '#4ade80';
  if (acc >= 40) return '#fbbf24';
  return '#f87171';
}

function AttemptCard({ attempt, onReview }) {
  const acc = getAccuracy(attempt);
  const accColor = getAccuracyColor(acc);
  const isFullTest = attempt.attemptType === 'FULL';
  const partInfo = !isFullTest && attempt.partNumber ? PART_INFO[attempt.partNumber] : null;
  const correct = attempt.totalCorrect ?? 0;
  const incorrect = attempt.totalIncorrect ?? 0;
  const unanswered = attempt.totalUnanswered ?? 0;
  const total = correct + incorrect + unanswered;

  return (
    <div
      style={{
        background: 'var(--bg-panel)',
        border: '1px solid var(--border)',
        borderRadius: '14px',
        padding: '1.25rem 1.5rem',
        backdropFilter: 'blur(16px)',
        display: 'grid',
        gridTemplateColumns: '1fr auto',
        gap: '1rem',
        alignItems: 'center',
        transition: 'border-color 0.2s, transform 0.15s, box-shadow 0.2s',
        cursor: 'default',
        position: 'relative',
        overflow: 'hidden',
      }}
      onMouseEnter={e => {
        e.currentTarget.style.borderColor = 'rgba(96,165,250,0.4)';
        e.currentTarget.style.boxShadow = '0 4px 24px rgba(59,130,246,0.12)';
        e.currentTarget.style.transform = 'translateY(-1px)';
      }}
      onMouseLeave={e => {
        e.currentTarget.style.borderColor = 'var(--border)';
        e.currentTarget.style.boxShadow = 'none';
        e.currentTarget.style.transform = 'translateY(0)';
      }}
    >
      {/* Left color accent bar */}
      <div style={{
        position: 'absolute', top: 0, left: 0, width: '4px', bottom: 0, borderRadius: '14px 0 0 14px',
        background: isFullTest
          ? 'linear-gradient(180deg,#3b82f6,#a78bfa)'
          : `linear-gradient(180deg,${partInfo?.color || '#94a3b8'},${partInfo?.color || '#94a3b8'}88)`,
      }} />

      <div style={{ paddingLeft: '0.5rem' }}>
        {/* Title row */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.6rem', marginBottom: '0.5rem', flexWrap: 'wrap' }}>
          <span style={{ fontWeight: 700, fontSize: '1rem' }}>{attempt.testTitle}</span>

          {/* Type badge */}
          {isFullTest ? (
            <span style={{
              padding: '2px 10px', borderRadius: '9999px', fontSize: '0.7rem', fontWeight: 700,
              background: 'rgba(59,130,246,0.2)', color: '#60a5fa',
            }}>Full Test</span>
          ) : (
            <span style={{
              padding: '2px 10px', borderRadius: '9999px', fontSize: '0.7rem', fontWeight: 700,
              background: partInfo ? `${partInfo.color}22` : 'rgba(139,92,246,0.2)',
              color: partInfo?.color || '#a78bfa',
            }}>
              {partInfo ? `${partInfo.icon} Part ${attempt.partNumber} – ${partInfo.name}` : `Part ${attempt.partNumber ?? '?'}`}
            </span>
          )}
        </div>

        {/* Stats row */}
        <div style={{ display: 'flex', gap: '1.5rem', flexWrap: 'wrap', fontSize: '0.8rem', color: 'var(--text-muted)' }}>
          {/* Accuracy */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.3rem' }}>
            <span>🎯</span>
            <span style={{ color: accColor, fontWeight: 700, fontSize: '0.9rem' }}>
              {acc != null ? `${acc}%` : '—'}
            </span>
          </div>

          {/* Correct/Total */}
          {total > 0 && (
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.3rem' }}>
              <span>✅</span>
              <span><strong style={{ color: '#4ade80' }}>{correct}</strong> / {total}</span>
              {incorrect > 0 && (
                <span style={{ color: '#f87171', marginLeft: '0.25rem' }}>· ❌ {incorrect}</span>
              )}
              {unanswered > 0 && (
                <span style={{ color: '#94a3b8', marginLeft: '0.25rem' }}>· ⬜ {unanswered}</span>
              )}
            </div>
          )}

          {/* Duration */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.3rem' }}>
            <span>⏱️</span>
            <span>{formatDuration(attempt.durationSeconds)}</span>
          </div>

          {/* Date */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.3rem' }}>
            <span>📅</span>
            <span>{formatDate(attempt.startedAt)}</span>
          </div>
        </div>
      </div>

      {/* Right: Review button */}
      <div style={{ flexShrink: 0 }}>
        <button
          onClick={() => onReview(attempt)}
          style={{
            padding: '0.5rem 1.1rem',
            background: 'rgba(96,165,250,0.12)',
            border: '1px solid rgba(96,165,250,0.35)',
            borderRadius: '10px',
            color: '#60a5fa',
            fontWeight: 600,
            fontSize: '0.82rem',
            cursor: 'pointer',
            whiteSpace: 'nowrap',
            transition: 'background 0.15s, transform 0.1s',
            fontFamily: 'inherit',
          }}
          onMouseEnter={e => {
            e.currentTarget.style.background = 'rgba(96,165,250,0.22)';
            e.currentTarget.style.transform = 'scale(1.04)';
          }}
          onMouseLeave={e => {
            e.currentTarget.style.background = 'rgba(96,165,250,0.12)';
            e.currentTarget.style.transform = 'scale(1)';
          }}
        >
          Xem lại ➔
        </button>
      </div>
    </div>
  );
}

const PAGE_SIZE = 15;

export default function HistoryPage() {
  const router = useRouter();
  const [user, setUser] = useState(null);
  const [allHistory, setAllHistory] = useState([]);
  const [loading, setLoading] = useState(true);
  const [currentPage, setCurrentPage] = useState(0);
  const [totalPages, setTotalPages] = useState(0);
  const [totalElements, setTotalElements] = useState(0);

  // Filters
  const [filterType, setFilterType] = useState('ALL'); // ALL | FULL | PART
  const [filterPart, setFilterPart] = useState(null); // null | 1-7
  const [searchText, setSearchText] = useState('');

  const fetchHistory = useCallback(async (page = 0) => {
    setLoading(true);
    try {
      const res = await apiClient.get(`/analytics/history?page=${page}&size=${PAGE_SIZE}`);
      const data = res.data;
      const items = Array.isArray(data) ? data : (data?.content || []);
      setAllHistory(items);
      setTotalPages(data?.totalPages ?? 1);
      setTotalElements(data?.totalElements ?? items.length);
      setCurrentPage(page);
    } catch (err) {
      console.error('Failed to load history', err);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    const init = async () => {
      const currentUser = getUser();
      if (!currentUser) {
        router.push('/login');
        return;
      }
      setUser(currentUser);
      await fetchHistory(0);
    };
    init();
  }, [router, fetchHistory]);

  const handleLogout = () => {
    logout();
    router.push('/login');
  };

  const handleReview = (attempt) => {
    router.push(`/test/${attempt.testId}?attemptId=${attempt.id}`);
  };

  // Client-side filter on top of fetched page data
  const filteredHistory = allHistory.filter(a => {
    if (filterType === 'FULL' && a.attemptType !== 'FULL') return false;
    if (filterType === 'PART' && a.attemptType !== 'PART') return false;
    if (filterPart !== null && a.partNumber !== filterPart) return false;
    if (searchText.trim()) {
      const q = searchText.toLowerCase();
      if (!(a.testTitle || '').toLowerCase().includes(q)) return false;
    }
    return true;
  });

  const handlePageChange = (page) => {
    // Reset client filters when paginating
    fetchHistory(page);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const typeFilters = [
    { key: 'ALL', label: 'Tất cả' },
    { key: 'FULL', label: '📋 Full Test' },
    { key: 'PART', label: '🧩 Part Practice' },
  ];

  if (!user) return null;

  return (
    <div style={{ minHeight: '100vh', background: 'var(--bg-main)', color: 'var(--text-main)', fontFamily: 'var(--font-body)' }}>

      {/* Header */}
      <header style={{
        maxWidth: '1100px', margin: '0 auto', padding: '1.5rem 24px',
        display: 'flex', justifyContent: 'space-between', alignItems: 'center',
        borderBottom: '1px solid var(--border)',
      }}>
        <div style={{ fontFamily: 'var(--font-heading)', fontSize: '1.5rem', fontWeight: 800 }}>
          <Link href="/dashboard" style={{ textDecoration: 'none', color: 'inherit' }}>
            <span style={{ background: 'linear-gradient(135deg,#60a5fa,#a78bfa)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>TOEIC</span> Master
          </Link>
        </div>
        <nav style={{ display: 'flex', gap: '1.5rem', alignItems: 'center' }}>
          <span style={{ fontWeight: 600, color: 'var(--primary)' }}>Hi, {user.name}</span>
          <Link href="/tests" style={{ color: 'var(--text-muted)', fontWeight: 500, textDecoration: 'none' }}>Practice</Link>
          <Link href="/history" style={{ color: 'white', fontWeight: 600, textDecoration: 'none', borderBottom: '2px solid #60a5fa', paddingBottom: '2px' }}>History</Link>
          <Link href="/review" style={{ color: 'var(--text-muted)', fontWeight: 500, textDecoration: 'none' }}>Review</Link>
          <button onClick={handleLogout} style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer', fontFamily: 'inherit', fontSize: '1rem', fontWeight: 500 }}>Logout</button>
        </nav>
      </header>

      <main style={{ maxWidth: '1100px', margin: '0 auto', padding: '2rem 24px 5rem' }}>

        {/* Page title */}
        <div style={{ marginBottom: '2rem' }}>
          <h1 style={{ fontFamily: 'var(--font-heading)', fontSize: '2.2rem', fontWeight: 800, marginBottom: '0.25rem' }}>
            📅 Lịch Sử{' '}
            <span style={{ background: 'linear-gradient(135deg,#60a5fa,#a78bfa)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>
              Làm Bài
            </span>
          </h1>
          <p style={{ color: 'var(--text-muted)' }}>
            Toàn bộ các bài test và part bạn đã hoàn thành —{' '}
            <strong style={{ color: 'var(--text-main)' }}>{totalElements}</strong> lần làm
          </p>
        </div>

        {/* Filter bar */}
        <div style={{
          background: 'var(--bg-panel)', border: '1px solid var(--border)', borderRadius: '14px',
          padding: '1rem 1.25rem', marginBottom: '1.5rem', backdropFilter: 'blur(16px)',
          display: 'flex', gap: '1rem', flexWrap: 'wrap', alignItems: 'center',
        }}>

          {/* Type filter */}
          <div style={{ display: 'flex', gap: '0.4rem' }}>
            {typeFilters.map(f => (
              <button
                key={f.key}
                onClick={() => { setFilterType(f.key); if (f.key !== 'PART') setFilterPart(null); }}
                style={{
                  padding: '0.4rem 0.9rem',
                  borderRadius: '8px',
                  border: filterType === f.key ? '1px solid #60a5fa' : '1px solid var(--border)',
                  background: filterType === f.key ? 'rgba(96,165,250,0.18)' : 'rgba(255,255,255,0.04)',
                  color: filterType === f.key ? '#60a5fa' : 'var(--text-muted)',
                  fontWeight: filterType === f.key ? 700 : 500,
                  fontSize: '0.82rem',
                  cursor: 'pointer',
                  transition: 'all 0.15s',
                  fontFamily: 'inherit',
                }}
              >{f.label}</button>
            ))}
          </div>

          {/* Part filter (only when PART type selected) */}
          {filterType === 'PART' && (
            <div style={{ display: 'flex', gap: '0.35rem', flexWrap: 'wrap' }}>
              <button
                onClick={() => setFilterPart(null)}
                style={{
                  padding: '0.3rem 0.75rem', borderRadius: '8px', fontSize: '0.78rem', fontWeight: 600,
                  border: filterPart === null ? '1px solid #60a5fa' : '1px solid var(--border)',
                  background: filterPart === null ? 'rgba(96,165,250,0.18)' : 'rgba(255,255,255,0.04)',
                  color: filterPart === null ? '#60a5fa' : 'var(--text-muted)',
                  cursor: 'pointer', transition: 'all 0.15s', fontFamily: 'inherit',
                }}
              >All Parts</button>
              {[1, 2, 3, 4, 5, 6, 7].map(p => {
                const info = PART_INFO[p];
                const active = filterPart === p;
                return (
                  <button
                    key={p}
                    onClick={() => setFilterPart(active ? null : p)}
                    title={info.name}
                    style={{
                      padding: '0.3rem 0.7rem', borderRadius: '8px', fontSize: '0.78rem', fontWeight: 600,
                      border: `1px solid ${active ? info.color : 'var(--border)'}`,
                      background: active ? `${info.color}22` : 'rgba(255,255,255,0.04)',
                      color: active ? info.color : 'var(--text-muted)',
                      cursor: 'pointer', transition: 'all 0.15s', fontFamily: 'inherit',
                    }}
                  >P{p} {info.icon}</button>
                );
              })}
            </div>
          )}

          {/* Spacer */}
          <div style={{ flex: 1 }} />

          {/* Search */}
          <div style={{ position: 'relative' }}>
            <span style={{ position: 'absolute', left: '10px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)', fontSize: '0.85rem' }}>🔍</span>
            <input
              type="text"
              placeholder="Tìm tên test..."
              value={searchText}
              onChange={e => setSearchText(e.target.value)}
              style={{
                paddingLeft: '2rem', paddingRight: '0.75rem', paddingTop: '0.4rem', paddingBottom: '0.4rem',
                background: 'rgba(255,255,255,0.06)', border: '1px solid var(--border)',
                borderRadius: '8px', color: 'var(--text-main)', fontSize: '0.82rem',
                outline: 'none', width: '180px', fontFamily: 'inherit',
                transition: 'border-color 0.15s',
              }}
              onFocus={e => e.currentTarget.style.borderColor = '#60a5fa'}
              onBlur={e => e.currentTarget.style.borderColor = 'var(--border)'}
            />
          </div>
        </div>

        {/* History list */}
        {loading ? (
          <div style={{ textAlign: 'center', padding: '5rem', color: 'var(--text-muted)' }}>
            <div style={{ fontSize: '2.5rem', marginBottom: '1rem', animation: 'spin 1s linear infinite' }}>⏳</div>
            <p>Đang tải lịch sử...</p>
          </div>
        ) : filteredHistory.length === 0 ? (
          <div style={{
            textAlign: 'center', padding: '5rem', color: 'var(--text-muted)',
            background: 'var(--bg-panel)', border: '1px solid var(--border)',
            borderRadius: '14px', backdropFilter: 'blur(16px)',
          }}>
            <div style={{ fontSize: '3.5rem', marginBottom: '1rem' }}>
              {allHistory.length === 0 ? '📝' : '🔍'}
            </div>
            <p style={{ fontSize: '1rem', marginBottom: '1.5rem' }}>
              {allHistory.length === 0
                ? 'Bạn chưa hoàn thành bài nào.'
                : 'Không tìm thấy kết quả phù hợp với bộ lọc.'}
            </p>
            {allHistory.length === 0 && (
              <Link href="/tests" style={{
                display: 'inline-block', padding: '0.75rem 2rem',
                background: 'var(--primary)', borderRadius: '10px',
                color: 'white', fontWeight: 600, textDecoration: 'none',
              }}>Bắt đầu luyện tập</Link>
            )}
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
            {filteredHistory.map(attempt => (
              <AttemptCard key={attempt.id} attempt={attempt} onReview={handleReview} />
            ))}
          </div>
        )}

        {/* Pagination */}
        {!loading && totalPages > 1 && (
          <div style={{
            display: 'flex', justifyContent: 'center', alignItems: 'center',
            gap: '0.5rem', marginTop: '2.5rem', flexWrap: 'wrap',
          }}>
            <PaginationBtn
              label="← Trước"
              disabled={currentPage === 0}
              onClick={() => handlePageChange(currentPage - 1)}
            />

            {Array.from({ length: totalPages }, (_, i) => i).map(p => {
              const isActive = p === currentPage;
              if (totalPages > 7 && Math.abs(p - currentPage) > 2 && p !== 0 && p !== totalPages - 1) {
                if (p === 1 && currentPage > 3) return <span key="el1" style={{ color: 'var(--text-muted)' }}>…</span>;
                if (p === totalPages - 2 && currentPage < totalPages - 4) return <span key="el2" style={{ color: 'var(--text-muted)' }}>…</span>;
                if (Math.abs(p - currentPage) > 2) return null;
              }
              return (
                <button
                  key={p}
                  onClick={() => handlePageChange(p)}
                  style={{
                    width: '36px', height: '36px', borderRadius: '8px',
                    border: isActive ? '1px solid #60a5fa' : '1px solid var(--border)',
                    background: isActive ? 'rgba(96,165,250,0.2)' : 'rgba(255,255,255,0.04)',
                    color: isActive ? '#60a5fa' : 'var(--text-muted)',
                    fontWeight: isActive ? 700 : 500, fontSize: '0.85rem',
                    cursor: 'pointer', transition: 'all 0.15s', fontFamily: 'inherit',
                  }}
                >{p + 1}</button>
              );
            })}

            <PaginationBtn
              label="Sau →"
              disabled={currentPage >= totalPages - 1}
              onClick={() => handlePageChange(currentPage + 1)}
            />
          </div>
        )}

        {/* Info text below pagination */}
        {!loading && totalElements > 0 && (
          <p style={{ textAlign: 'center', color: 'var(--text-muted)', fontSize: '0.78rem', marginTop: '0.75rem' }}>
            Trang {currentPage + 1} / {totalPages} · {totalElements} lần làm tổng
          </p>
        )}
      </main>

      <style>{`
        @keyframes spin { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }
      `}</style>
    </div>
  );
}

function PaginationBtn({ label, disabled, onClick }) {
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      style={{
        padding: '0.4rem 0.9rem', borderRadius: '8px',
        border: '1px solid var(--border)',
        background: disabled ? 'rgba(255,255,255,0.02)' : 'rgba(255,255,255,0.06)',
        color: disabled ? 'var(--text-muted)' : 'var(--text-main)',
        fontWeight: 600, fontSize: '0.82rem',
        cursor: disabled ? 'not-allowed' : 'pointer',
        opacity: disabled ? 0.5 : 1,
        transition: 'all 0.15s', fontFamily: 'inherit',
      }}
    >{label}</button>
  );
}
