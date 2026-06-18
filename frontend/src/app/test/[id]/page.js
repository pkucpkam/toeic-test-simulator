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
import './iig-simulator.css';

export default function TestSimulator({ params, searchParams }) {
  const router = useRouter();
  const unwrappedParams = React.use(params);
  const unwrappedSearchParams = React.use(searchParams);
  const testId = unwrappedParams.id;
  const mode = unwrappedSearchParams?.mode || "full";
  
  const [attemptId, setAttemptId] = useState(null);
  const [allQuestions, setAllQuestions] = useState([]);
  const [fullAudioUrl, setFullAudioUrl] = useState(null);
  const [currentQuestionIndex, setCurrentQuestionIndex] = useState(0);
  const [selections, setSelections] = useState({});
  const [checkedQuestions, setCheckedQuestions] = useState({});
  const [reviewItems, setReviewItems] = useState({});
  const [showQuestionGrid, setShowQuestionGrid] = useState(false);
  const [showSubmitConfirm, setShowSubmitConfirm] = useState(false);
  const [timeLeft, setTimeLeft] = useState(7200);
  const [isSubmitted, setIsSubmitted] = useState(false);
  const [scoreData, setScoreData] = useState(null);
  const [loading, setLoading] = useState(true);

  const handleSubmitRef = useRef(null);

  useEffect(() => {
    const init = async () => {
      const user = getUser();
      if (!user) {
         router.push('/login');
         return;
      }

      try {
        const attemptPayload = {
           testId: parseInt(testId),
           attemptType: mode === 'full' ? 'FULL' : 'PART',
           testPartId: mode === 'full' ? null : parseInt(mode)
        };
        const attemptRes = await apiClient.post('/attempts/start', attemptPayload);
        setAttemptId(attemptRes.data.id);

        let partsToFetch = [];
        if (mode === 'full') {
           const partsRes = await apiClient.get(`/tests/${testId}/parts`);
           partsToFetch = partsRes.data.map(p => p.id);
           setTimeLeft(7200);
           
           const testRes = await apiClient.get(`/tests/${testId}`);
           if (testRes.data && testRes.data.fullAudioUrl) {
               setFullAudioUrl(testRes.data.fullAudioUrl);
           }
        } else {
           partsToFetch = [parseInt(mode)];
           setTimeLeft(null);
        }

        let questionsFlattened = [];
        for (const pId of partsToFetch) {
           const qRes = await apiClient.get(`/tests/parts/${pId}/questions`);
           const partGroups = qRes.data;
           
           const partsResAll = await apiClient.get(`/tests/${testId}/parts`);
           const currentPart = partsResAll.data.find(p => p.id === pId);
           const partNumber = currentPart ? currentPart.partNumber : 1;

           const typeMap = {
              1: 'picture', 2: 'response', 3: 'conversation', 4: 'talk',
              5: 'incomplete_sentence', 6: 'text_completion', 7: 'passage'
           };
           const qType = typeMap[partNumber];
           const sectionTitle = `Part ${partNumber}`;

           partGroups.forEach(group => {
              group.questions.forEach(q => {
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
                    sectionTitle: sectionTitle,
                    options: options.length > 0 ? options : null,
                    instruction: `Select the best answer for Question ${q.questionNumber}`
                 });
              });
           });
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
  }, [testId, mode, router]);

  const handleSubmit = async () => {
    if (!attemptId) return;
    try {
       const answersPayload = Object.keys(selections).map(qId => {
          const sel = selections[qId];
          const optLetter = sel ? sel.substring(1, 2) : null; 
          return {
             questionId: parseInt(qId),
             selectedOption: optLetter
          };
       });

       const res = await apiClient.post(`/attempts/${attemptId}/submit`, answersPayload);
       setScoreData(res.data);
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

  if (loading) return <div className="premium-container text-center mt-8"><p>Loading Test Environment...</p></div>;
  if (allQuestions.length === 0) return <div className="premium-container text-center mt-8"><p>No questions found.</p></div>;

  if (isSubmitted && scoreData) {
    const listScore = scoreData.listeningScore || 0;
    const readScore = scoreData.readingScore || 0;
    const totalScore = scoreData.totalScore || 0;

    const listPercent = Math.min(100, Math.max(0, (listScore / 495) * 100));
    const readPercent = Math.min(100, Math.max(0, (readScore / 495) * 100));
    const totalPercent = Math.min(100, Math.max(0, (totalScore / 990) * 100));

    return (
      <div className="iig-result-page">
        <header className="iig-header" style={{ justifyContent: 'center', position: 'relative' }}>
          <div className="iig-header-left" style={{ position: 'absolute', left: '1rem' }}>
            <span style={{ color: '#00205c' }}>pkucpkam</span> <span style={{ color: '#f58220', marginLeft: '4px' }}>TOEIC</span>
          </div>
          <div style={{ fontSize: '1.25rem', fontWeight: 'bold' }}>Result</div>
        </header>
        
        <main className="iig-result-main">
          <h2 className="iig-result-title">THI THỬ ONLINE TOEIC - ĐỀ {testId}</h2>
          
          <div className="iig-score-card">
            <div className="iig-score-label">Your score: {totalScore}</div>
            <div className="iig-slider-container">
              <span>0</span>
              <div className="iig-slider-track">
                <div className="iig-slider-fill" style={{ width: `${totalPercent}%` }}></div>
                <div className="iig-slider-thumb" style={{ left: `${totalPercent}%` }}></div>
              </div>
              <span>990</span>
            </div>
            <div style={{ textAlign: 'left', marginTop: '-10px', color: '#00205c', fontWeight: 'bold' }}>TOTAL</div>
          </div>
          
          <div className="iig-skill-cards">
            <div className="iig-skill-card">
              <div className="iig-skill-header iig-skill-listening">
                🎧 Listening
              </div>
              <div className="iig-skill-body">
                <div className="iig-skill-score">Your score: {listScore}</div>
                <div style={{ position: 'relative', height: '40px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', fontSize: '0.9rem', fontWeight: 'bold', margin: '0 1rem 1rem 1rem' }}>
                  <span>0</span>
                  <div className="iig-slider-track" style={{ left: '1.5rem', right: '2rem' }}>
                     <div className="iig-skill-fill" style={{ width: `${listPercent}%` }}></div>
                     <div className="iig-skill-thumb" style={{ left: `${listPercent}%` }}></div>
                  </div>
                  <span>495</span>
                </div>
                <ul className="iig-skill-bullets">
                  <li>You can sometimes infer the central idea, purpose, and basic context of short spoken exchanges.</li>
                  <li>You can understand details in short spoken exchanges when easy or medium-level vocabulary is used.</li>
                  <li>You can understand details in extended spoken texts when the information is supported by repetition.</li>
                </ul>
              </div>
            </div>

            <div className="iig-skill-card">
              <div className="iig-skill-header iig-skill-reading">
                📖 Reading
              </div>
              <div className="iig-skill-body">
                <div className="iig-skill-score">Your score: {readScore}</div>
                <div style={{ position: 'relative', height: '40px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', fontSize: '0.9rem', fontWeight: 'bold', margin: '0 1rem 1rem 1rem' }}>
                  <span>0</span>
                  <div className="iig-slider-track" style={{ left: '1.5rem', right: '2rem' }}>
                     <div className="iig-skill-fill" style={{ width: `${readPercent}%` }}></div>
                     <div className="iig-skill-thumb" style={{ left: `${readPercent}%` }}></div>
                  </div>
                  <span>495</span>
                </div>
                <ul className="iig-skill-bullets">
                  <li>You can understand very familiar everyday words.</li>
                  <li>You can understand some most-common, rule-based grammatical constructions.</li>
                  <li>You can catch the basic idea of very short and simple texts such as restaurant menus.</li>
                </ul>
              </div>
            </div>
          </div>

          <div style={{ textAlign: 'center', marginTop: '2rem' }}>
            <button 
              className="iig-btn-finish iig-modal-btn" 
              onClick={() => router.push('/dashboard')}
            >
              Back
            </button>
          </div>
        </main>
      </div>
    );
  }

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

  const handleCheckAnswer = (qId) => {
    setCheckedQuestions(prev => ({ ...prev, [qId]: true }));
  };

  const handleNext = () => {
    if (currentQInfo.groupId) {
      const lastQIndex = allQuestions.findLastIndex(q => q.groupId === currentQInfo.groupId);
      if (lastQIndex < allQuestions.length - 1) {
        setCurrentQuestionIndex(lastQIndex + 1);
      }
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

  const renderView = () => {
    const props = { selectedOption: selections[currentQInfo.id], onSelectOption: handleSelectOption, mode, checkedQuestions, onCheckAnswer: handleCheckAnswer };
    const groupProps = { selections, onSelectOption: handleSelectOption, mode, checkedQuestions, onCheckAnswer: handleCheckAnswer };

    if (currentQInfo.type === 'picture') return <ListeningPicture question={currentQInfo} {...props} />;
    if (currentQInfo.type === 'response') return <ListeningResponse question={currentQInfo} {...props} />;
    if (currentQInfo.type === 'conversation' || currentQInfo.type === 'talk') return <ListeningAudioGroup questions={viewQuestions} group={currentGroup} {...groupProps} />;
    if (currentQInfo.type === 'incomplete_sentence') return <IncompleteSentence question={currentQInfo} {...props} />;
    if (currentQInfo.type === 'text_completion' || currentQInfo.type === 'passage') return <ReadingPassageGroup questions={viewQuestions} group={currentGroup} {...groupProps} />;
    return <div>Unknown Question Type</div>;
  };

  return (
    <div className="iig-page">
      <header className="iig-header">
        <div className="iig-header-left">
          <span style={{ color: '#00205c' }}>pkucpkam</span> <span style={{ color: '#f58220', marginLeft: '4px' }}>TOEIC</span>
        </div>
        <div className="iig-header-center">
          {currentQInfo.sectionTitle}: Questions {currentQuestionIndex + 1} of {allQuestions.length}
        </div>
        <div className="iig-header-right">
          <button style={{ background: '#0277bd', border: 'none', color: 'white', padding: '4px 8px', borderRadius: '4px', cursor: 'pointer' }}>🔊</button>
          <div className="iig-progress-box">
            {currentQuestionIndex + 1}/{allQuestions.length}
          </div>
          {mode === 'full' ? (
             <>
               <div className="iig-timer-box">
                 ⏱ {formatTime(timeLeft)}
               </div>
               <button className="iig-submit-btn" onClick={() => setShowSubmitConfirm(true)}>Submit</button>
             </>
          ) : (
             <div className="iig-progress-box" style={{ background: '#e3f2fd', color: '#0277bd' }}>Practice Mode</div>
          )}
        </div>
      </header>
      
      <main className="iig-main">
        {mode === 'full' && fullAudioUrl && (
           <div style={{ marginBottom: '1rem', display: 'flex', justifyContent: 'center' }}>
             <audio src={`${process.env.NEXT_PUBLIC_API_URL}/media/${fullAudioUrl}`} controls autoPlay style={{ width: '100%', maxWidth: '800px' }}>
                Your browser does not support the audio element.
             </audio>
           </div>
        )}
        {renderView()}
      </main>

      {showQuestionGrid && (
        <div style={{ position: 'fixed', bottom: '70px', right: '20px', background: 'white', border: '1px solid #ccc', borderRadius: '4px', padding: '1rem', boxShadow: '0 -2px 10px rgba(0,0,0,0.2)', zIndex: 100, width: '320px', maxHeight: '400px', overflowY: 'auto' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '1rem', alignItems: 'center' }}>
            <h3 style={{ margin: 0, color: '#00205c', fontSize: '1.1rem' }}>Question List</h3>
            <button onClick={() => setShowQuestionGrid(false)} style={{ background: 'none', border: 'none', cursor: 'pointer', fontSize: '1rem', color: '#666' }}>✖</button>
          </div>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: '6px' }}>
            {allQuestions.map((q, idx) => {
              // Only render one button per group if the view shows the whole group at once.
              // Wait, in group view, should it scroll? The UI normally jumps to the first question of the group.
              // We'll list all questions, and jumping to any sets the index to the group's first question automatically (if handled in currentQuestionIndex).
              // Let's just set the index directly. The view handles grouping based on currentQuestionIndex.
              const isAnswered = !!selections[q.id];
              const isCurrentGroup = q.groupId ? q.groupId === currentQInfo.groupId : idx === currentQuestionIndex;
              
              return (
                <button
                  key={q.id}
                  onClick={() => {
                    let targetIdx = idx;
                    if (q.groupId) {
                       targetIdx = allQuestions.findIndex(allQ => allQ.groupId === q.groupId);
                    }
                    setCurrentQuestionIndex(targetIdx >= 0 ? targetIdx : idx);
                    setShowQuestionGrid(false);
                  }}
                  style={{
                    width: '36px', height: '36px', display: 'flex', alignItems: 'center', justifyContent: 'center',
                    border: `2px solid ${isCurrentGroup ? '#f58220' : (isAnswered ? '#4caf50' : '#e0e0e0')}`,
                    background: isCurrentGroup ? '#fff3e0' : (isAnswered ? '#e8f5e9' : 'white'),
                    cursor: 'pointer',
                    fontWeight: isCurrentGroup ? 'bold' : 'normal',
                    fontSize: '0.85rem',
                    borderRadius: '4px'
                  }}
                >
                  {q.questionNumber}
                </button>
              );
            })}
          </div>
        </div>
      )}

      {showSubmitConfirm && (
        <div className="iig-modal-overlay">
          <div className="iig-modal-content">
            <div className="iig-modal-title">NOTIFICATION</div>
            <div className="iig-modal-subtitle">You have unanswered questions. Submit anyway?</div>
            
            <div className="iig-modal-body">
              {['Listening', 'Reading'].map(skill => {
                const parts = skill === 'Listening' 
                  ? [1, 2, 3, 4] 
                  : [5, 6, 7];
                
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
                      
                      return (
                        <div key={ptNum} className="iig-modal-part">
                          <div className="iig-modal-part-title">Part {ptNum}</div>
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
              <button className="iig-modal-btn iig-btn-finish" onClick={() => {
                setShowSubmitConfirm(false);
                handleSubmit();
              }}>Finish test</button>
            </div>
          </div>
        </div>
      )}

      <footer className="iig-footer">
         <div className="iig-footer-left">
            <input type="checkbox" id="markReview" />
            <label htmlFor="markReview">Mark item for review</label>
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
