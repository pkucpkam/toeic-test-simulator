"use client";

import React, { useEffect, useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { getUser, logout } from '../../utils/auth';
import apiClient from '../../utils/apiClient';
import '../globals.css';

const PART_INFO = {
  1: { name: 'Photographs', icon: '🖼️', color: '#3b82f6', desc: 'Describe what you see in the photograph' },
  2: { name: 'Question-Response', icon: '🎙️', color: '#8b5cf6', desc: 'Choose the best response to a question' },
  3: { name: 'Conversations', icon: '💬', color: '#10b981', desc: 'Understand short conversations between two or more people' },
  4: { name: 'Short Talks', icon: '📢', color: '#f59e0b', desc: 'Understand short monologues' },
  5: { name: 'Incomplete Sentences', icon: '✏️', color: '#ef4444', desc: 'Choose the word or phrase that best completes the sentence' },
  6: { name: 'Text Completion', icon: '📝', color: '#ec4899', desc: 'Select words to complete passages' },
  7: { name: 'Reading Passages', icon: '📖', color: '#06b6d4', desc: 'Answer questions based on reading passages' },
};

export default function TestSelectionPage() {
  const router = useRouter();
  const [user, setUser] = useState(null);

  // Mode: null | 'full' | 'part'
  const [selectedMode, setSelectedMode] = useState(null);

  const [years, setYears] = useState([]);
  const [selectedYear, setSelectedYear] = useState(null);

  const [tests, setTests] = useState([]);
  const [selectedTest, setSelectedTest] = useState(null); // { id, title }

  // For Part mode: parts of the selected test
  const [parts, setParts] = useState([]);
  const [expandedPart, setExpandedPart] = useState(null); // partId of expanded mini-test
  const [miniGroups, setMiniGroups] = useState({}); // { [partId]: groupSummaries[] }
  const [loadingGroups, setLoadingGroups] = useState({});

  // For Skill mode
  const [skillParts, setSkillParts] = useState([]);
  const [selectedSkillCategory, setSelectedSkillCategory] = useState(null); // 'listening' | 'reading'
  const [loadingSkillParts, setLoadingSkillParts] = useState(false);
  const [selectedSkillPartNumber, setSelectedSkillPartNumber] = useState(null);

  useEffect(() => {
    const init = async () => {
      const currentUser = getUser();
      if (!currentUser) {
        router.push('/login');
        return;
      }
      setUser(currentUser);

      try {
        const res = await apiClient.get('/tests/years');
        setYears(res.data);
        if (res.data.length > 0) {
          setSelectedYear(res.data[0]);
        }
      } catch (err) {
        console.error("Error fetching years", err);
      }
    };
    init();
  }, [router]);

  // Fetch tests when year changes
  useEffect(() => {
    if (!selectedYear) return;
    const fetchTests = async () => {
      try {
        const res = await apiClient.get(`/tests?year=${selectedYear}`);
        setTests(res.data);
        setSelectedTest(null);
        setParts([]);
        setExpandedPart(null);
        setMiniGroups({});

        // Clear skill mode states on year change
        setSelectedSkillCategory(null);
        setSelectedSkillPartNumber(null);
        setSkillParts([]);
      } catch (err) {
        console.error("Error fetching tests", err);
      }
    };
    fetchTests();
  }, [selectedYear]);

  // Fetch parts when a test is selected in part mode
  useEffect(() => {
    if (!selectedTest || selectedMode !== 'part') return;
    const fetchParts = async () => {
      try {
        const res = await apiClient.get(`/tests/${selectedTest.id}/parts`);
        // Sort parts by partNumber
        const sorted = [...res.data].sort((a, b) => a.partNumber - b.partNumber);
        setParts(sorted);
      } catch (err) {
        console.error("Error fetching parts", err);
      }
    };
    fetchParts();
  }, [selectedTest, selectedMode]);

  const handleLogout = () => {
    logout();
    router.push('/login');
  };

  const handleToggleMiniGroups = async (partId) => {
    if (expandedPart === partId) {
      setExpandedPart(null);
      return;
    }
    setExpandedPart(partId);
    if (miniGroups[partId]) return; // already loaded

    setLoadingGroups(prev => ({ ...prev, [partId]: true }));
    try {
      const res = await apiClient.get(`/tests/parts/${partId}/groups`);
      setMiniGroups(prev => ({ ...prev, [partId]: res.data }));
    } catch (err) {
      console.error("Error fetching groups", err);
    } finally {
      setLoadingGroups(prev => ({ ...prev, [partId]: false }));
    }
  };

  const handleSelectSkillPart = async (partNum) => {
    setSelectedSkillPartNumber(partNum);
    setLoadingSkillParts(true);
    setSkillParts([]);
    try {
      const res = await apiClient.get(`/tests/parts/summary?year=${selectedYear}&partNumber=${partNum}`);
      setSkillParts(res.data);
    } catch (err) {
      console.error("Error fetching skill parts", err);
    } finally {
      setLoadingSkillParts(false);
    }
  };

  if (!user) return null;

  const goBack = () => {
    if (selectedTest && selectedMode === 'part') {
      setSelectedTest(null);
      setParts([]);
      setExpandedPart(null);
    } else if (selectedMode === 'skill' && selectedSkillPartNumber) {
      setSelectedSkillPartNumber(null);
      setSkillParts([]);
    } else if (selectedMode === 'skill' && selectedSkillCategory) {
      setSelectedSkillCategory(null);
    } else {
      setSelectedMode(null);
      setSelectedTest(null);
      setParts([]);
      setSelectedSkillCategory(null);
      setSelectedSkillPartNumber(null);
      setSkillParts([]);
    }
  };

  return (
    <div className="premium-container">
      <header className="premium-header">
        <div className="header-brand">
          <span className="gradient-text">TOEIC</span> Master
        </div>
        <nav className="header-nav">
          {(selectedMode || selectedTest) && (
            <button
              onClick={goBack}
              className="nav-item"
              style={{ background: 'transparent', border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '4px', padding: 0 }}
            >
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <line x1="19" y1="12" x2="5" y2="12"></line>
                <polyline points="12 19 5 12 12 5"></polyline>
              </svg>
              Back
            </button>
          )}
          <span className="user-greeting">Hi, {user.name}</span>
          <Link href="/dashboard" className="nav-item">Dashboard</Link>
          <button onClick={handleLogout} className="nav-item btn-logout">Logout</button>
        </nav>
      </header>

      <main className="premium-main">

        {/* Year filter – always visible when mode is selected */}
        {selectedMode && (
          <div style={{ display: 'flex', justifyContent: 'center', marginBottom: '2rem', gap: '0.75rem', flexWrap: 'wrap' }}>
            {years.map(y => (
              <button
                key={y}
                onClick={() => setSelectedYear(y)}
                className="premium-btn"
                style={{
                  padding: '0.5rem 1.25rem',
                  background: selectedYear === y ? 'var(--primary)' : 'rgba(255,255,255,0.05)',
                  border: `1px solid ${selectedYear === y ? 'var(--primary)' : 'var(--border)'}`,
                  color: 'white',
                  fontSize: '0.875rem',
                  fontWeight: 600,
                }}
              >
                {y}
              </button>
            ))}
          </div>
        )}

        {/* Step 1: Choose mode */}
        {!selectedMode ? (
          <div>
            <div className="glass-panel text-center mb-12">
              <h1 className="text-4xl font-extrabold gradient-text">Select Practice Mode</h1>
              <p className="subtitle">Choose how you want to practice today.</p>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: '1.5rem', marginTop: '2rem' }}>
              <div className="premium-card" style={{ cursor: 'pointer' }} onClick={() => setSelectedMode('full')}>
                <div className="card-badge bg-primary">Standard</div>
                <div style={{ fontSize: '2.5rem', marginBottom: '1rem' }}>🎯</div>
                <h2 className="card-title">Full Test</h2>
                <p className="card-desc mb-4">
                  200 questions · 120 minutes · All 7 parts<br />
                  Simulate the real TOEIC experience.
                </p>
                <button className="premium-btn btn-primary mt-auto">Start Full Test</button>
              </div>

              <div className="premium-card" style={{ cursor: 'pointer' }} onClick={() => setSelectedMode('part')}>
                <div className="card-badge bg-secondary">Targeted</div>
                <div style={{ fontSize: '2.5rem', marginBottom: '1rem' }}>🔍</div>
                <h2 className="card-title">Practice by Part</h2>
                <p className="card-desc mb-4">
                  Focus on a specific part from a test.<br />
                  Practice full parts or individual mini-sections.
                </p>
                <button className="premium-btn mt-auto" style={{ background: 'var(--secondary)' }}>Select by Part</button>
              </div>

              <div className="premium-card" style={{ cursor: 'pointer' }} onClick={() => setSelectedMode('skill')}>
                <div className="card-badge" style={{ background: 'rgba(16,185,129,0.2)', color: '#10b981' }}>Skill Focus</div>
                <div style={{ fontSize: '2.5rem', marginBottom: '1rem' }}>🎧</div>
                <h2 className="card-title">Practice by Skill</h2>
                <p className="card-desc mb-4">
                  Focus on Reading or Listening.<br />
                  Target specific parts across all tests.
                </p>
                <button className="premium-btn mt-auto" style={{ background: '#10b981', color: 'white' }}>Select Skill</button>
              </div>
            </div>
          </div>

          /* Step 2 (Full mode): Choose test */
        ) : selectedMode === 'full' && !selectedTest ? (
          <div>
            <div className="glass-panel text-center mb-12">
              <h1 className="text-4xl font-extrabold gradient-text">Choose a Full Test</h1>
              <p className="subtitle">Select a test for {selectedYear}</p>
            </div>

            <div className="grid-2">
              {tests.length > 0 ? tests.map(t => (
                <div key={t.id} className="premium-card" style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }}>
                  <div>
                    <div className="card-badge bg-primary" style={{ marginBottom: '0.5rem' }}>Full · 200 Qs</div>
                    <span style={{ fontSize: '1.1rem', fontWeight: 600 }}>{t.title}</span>
                  </div>
                  <Link href={`/test/${t.id}?mode=full`} className="premium-btn btn-primary" style={{ whiteSpace: 'nowrap' }}>
                    Start
                  </Link>
                </div>
              )) : (
                <p className="text-muted">No full tests available for {selectedYear}.</p>
              )}
            </div>
          </div>

          /* Step 2 (Part mode): Choose test */
        ) : selectedMode === 'part' && !selectedTest ? (
          <div>
            <div className="glass-panel text-center mb-12">
              <h1 className="text-4xl font-extrabold gradient-text">Choose a Test</h1>
              <p className="subtitle">Then select which part to practice from that test</p>
            </div>

            <div className="grid-2">
              {tests.length > 0 ? tests.map(t => (
                <div
                  key={t.id}
                  className="premium-card"
                  style={{ cursor: 'pointer', flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }}
                  onClick={() => setSelectedTest(t)}
                >
                  <div>
                    <div className="card-badge bg-secondary" style={{ marginBottom: '0.5rem' }}>Parts 1-7</div>
                    <span style={{ fontSize: '1.1rem', fontWeight: 600 }}>{t.title}</span>
                  </div>
                  <button className="premium-btn" style={{ background: 'var(--secondary)', color: 'white', whiteSpace: 'nowrap' }}>
                    Select →
                  </button>
                </div>
              )) : (
                <p className="text-muted">No tests available for {selectedYear}.</p>
              )}
            </div>
          </div>

          /* Step 3 (Part mode): Parts of the selected test */
        ) : selectedMode === 'part' && selectedTest ? (
          <div>
            <div className="glass-panel text-center mb-12">
              <h1 className="text-4xl font-extrabold gradient-text">{selectedTest.title}</h1>
              <p className="subtitle">Select a part to practice – or expand to do a mini-section</p>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
              {parts.map(part => {
                const info = PART_INFO[part.partNumber] || { name: part.name, icon: '📚', color: '#666', desc: '' };
                const isExpanded = expandedPart === part.id;
                const groups = miniGroups[part.id] || [];
                const isLoading = loadingGroups[part.id];

                return (
                  <div key={part.id} className="premium-card" style={{ padding: '0', overflow: 'hidden' }}>
                    {/* Part header row */}
                    <div style={{ display: 'flex', alignItems: 'center', gap: '1rem', padding: '1.25rem 1.5rem' }}>
                      <div style={{
                        width: '48px', height: '48px', borderRadius: '12px', flexShrink: 0,
                        background: `${info.color}22`, display: 'flex', alignItems: 'center', justifyContent: 'center',
                        fontSize: '1.5rem'
                      }}>
                        {info.icon}
                      </div>
                      <div style={{ flex: 1, minWidth: 0 }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '0.25rem' }}>
                          <span style={{ fontWeight: 700, fontSize: '1rem', color: 'var(--text-main)' }}>Part {part.partNumber}</span>
                          <span style={{
                            padding: '2px 8px', borderRadius: '9999px', fontSize: '0.7rem', fontWeight: 700,
                            background: `${info.color}22`, color: info.color, textTransform: 'uppercase'
                          }}>{info.name}</span>
                        </div>
                        <p style={{ color: 'var(--text-muted)', fontSize: '0.8rem', margin: 0 }}>{info.desc}</p>
                      </div>
                      <div style={{ display: 'flex', gap: '0.5rem', flexShrink: 0 }}>
                        {/* Mini-test expand button */}
                        <button
                          onClick={() => handleToggleMiniGroups(part.id)}
                          style={{
                            background: isExpanded ? `${info.color}33` : 'rgba(255,255,255,0.05)',
                            border: `1px solid ${isExpanded ? info.color : 'var(--border)'}`,
                            color: isExpanded ? info.color : 'var(--text-muted)',
                            padding: '0.5rem 0.875rem', borderRadius: '8px',
                            cursor: 'pointer', fontSize: '0.8rem', fontWeight: 600,
                            transition: 'all 0.2s',
                          }}
                        >
                          {isExpanded ? '▲ Mini' : '▼ Mini'}
                        </button>
                        {/* Practice full part */}
                        <Link
                          href={`/test/${selectedTest.id}?mode=${part.id}`}
                          className="premium-btn btn-primary"
                          style={{ padding: '0.5rem 1rem', fontSize: '0.85rem', whiteSpace: 'nowrap' }}
                        >
                          Full Part
                        </Link>
                      </div>
                    </div>

                    {/* Mini-sections dropdown */}
                    {isExpanded && (
                      <div style={{ borderTop: '1px solid var(--border)', background: 'rgba(0,0,0,0.2)', padding: '1rem 1.5rem' }}>
                        {isLoading ? (
                          <p style={{ color: 'var(--text-muted)', fontSize: '0.875rem' }}>Loading sections...</p>
                        ) : groups.length === 0 ? (
                          <p style={{ color: 'var(--text-muted)', fontSize: '0.875rem' }}>No mini-sections available.</p>
                        ) : (
                          <div style={{ display: 'flex', flexWrap: 'wrap', gap: '0.5rem' }}>
                            {groups.map(g => (
                              <Link
                                key={g.groupId}
                                href={`/test/${selectedTest.id}?mode=mini&partId=${part.id}&groupId=${g.groupId}`}
                                style={{
                                  display: 'inline-flex', alignItems: 'center', gap: '0.4rem',
                                  padding: '0.375rem 0.875rem', borderRadius: '8px',
                                  background: 'rgba(255,255,255,0.05)', border: '1px solid var(--border)',
                                  color: 'var(--text-main)', fontSize: '0.8rem', fontWeight: 500,
                                  textDecoration: 'none', transition: 'all 0.2s',
                                }}
                                onMouseOver={e => {
                                  e.currentTarget.style.background = `${info.color}22`;
                                  e.currentTarget.style.borderColor = info.color;
                                }}
                                onMouseOut={e => {
                                  e.currentTarget.style.background = 'rgba(255,255,255,0.05)';
                                  e.currentTarget.style.borderColor = 'var(--border)';
                                }}
                              >
                                <span style={{ color: info.color, fontWeight: 700 }}>#{g.groupIndex}</span>
                                <span>Q{g.firstQuestionNumber}{g.questionCount > 1 ? `–${g.lastQuestionNumber}` : ''}</span>
                                {g.hasAudio && <span title="Audio">🔊</span>}
                                {g.hasImage && <span title="Image">🖼️</span>}
                                {g.hasPassage && <span title="Passage">📄</span>}
                                <span style={{ color: 'var(--text-muted)' }}>({g.questionCount}Q)</span>
                              </Link>
                            ))}
                          </div>
                        )}
                      </div>
                    )}
                  </div>
                );
              })}
            </div>
          </div>

          /* Step 2 (Skill mode): Choose Category */
        ) : selectedMode === 'skill' && !selectedSkillCategory ? (
          <div>
            <div className="glass-panel text-center mb-12">
              <h1 className="text-4xl font-extrabold gradient-text">Select a Skill</h1>
              <p className="subtitle">Focus your practice for {selectedYear}</p>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '1.5rem' }}>
              <div className="premium-card" style={{ cursor: 'pointer' }} onClick={() => setSelectedSkillCategory('listening')}>
                <div className="card-badge" style={{ background: 'rgba(139,92,246,0.2)', color: '#8b5cf6' }}>Parts 1-4</div>
                <div style={{ fontSize: '2.5rem', marginBottom: '1rem' }}>🎧</div>
                <h2 className="card-title">Listening</h2>
                <p className="card-desc mb-4">Practice your listening skills with Photos, Q-Response, Conversations, and Short Talks.</p>
                <button className="premium-btn mt-auto" style={{ background: 'var(--secondary)', color: 'white' }}>Focus Listening</button>
              </div>

              <div className="premium-card" style={{ cursor: 'pointer' }} onClick={() => setSelectedSkillCategory('reading')}>
                <div className="card-badge" style={{ background: 'rgba(6,182,212,0.2)', color: '#06b6d4' }}>Parts 5-7</div>
                <div style={{ fontSize: '2.5rem', marginBottom: '1rem' }}>📖</div>
                <h2 className="card-title">Reading</h2>
                <p className="card-desc mb-4">Enhance your reading comprehension with Incomplete Sentences, Text Completion, and Passages.</p>
                <button className="premium-btn mt-auto" style={{ background: '#06b6d4', color: 'white' }}>Focus Reading</button>
              </div>
            </div>
          </div>

          /* Step 3 (Skill mode): Choose Part */
        ) : selectedMode === 'skill' && selectedSkillCategory && !selectedSkillPartNumber ? (
          <div>
            <div className="glass-panel text-center mb-12">
              <h1 className="text-4xl font-extrabold gradient-text">
                {selectedSkillCategory === 'listening' ? 'Listening Parts' : 'Reading Parts'}
              </h1>
              <p className="subtitle">Select the specific part you want to practice</p>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
              {(selectedSkillCategory === 'listening' ? [1, 2, 3, 4] : [5, 6, 7]).map(partNum => {
                const info = PART_INFO[partNum];
                return (
                  <div key={partNum} className="premium-card" style={{ cursor: 'pointer', padding: '1.25rem 1.5rem' }} onClick={() => handleSelectSkillPart(partNum)}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                      <div style={{
                        width: '48px', height: '48px', borderRadius: '12px', flexShrink: 0,
                        background: `${info.color}22`, display: 'flex', alignItems: 'center', justifyContent: 'center',
                        fontSize: '1.5rem'
                      }}>
                        {info.icon}
                      </div>
                      <div style={{ flex: 1 }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '0.25rem' }}>
                          <span style={{ fontWeight: 700, fontSize: '1.1rem', color: 'var(--text-main)' }}>Part {partNum}</span>
                          <span style={{
                            padding: '2px 8px', borderRadius: '9999px', fontSize: '0.75rem', fontWeight: 700,
                            background: `${info.color}22`, color: info.color, textTransform: 'uppercase'
                          }}>{info.name}</span>
                        </div>
                        <p style={{ color: 'var(--text-muted)', fontSize: '0.85rem', margin: 0 }}>{info.desc}</p>
                      </div>
                      <button className="premium-btn" style={{ background: 'rgba(255,255,255,0.05)', color: info.color }}>
                        Select →
                      </button>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>

          /* Step 4 (Skill mode): List of Parts */
        ) : selectedMode === 'skill' && selectedSkillPartNumber ? (
          <div>
            <div className="glass-panel text-center mb-12">
              <h1 className="text-4xl font-extrabold gradient-text">Part {selectedSkillPartNumber}: {PART_INFO[selectedSkillPartNumber]?.name}</h1>
              <p className="subtitle">Available tests from {selectedYear}</p>
            </div>

            {loadingSkillParts ? (
              <p className="text-center text-muted">Loading...</p>
            ) : skillParts.length > 0 ? (
              <div className="grid-2">
                {skillParts.map(p => (
                  <div key={p.partId} className="premium-card" style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }}>
                    <div>
                      <div className="card-badge" style={{ background: `${PART_INFO[selectedSkillPartNumber]?.color}22`, color: PART_INFO[selectedSkillPartNumber]?.color, marginBottom: '0.5rem' }}>
                        Part {selectedSkillPartNumber}
                      </div>
                      <span style={{ fontSize: '1.1rem', fontWeight: 600, display: 'block' }}>{p.testTitle}</span>
                    </div>
                    <Link href={`/test/${p.testId}?mode=${p.partId}`} className="premium-btn" style={{ background: PART_INFO[selectedSkillPartNumber]?.color, color: 'white', whiteSpace: 'nowrap' }}>
                      Practice
                    </Link>
                  </div>
                ))}
              </div>
            ) : (
              <p className="text-center text-muted">No parts available for {selectedYear}.</p>
            )}
          </div>
        ) : null}
      </main>
    </div>
  );
}
