"use client";

import React, { useState, useEffect, useRef } from 'react';
import { useRouter } from 'next/navigation';
import {
  ListeningPicture,
  ListeningResponse,
  ListeningAudioGroup,
  IncompleteSentence,
  ReadingPassageGroup
} from '../../../components/QuestionViews';
import { getUser } from '../../../utils/auth';
import apiClient from '../../../utils/apiClient';
import ConfirmModal from '../../../components/ConfirmModal';
import './iig-simulator.css';

export default function TestSimulator({ params, searchParams }) {
  const router = useRouter();
  const unwrappedParams = React.use(params);
  const unwrappedSearchParams = React.use(searchParams);
  const testId = unwrappedParams.id;
  const mode = unwrappedSearchParams?.mode || "full";
  const miniPartId = unwrappedSearchParams?.partId ? parseInt(unwrappedSearchParams.partId) : null;
  const miniGroupId = unwrappedSearchParams?.groupId ? parseInt(unwrappedSearchParams.groupId) : null;
  const viewAttemptId = unwrappedSearchParams?.attemptId ? parseInt(unwrappedSearchParams.attemptId) : null;

  const isMini = mode === 'mini';
  const isFull = mode === 'full';
  const isPart = !isFull && !isMini;

  const [attemptId, setAttemptId] = useState(null);
  const [allQuestions, setAllQuestions] = useState([]);
  const [fullAudioUrl, setFullAudioUrl] = useState(null);
  const [currentQuestionIndex, setCurrentQuestionIndex] = useState(0);
  const [selections, setSelections] = useState({});
  const [checkedQuestions, setCheckedQuestions] = useState({});
  const [reviewItems, setReviewItems] = useState({});
  const [showQuestionGrid, setShowQuestionGrid] = useState(false);
  const [showSubmitConfirm, setShowSubmitConfirm] = useState(false);
  const [showExitConfirm, setShowExitConfirm] = useState(false);
  const [timeLeft, setTimeLeft] = useState(7200);
  const [isSubmitted, setIsSubmitted] = useState(false);
  const [scoreData, setScoreData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [testTitle, setTestTitle] = useState('');
  const [showResultDetail, setShowResultDetail] = useState(false);

  const startTimeRef = useRef(0);
  const handleSubmitRef = useRef(null);

  useEffect(() => {
    startTimeRef.current = Date.now();
  }, []);

  useEffect(() => {
    const init = async () => {
      const user = getUser();
      if (!user) {
        router.push('/login');
        return;
      }

      try {
        if (viewAttemptId) {
          setAttemptId(viewAttemptId);
          const resultRes = await apiClient.get(`/attempts/${viewAttemptId}/result`);
          setScoreData(resultRes.data);
          setIsSubmitted(true);
          setShowResultDetail(true);
          setLoading(false);
          return;
        }

        // Determine attempt type and part
        let attemptType = 'FULL';
        let attemptPartId = null;
        if (isMini) {
          attemptType = 'PART';
          attemptPartId = miniPartId;
        } else if (isPart) {
          attemptType = 'PART';
          attemptPartId = parseInt(mode); // mode = partId
        }

        const attemptPayload = {
          testId: parseInt(testId),
          attemptType,
          testPartId: attemptPartId,
        };
        const attemptRes = await apiClient.post('/attempts/start', attemptPayload);
        setAttemptId(attemptRes.data.id);

        // Fetch test info
        const testRes = await apiClient.get(`/tests/${testId}`);
        if (testRes.data) {
          setTestTitle(testRes.data.title || `Test ${testId}`);
          if (isFull && testRes.data.fullAudioUrl) {
            setFullAudioUrl(testRes.data.fullAudioUrl);
          }
        }

        // Determine which parts to load
        let partsToFetch = [];
        if (isFull) {
          const partsRes = await apiClient.get(`/tests/${testId}/parts`);
          partsToFetch = partsRes.data.map(p => ({ id: p.id, partNumber: p.partNumber }));
          setTimeLeft(7200);
        } else if (isMini) {
          partsToFetch = [{ id: miniPartId, partNumber: null }];
          setTimeLeft(null);
        } else {
          // Part mode: mode = partId
          const partId = parseInt(mode);
          const partsRes = await apiClient.get(`/tests/${testId}/parts`);
          const currentPart = partsRes.data.find(p => p.id === partId);
          partsToFetch = [{ id: partId, partNumber: currentPart?.partNumber ?? null }];
          setTimeLeft(null);
        }

        // If parts don't have partNumber yet, fetch them
        const resolvedParts = await Promise.all(partsToFetch.map(async (p) => {
          if (p.partNumber !== null) return p;
          const partsRes = await apiClient.get(`/tests/${testId}/parts`);
          const found = partsRes.data.find(tp => tp.id === p.id);
          return { id: p.id, partNumber: found?.partNumber ?? 0 };
        }));

        const typeMap = {
          1: 'picture', 2: 'response', 3: 'conversation', 4: 'talk',
          5: 'incomplete_sentence', 6: 'text_completion', 7: 'passage'
        };

        let questionsFlattened = [];
        for (const part of resolvedParts) {
          const qRes = await apiClient.get(`/tests/parts/${part.id}/questions`);
          const partGroups = qRes.data;
          const qType = typeMap[part.partNumber] || 'incomplete_sentence';
          const sectionTitle = `Part ${part.partNumber}`;

          for (const group of partGroups) {
            // In mini mode, only load questions from the specific group
            if (isMini && group.id !== miniGroupId) continue;

            for (const q of group.questions) {
              let options = [];
              if (qType === 'response') {
                if (q.optionA) options.push(`(A) ${q.optionA}`);
                if (q.optionB) options.push(`(B) ${q.optionB}`);
                if (q.optionC) options.push(`(C) ${q.optionC}`);
              } else {
                if (q.optionA) options.push(`(A) ${q.optionA}`);
                if (q.optionB) options.push(`(B) ${q.optionB}`);
                if (q.optionC) options.push(`(C) ${q.optionC}`);
                if (q.optionD) options.push(`(D) ${q.optionD}`);
              }

              questionsFlattened.push({
                ...q,
                groupId: group.id,
                groupData: group,
                type: qType,
                sectionTitle,
                options: options.length > 0 ? options : null,
                instruction: `Select the best answer for Question ${q.questionNumber}`,
              });
            }
          }
        }

        setAllQuestions(questionsFlattened);
      } catch (err) {
        console.error("Failed to load test", err);
        alert("Failed to load test data.");
      } finally {
        setLoading(false);
      }
    };
    init();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [testId, mode]);

  const handleSubmit = async () => {
    if (!attemptId) return;
    try {
      const durationSeconds = Math.round((Date.now() - startTimeRef.current) / 1000);

      const answersPayload = Object.keys(selections).map(qId => {
        const sel = selections[qId];
        const optLetter = sel ? sel.substring(1, 2) : null;
        return {
          questionId: parseInt(qId),
          selectedOption: optLetter
        };
      });

      // Also add unanswered questions
      const answeredIds = new Set(answersPayload.map(a => a.questionId));
      allQuestions.forEach(q => {
        if (!answeredIds.has(q.id)) {
          answersPayload.push({ questionId: q.id, selectedOption: null });
        }
      });

      await apiClient.post(`/attempts/${attemptId}/submit`, {
        durationSeconds,
        answers: answersPayload
      });

      // Fetch full result
      const resultRes = await apiClient.get(`/attempts/${attemptId}/result`);
      setScoreData(resultRes.data);
      setIsSubmitted(true);
    } catch (err) {
      console.error("Submit failed", err);
      alert("Failed to submit test.");
    }
  };

  useEffect(() => {
    handleSubmitRef.current = handleSubmit;
  });

  useEffect(() => {
    if (loading || isSubmitted || timeLeft === null) return;
    const timer = setInterval(() => {
      setTimeLeft(prev => {
        if (prev <= 1) {
          clearInterval(timer);
          if (handleSubmitRef.current) handleSubmitRef.current();
          return 0;
        }
        return prev - 1;
      });
    }, 1000);
    return () => clearInterval(timer);
  }, [loading, isSubmitted, timeLeft]);

  if (loading) return (
    <div className="iig-page" style={{ alignItems: 'center', justifyContent: 'center' }}>
      <div style={{ textAlign: 'center', color: '#00205c' }}>
        <div style={{ fontSize: '2rem', marginBottom: '1rem' }}>⏳</div>
        <p style={{ fontSize: '1.1rem', fontWeight: 600 }}>Loading Test Environment...</p>
      </div>
    </div>
  );

  if (allQuestions.length === 0) return (
    <div className="iig-page" style={{ alignItems: 'center', justifyContent: 'center' }}>
      <div style={{ textAlign: 'center', color: '#00205c' }}>
        <div style={{ fontSize: '2rem', marginBottom: '1rem' }}>😕</div>
        <p>No questions found for this section.</p>
        <button className="iig-modal-btn iig-btn-finish" style={{ marginTop: '1rem' }} onClick={() => router.push('/tests')}>Go Back</button>
      </div>
    </div>
  );

  // ─── RESULT PAGE ───────────────────────────────────────────────────────────
  if (isSubmitted && scoreData) {
    const listeningScore = scoreData.listeningScore ?? 0;
    const readingScore = scoreData.readingScore ?? 0;
    const totalCorrect = scoreData.totalCorrect ?? 0;
    const totalIncorrect = scoreData.totalIncorrect ?? 0;
    const totalUnanswered = scoreData.totalUnanswered ?? 0;
    const totalQuestions = totalCorrect + totalIncorrect + totalUnanswered;
    const accuracy = totalQuestions > 0 ? Math.round((totalCorrect / totalQuestions) * 100) : 0;

    const listeningTotal = listeningScore + (scoreData.questionResults?.filter(q => q.partNumber <= 4 && !q.isCorrect).length || 0);
    const readingTotal = readingScore + (scoreData.questionResults?.filter(q => q.partNumber > 4 && !q.isCorrect).length || 0);
    const listeningPct = listeningTotal > 0 ? Math.round(listeningScore / listeningTotal * 100) : 0;
    const readingPct = readingTotal > 0 ? Math.round(readingScore / readingTotal * 100) : 0;

    // Group results by part
    const resultsByPart = {};
    (scoreData.questionResults || []).forEach(q => {
      const p = q.partNumber || 0;
      if (!resultsByPart[p]) resultsByPart[p] = { correct: 0, incorrect: 0, unanswered: 0 };
      if (q.selectedOption == null || q.selectedOption === '') resultsByPart[p].unanswered++;
      else if (q.isCorrect) resultsByPart[p].correct++;
      else resultsByPart[p].incorrect++;
    });

    return (
      <div className="iig-result-page">
        <header className="iig-header" style={{ justifyContent: 'center', position: 'relative' }}>
          <div className="iig-header-left" style={{ position: 'absolute', left: '1rem', padding: '4px 12px 4px 6px' }}>
            <button
              onClick={() => router.push('/dashboard')}
              title="Back to Dashboard"
              style={{ background: 'none', border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', color: '#00205c', paddingRight: '8px', borderRight: '2px solid #e0e0e0', marginRight: '8px', transition: 'color 0.2s' }}
              onMouseOver={e => e.currentTarget.style.color = '#f58220'}
              onMouseOut={e => e.currentTarget.style.color = '#00205c'}
            >
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                <line x1="19" y1="12" x2="5" y2="12"></line>
                <polyline points="12 19 5 12 12 5"></polyline>
              </svg>
            </button>
            <span style={{ color: '#00205c' }}>pkucpkam</span> <span style={{ color: '#f58220', marginLeft: '4px' }}>TOEIC</span>
          </div>
          <div style={{ fontSize: '1.25rem', fontWeight: 'bold' }}>Result</div>
        </header>

        <main className="iig-result-main">
          <h2 className="iig-result-title">{scoreData.testTitle?.toUpperCase()}</h2>

          {/* Accuracy banner */}
          <div style={{ display: 'flex', justifyContent: 'center', gap: '2rem', marginBottom: '2rem', flexWrap: 'wrap' }}>
            {[
              { label: 'Correct', value: totalCorrect, color: '#4caf50' },
              { label: 'Incorrect', value: totalIncorrect, color: '#f44336' },
              { label: 'Unanswered', value: totalUnanswered, color: '#9e9e9e' },
              { label: 'Accuracy', value: `${accuracy}%`, color: '#f58220' },
            ].map(item => (
              <div key={item.label} style={{ textAlign: 'center', minWidth: '80px' }}>
                <div style={{ fontSize: '2rem', fontWeight: 800, color: item.color }}>{item.value}</div>
                <div style={{ fontSize: '0.8rem', textTransform: 'uppercase', letterSpacing: '1px', color: '#666', fontWeight: 600 }}>{item.label}</div>
              </div>
            ))}
          </div>

          {/* Score cards */}
          {(scoreData.attemptType === 'FULL' || isFull) ? (
            <>
              <div className="iig-score-card">
                <div className="iig-score-label">Total Correct: {totalCorrect} / {totalQuestions}</div>
                <div className="iig-slider-container">
                  <span>0</span>
                  <div className="iig-slider-track">
                    <div className="iig-slider-fill" style={{ width: `${accuracy}%` }}></div>
                    <div className="iig-slider-thumb" style={{ left: `${accuracy}%` }}></div>
                  </div>
                  <span>{totalQuestions}</span>
                </div>
                <div style={{ textAlign: 'left', marginTop: '-10px', color: '#00205c', fontWeight: 'bold' }}>TOTAL</div>
              </div>

              <div className="iig-skill-cards">
                {/* Listening */}
                <div className="iig-skill-card">
                  <div className="iig-skill-header iig-skill-listening">🎧 Listening</div>
                  <div className="iig-skill-body">
                    <div className="iig-skill-score">Correct: {listeningScore}</div>
                    <div style={{ position: 'relative', height: '40px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', fontSize: '0.9rem', fontWeight: 'bold', margin: '0 1rem 1rem' }}>
                      <span>0</span>
                      <div className="iig-slider-track" style={{ left: '1.5rem', right: '2rem' }}>
                        <div className="iig-skill-fill" style={{ width: `${listeningPct}%` }}></div>
                        <div className="iig-skill-thumb" style={{ left: `${listeningPct}%` }}></div>
                      </div>
                      <span>{listeningTotal}</span>
                    </div>
                    <div style={{ display: 'flex', justifyContent: 'space-around', padding: '0 1rem 1rem' }}>
                      {[1, 2, 3, 4].map(p => {
                        const s = resultsByPart[p];
                        if (!s) return null;
                        const acc = (s.correct + s.incorrect) > 0 ? Math.round(s.correct / (s.correct + s.incorrect) * 100) : 0;
                        return (
                          <div key={p} style={{ textAlign: 'center' }}>
                            <div style={{ fontSize: '0.75rem', color: '#666', marginBottom: '2px' }}>P{p}</div>
                            <div style={{ fontSize: '0.9rem', fontWeight: 700, color: acc >= 70 ? '#4caf50' : acc >= 40 ? '#f59e0b' : '#f44336' }}>{acc}%</div>
                          </div>
                        );
                      })}
                    </div>
                  </div>
                </div>

                {/* Reading */}
                <div className="iig-skill-card">
                  <div className="iig-skill-header iig-skill-reading">📖 Reading</div>
                  <div className="iig-skill-body">
                    <div className="iig-skill-score">Correct: {readingScore}</div>
                    <div style={{ position: 'relative', height: '40px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', fontSize: '0.9rem', fontWeight: 'bold', margin: '0 1rem 1rem' }}>
                      <span>0</span>
                      <div className="iig-slider-track" style={{ left: '1.5rem', right: '2rem' }}>
                        <div className="iig-skill-fill" style={{ width: `${readingPct}%` }}></div>
                        <div className="iig-skill-thumb" style={{ left: `${readingPct}%` }}></div>
                      </div>
                      <span>{readingTotal}</span>
                    </div>
                    <div style={{ display: 'flex', justifyContent: 'space-around', padding: '0 1rem 1rem' }}>
                      {[5, 6, 7].map(p => {
                        const s = resultsByPart[p];
                        if (!s) return null;
                        const acc = (s.correct + s.incorrect) > 0 ? Math.round(s.correct / (s.correct + s.incorrect) * 100) : 0;
                        return (
                          <div key={p} style={{ textAlign: 'center' }}>
                            <div style={{ fontSize: '0.75rem', color: '#666', marginBottom: '2px' }}>P{p}</div>
                            <div style={{ fontSize: '0.9rem', fontWeight: 700, color: acc >= 70 ? '#4caf50' : acc >= 40 ? '#f59e0b' : '#f44336' }}>{acc}%</div>
                          </div>
                        );
                      })}
                    </div>
                  </div>
                </div>
              </div>
            </>
          ) : (
            /* Part / Mini result */
            <div className="iig-score-card">
              <div className="iig-score-label">Result: {totalCorrect} / {totalQuestions} correct</div>
              <div className="iig-slider-container">
                <span>0</span>
                <div className="iig-slider-track">
                  <div className="iig-slider-fill" style={{ width: `${accuracy}%` }}></div>
                  <div className="iig-slider-thumb" style={{ left: `${accuracy}%` }}></div>
                </div>
                <span>{totalQuestions}</span>
              </div>
              <div style={{ textAlign: 'left', marginTop: '-10px', color: '#00205c', fontWeight: 'bold' }}>{accuracy}% Accuracy</div>
            </div>
          )}

          {/* Review answers section */}
          <div style={{ marginTop: '2rem' }}>
            <button
              onClick={() => setShowResultDetail(!showResultDetail)}
              style={{
                width: '100%', padding: '0.875rem', background: showResultDetail ? '#00205c' : 'white',
                border: '2px solid #00205c', borderRadius: '8px', cursor: 'pointer',
                fontWeight: 700, fontSize: '1rem', color: showResultDetail ? 'white' : '#00205c',
                transition: 'all 0.2s', marginBottom: '1rem'
              }}
            >
              {showResultDetail ? '▲ Hide Answer Review' : '▼ Review Answers with Explanation'}
            </button>

            {showResultDetail && (
              <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
                {(scoreData.questionResults || []).map((q, idx) => (
                  <div key={q.questionId} style={{
                    background: 'white', border: `2px solid ${q.isCorrect ? '#4caf50' : (q.selectedOption ? '#f44336' : '#9e9e9e')}`,
                    borderRadius: '8px', padding: '1.25rem', fontSize: '0.9rem',
                    overflowWrap: 'break-word', wordBreak: 'normal'
                  }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '0.5rem' }}>
                      <span style={{ fontWeight: 700, color: '#00205c' }}>Q{q.questionNumber} · {q.partTitle}</span>
                      <span style={{
                        fontWeight: 700,
                        color: q.isCorrect ? '#4caf50' : (q.selectedOption ? '#f44336' : '#9e9e9e')
                      }}>
                        {q.isCorrect ? '✓ Correct' : (q.selectedOption ? '✗ Incorrect' : '— Skipped')}
                      </span>
                    </div>
                    {q.questionText && (
                      <p style={{ marginBottom: '0.75rem', color: '#333', fontWeight: 500, overflowWrap: 'break-word', wordBreak: 'normal' }}>{q.questionText}</p>
                    )}
                    <div style={{ display: 'flex', gap: '1rem', flexWrap: 'wrap', marginBottom: '0.75rem' }}>
                      {['A', 'B', 'C', 'D'].map(letter => {
                        const optText = q[`option${letter}`];
                        if (!optText) return null;
                        const isCorrectAns = q.correctAnswer === letter;
                        const isUserAns = q.selectedOption === letter;
                        return (
                          <div key={letter} style={{
                            padding: '0.375rem 0.75rem', borderRadius: '6px', fontSize: '0.85rem',
                            background: isCorrectAns ? '#e8f5e9' : isUserAns ? '#ffebee' : '#f5f5f5',
                            border: `1px solid ${isCorrectAns ? '#4caf50' : isUserAns ? '#f44336' : '#e0e0e0'}`,
                            fontWeight: isCorrectAns || isUserAns ? 700 : 400,
                            color: isCorrectAns ? '#2e7d32' : isUserAns ? '#c62828' : '#555',
                            overflowWrap: 'break-word', wordBreak: 'normal', maxWidth: '100%'
                          }}>
                            ({letter}) {optText}
                            {isCorrectAns && ' ✓'}
                            {isUserAns && !isCorrectAns && ' ✗'}
                          </div>
                        );
                      })}
                    </div>
                    {q.explanation && (
                      <div style={{
                        background: '#e8f5e9', border: '1px solid #c8e6c9', padding: '1rem',
                        borderRadius: '8px', color: '#2e7d32', fontSize: '0.9rem', marginTop: '0.75rem',
                        overflowWrap: 'break-word', wordBreak: 'normal'
                      }}>
                        <div style={{ fontWeight: 700, marginBottom: '0.75rem', fontSize: '0.95rem' }}>💡 Explanation:</div>
                        {q.explanation.split('\n').map((line, i) => {
                          const match = line.trim().match(/^([A-D])\s+(.*)/);
                          if (match) {
                            return (
                              <div key={i} style={{ marginBottom: '0.5rem', lineHeight: '1.5', display: 'flex', gap: '0.5rem', overflowWrap: 'break-word', wordBreak: 'normal' }}>
                                <span style={{ fontWeight: 'bold', background: '#c8e6c9', color: '#1b5e20', padding: '0 6px', borderRadius: '4px', height: 'fit-content', flexShrink: 0 }}>
                                  {match[1]}
                                </span>
                                <span style={{ flex: 1, minWidth: 0, overflowWrap: 'break-word', wordBreak: 'normal' }}>{match[2]}</span>
                              </div>
                            );
                          }
                          return <div key={i} style={{ marginBottom: '0.5rem', lineHeight: '1.5', overflowWrap: 'break-word', wordBreak: 'normal' }}>{line}</div>;
                        })}
                      </div>
                    )}
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* Action buttons */}
          <div style={{ display: 'flex', justifyContent: 'center', gap: '1rem', marginTop: '2rem', flexWrap: 'wrap' }}>
            <button className="iig-modal-btn iig-btn-review" onClick={() => router.push('/tests')}>
              Practice Again
            </button>
            <button className="iig-modal-btn iig-btn-finish" onClick={() => router.push('/dashboard')}>
              Dashboard
            </button>
          </div>
        </main>
      </div>
    );
  }

  // ─── TEST UI ────────────────────────────────────────────────────────────────
  const formatTime = (seconds) => {
    const h = Math.floor(seconds / 3600).toString().padStart(2, '0');
    const m = Math.floor((seconds % 3600) / 60).toString().padStart(2, '0');
    const s = (seconds % 60).toString().padStart(2, '0');
    return `${h}:${m}:${s}`;
  };

  const currentQInfo = allQuestions[currentQuestionIndex];
  let viewQuestions = [currentQInfo];
  let currentGroup = currentQInfo.groupData;

  if (currentQInfo.groupId) {
    viewQuestions = allQuestions.filter(q => q.groupId === currentQInfo.groupId);
  }

  const handleSelectOption = (qId, option) => {
    setSelections(prev => ({ ...prev, [qId]: option }));
  };

  const handleCheckAnswer = (qIds) => {
    if (Array.isArray(qIds)) {
      setCheckedQuestions(prev => {
        const next = { ...prev };
        qIds.forEach(id => { next[id] = true; });
        return next;
      });
    } else {
      setCheckedQuestions(prev => ({ ...prev, [qIds]: true }));
    }
  };

  const handleToggleReview = () => {
    setReviewItems(prev => ({ ...prev, [currentQInfo.id]: !prev[currentQInfo.id] }));
  };

  const handleNext = () => {
    if (currentQInfo.groupId) {
      const lastQIndex = allQuestions.findLastIndex(q => q.groupId === currentQInfo.groupId);
      if (lastQIndex < allQuestions.length - 1) setCurrentQuestionIndex(lastQIndex + 1);
    } else {
      if (currentQuestionIndex < allQuestions.length - 1) setCurrentQuestionIndex(prev => prev + 1);
    }
  };

  const handlePrev = () => {
    if (currentQInfo.groupId) {
      const firstQIndex = allQuestions.findIndex(q => q.groupId === currentQInfo.groupId);
      if (firstQIndex > 0) {
        const targetQIndex = firstQIndex - 1;
        const targetQ = allQuestions[targetQIndex];
        const targetFirstQIndex = allQuestions.findIndex(q => q.groupId === targetQ.groupId);
        setCurrentQuestionIndex(targetFirstQIndex >= 0 ? targetFirstQIndex : targetQIndex);
      }
    } else {
      if (currentQuestionIndex > 0) {
        const targetQIndex = currentQuestionIndex - 1;
        const targetQ = allQuestions[targetQIndex];
        const targetFirstQIndex = allQuestions.findIndex(q => q.groupId === targetQ.groupId);
        setCurrentQuestionIndex(targetFirstQIndex >= 0 ? targetFirstQIndex : targetQIndex);
      }
    }
  };

  const answeredCount = Object.keys(selections).length;
  const isReviewed = reviewItems[currentQInfo.id];

  const renderView = () => {
    const practiceMode = isFull ? 'full' : 'practice';
    const props = { selectedOption: selections[currentQInfo.id], onSelectOption: handleSelectOption, mode: practiceMode, checkedQuestions, onCheckAnswer: handleCheckAnswer };
    const groupProps = { selections, onSelectOption: handleSelectOption, mode: practiceMode, checkedQuestions, onCheckAnswer: handleCheckAnswer };

    if (currentQInfo.type === 'picture') return <ListeningPicture question={currentQInfo} {...props} />;
    if (currentQInfo.type === 'response') return <ListeningResponse question={currentQInfo} {...props} />;
    if (currentQInfo.type === 'conversation' || currentQInfo.type === 'talk') return <ListeningAudioGroup questions={viewQuestions} group={currentGroup} {...groupProps} />;
    if (currentQInfo.type === 'incomplete_sentence') return <IncompleteSentence question={currentQInfo} {...props} />;
    if (currentQInfo.type === 'text_completion' || currentQInfo.type === 'passage') return <ReadingPassageGroup questions={viewQuestions} group={currentGroup} {...groupProps} />;
    return <div>Unknown Question Type</div>;
  };

  // Mode label
  const modeLabel = isFull ? 'Full Test' : isMini ? 'Mini-Section' : 'Part Practice';

  return (
    <div className="iig-page">
      <header className="iig-header">
        <div className="iig-header-left" style={{ padding: '4px 12px 4px 6px' }}>
          <button
            onClick={() => setShowExitConfirm(true)}
            title="Back"
            style={{ background: 'none', border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', color: '#00205c', paddingRight: '8px', borderRight: '2px solid #e0e0e0', marginRight: '8px', transition: 'color 0.2s' }}
            onMouseOver={e => e.currentTarget.style.color = '#f58220'}
            onMouseOut={e => e.currentTarget.style.color = '#00205c'}
          >
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
              <line x1="19" y1="12" x2="5" y2="12"></line>
              <polyline points="12 19 5 12 12 5"></polyline>
            </svg>
          </button>
          <span style={{ color: '#00205c' }}>pkucpkam</span> <span style={{ color: '#f58220', marginLeft: '4px' }}>TOEIC</span>
        </div>
        <div className="iig-header-center">
          {currentQInfo.sectionTitle} · Q{currentQuestionIndex + 1}/{allQuestions.length}
        </div>
        <div className="iig-header-right">
          <div className="iig-progress-box">{answeredCount}/{allQuestions.length} answered</div>
          {isFull ? (
            <>
              <div className={`iig-timer-box ${timeLeft < 300 ? 'timer-urgent' : ''}`}>
                ⏱ {formatTime(timeLeft)}
              </div>
              <button className="iig-submit-btn" onClick={() => setShowSubmitConfirm(true)}>Submit</button>
            </>
          ) : (
            <>
              <div className="iig-progress-box" style={{ background: '#e3f2fd', color: '#0277bd' }}>{modeLabel}</div>
              <button className="iig-submit-btn" onClick={() => setShowSubmitConfirm(true)}>Submit</button>
            </>
          )}
        </div>
      </header>

      <main className="iig-main">
        {isFull && fullAudioUrl && (
          <div style={{ marginBottom: '1rem', display: 'flex', justifyContent: 'center' }}>
            <audio src={`${process.env.NEXT_PUBLIC_API_URL}/media/${fullAudioUrl}`} controls autoPlay style={{ width: '100%', maxWidth: '800px' }}>
              Your browser does not support the audio element.
            </audio>
          </div>
        )}
        {renderView()}
      </main>

      {/* Question Grid Popup */}
      {showQuestionGrid && (
        <div style={{ position: 'fixed', bottom: '70px', right: '20px', background: 'white', border: '1px solid #ccc', borderRadius: '4px', padding: '1rem', boxShadow: '0 -2px 10px rgba(0,0,0,0.2)', zIndex: 100, width: '320px', maxHeight: '400px', overflowY: 'auto' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '1rem', alignItems: 'center' }}>
            <h3 style={{ margin: 0, color: '#00205c', fontSize: '1.1rem' }}>Question List</h3>
            <button onClick={() => setShowQuestionGrid(false)} style={{ background: 'none', border: 'none', cursor: 'pointer', fontSize: '1rem', color: '#666' }}>✖</button>
          </div>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: '6px' }}>
            {allQuestions.map((q, idx) => {
              const isAnswered = !!selections[q.id];
              const isCurrentGroup = q.groupId ? q.groupId === currentQInfo.groupId : idx === currentQuestionIndex;
              const isMarked = reviewItems[q.id];
              return (
                <button
                  key={q.id}
                  onClick={() => {
                    let targetIdx = idx;
                    if (q.groupId) targetIdx = allQuestions.findIndex(allQ => allQ.groupId === q.groupId);
                    setCurrentQuestionIndex(targetIdx >= 0 ? targetIdx : idx);
                    setShowQuestionGrid(false);
                  }}
                  style={{
                    width: '36px', height: '36px', display: 'flex', alignItems: 'center', justifyContent: 'center',
                    border: `2px solid ${isCurrentGroup ? '#f58220' : (isAnswered ? '#4caf50' : '#e0e0e0')}`,
                    background: isCurrentGroup ? '#fff3e0' : (isMarked ? '#fff9c4' : (isAnswered ? '#e8f5e9' : 'white')),
                    cursor: 'pointer', fontWeight: isCurrentGroup ? 'bold' : 'normal',
                    fontSize: '0.85rem', borderRadius: '4px', position: 'relative'
                  }}
                >
                  {q.questionNumber}
                  {isMarked && <span style={{ position: 'absolute', top: '-4px', right: '-4px', fontSize: '0.5rem' }}>🚩</span>}
                </button>
              );
            })}
          </div>
          <div style={{ marginTop: '0.75rem', display: 'flex', gap: '0.5rem', fontSize: '0.75rem', color: '#666' }}>
            <span style={{ display: 'flex', alignItems: 'center', gap: '3px' }}><span style={{ width: '12px', height: '12px', background: '#e8f5e9', border: '1px solid #4caf50', display: 'inline-block' }}></span>Answered</span>
            <span style={{ display: 'flex', alignItems: 'center', gap: '3px' }}><span style={{ width: '12px', height: '12px', background: '#fff9c4', border: '1px solid #ccc', display: 'inline-block' }}></span>Marked</span>
          </div>
        </div>
      )}

      {/* Submit Confirm Modal */}
      {showSubmitConfirm && (
        <div className="iig-modal-overlay">
          <div className="iig-modal-content">
            <div className="iig-modal-title">SUBMIT TEST?</div>
            <div className="iig-modal-subtitle">
              {answeredCount}/{allQuestions.length} questions answered.
              {allQuestions.length - answeredCount > 0 && ` ${allQuestions.length - answeredCount} unanswered.`}
            </div>

            <div className="iig-modal-body">
              {['Listening', 'Reading'].map(skill => {
                const parts = skill === 'Listening' ? [1, 2, 3, 4] : [5, 6, 7];
                const skillQuestions = allQuestions.filter(q => {
                  const ptMatch = q.sectionTitle.match(/Part (\d+)/);
                  const ptNum = ptMatch ? parseInt(ptMatch[1]) : 0;
                  return parts.includes(ptNum);
                });
                if (skillQuestions.length === 0) return null;
                return (
                  <div key={skill}>
                    <div className="iig-modal-section">{skill}</div>
                    {parts.map(ptNum => {
                      const partQuestions = skillQuestions.filter(q => q.sectionTitle === `Part ${ptNum}`);
                      if (partQuestions.length === 0) return null;
                      const partAnswered = partQuestions.filter(q => selections[q.id]).length;
                      return (
                        <div key={ptNum} className="iig-modal-part">
                          <div className="iig-modal-part-title">Part {ptNum} ({partAnswered}/{partQuestions.length})</div>
                          <div className="iig-modal-grid">
                            {partQuestions.map(q => {
                              const isAnswered = !!selections[q.id];
                              return (
                                <div key={q.id} style={{
                                  width: '32px', height: '32px', display: 'flex', alignItems: 'center', justifyContent: 'center',
                                  background: isAnswered ? '#e0e0e0' : '#f58220',
                                  color: isAnswered ? '#555' : 'white',
                                  fontSize: '0.85rem', fontWeight: 'bold', borderRadius: '4px'
                                }}>
                                  {q.questionNumber}
                                </div>
                              );
                            })}
                          </div>
                        </div>
                      );
                    })}
                  </div>
                );
              })}
            </div>

            <div style={{ display: 'flex', justifyContent: 'center', gap: '1rem', marginTop: '1.5rem' }}>
              <button className="iig-modal-btn iig-btn-review" onClick={() => setShowSubmitConfirm(false)}>Review</button>
              <button className="iig-modal-btn iig-btn-finish" onClick={() => { setShowSubmitConfirm(false); handleSubmit(); }}>
                Finish Test
              </button>
            </div>
          </div>
        </div>
      )}

      <ConfirmModal
        isOpen={showExitConfirm}
        title="Leave Test?"
        message="Are you sure you want to leave? Your progress will not be saved."
        confirmText="Leave"
        cancelText="Stay"
        type="danger"
        onConfirm={() => router.push('/tests')}
        onCancel={() => setShowExitConfirm(false)}
      />

      <footer className="iig-footer">
        <div className="iig-footer-left">
          <input
            type="checkbox"
            id="markReview"
            checked={!!isReviewed}
            onChange={handleToggleReview}
          />
          <label htmlFor="markReview" style={{ cursor: 'pointer' }}>
            {isReviewed ? '🚩 Marked for Review' : 'Mark for Review'}
          </label>
        </div>
        <div className="iig-footer-right">
          <button className="iig-list-btn" onClick={() => setShowQuestionGrid(!showQuestionGrid)}>☰</button>
          <button className="iig-nav-btn" onClick={handlePrev} disabled={currentQuestionIndex === 0}>&lt;</button>
          <button className="iig-nav-btn" onClick={handleNext} disabled={currentQuestionIndex === allQuestions.length - 1}>&gt;</button>
        </div>
      </footer>
    </div>
  );
}
