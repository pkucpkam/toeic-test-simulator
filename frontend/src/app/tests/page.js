"use client";

import React, { useEffect, useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { getUser, logout } from '../../utils/auth';
import apiClient from '../../utils/apiClient';
import '../globals.css';

export default function TestSelectionPage() {
  const router = useRouter();
  const [user, setUser] = useState(null);
  
  const [selectedMode, setSelectedMode] = useState(null); // 'full' | 'part'

  const [years, setYears] = useState([]);
  const [selectedYear, setSelectedYear] = useState(null);
  
  const [tests, setTests] = useState([]);
  
  const [selectedPartNum, setSelectedPartNum] = useState(1);
  const [partSummaries, setPartSummaries] = useState([]);

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

  useEffect(() => {
    if (!selectedYear || selectedMode !== 'full') return;
    const fetchTests = async () => {
      try {
        const res = await apiClient.get(`/tests?year=${selectedYear}`);
        setTests(res.data);
      } catch (err) {
        console.error("Error fetching tests", err);
      }
    };
    fetchTests();
  }, [selectedYear, selectedMode]);

  useEffect(() => {
    if (!selectedYear || selectedMode !== 'part' || !selectedPartNum) return;
    const fetchPartSummaries = async () => {
      try {
        const res = await apiClient.get(`/tests/parts/summary?year=${selectedYear}&partNumber=${selectedPartNum}`);
        setPartSummaries(res.data);
      } catch (err) {
        console.error("Error fetching part summaries", err);
      }
    };
    fetchPartSummaries();
  }, [selectedYear, selectedMode, selectedPartNum]);

  const handleLogout = () => {
    logout();
    router.push('/login');
  };

  if (!user) return null;

  return (
    <div className="premium-container">
      <header className="premium-header">
        <div className="header-brand">TOEIC Master</div>
        <nav className="header-nav">
           {selectedMode && (
              <button 
                onClick={() => setSelectedMode(null)} 
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
        <div className="glass-panel text-center mb-12">
          <h1 className="text-4xl font-extrabold gradient-text">Select a Practice Test</h1>
          <p className="subtitle">Enhance your TOEIC skills with real simulations.</p>
        </div>

        {!selectedMode ? (
          <div className="grid-2 mt-8">
             <div className="premium-card" style={{ cursor: 'pointer' }} onClick={() => setSelectedMode('full')}>
                <div className="card-badge bg-primary">Standard</div>
                <h2 className="card-title">Full Test Mode</h2>
                <p className="card-desc mb-4">
                   Experience the complete test simulation. 200 questions, 120 minutes time limit.
                </p>
                <button className="premium-btn btn-primary mt-auto">Select Full Test</button>
             </div>
             <div className="premium-card" style={{ cursor: 'pointer' }} onClick={() => setSelectedMode('part')}>
                <div className="card-badge bg-secondary">Targeted</div>
                <h2 className="card-title">Practice by Part</h2>
                <p className="card-desc mb-4">
                   Focus on specific sections to master your skills without time limits.
                </p>
                <button className="premium-btn btn-primary mt-auto" style={{ background: 'var(--secondary)' }}>Select Practice by Part</button>
             </div>
          </div>
        ) : (
          <>


            <div className="filter-bar glass-panel flex-row">
               <div className="filter-group">
                  <label>Year</label>
                  <select 
                     value={selectedYear || ''}
                     onChange={(e) => setSelectedYear(Number(e.target.value))}
                     className="premium-select"
                  >
                     {years.map(y => <option key={y} value={y}>{y}</option>)}
                  </select>
               </div>
               
               {selectedMode === 'part' && (
                 <div className="filter-group">
                    <label>Part</label>
                    <select 
                       value={selectedPartNum}
                       onChange={(e) => setSelectedPartNum(Number(e.target.value))}
                       className="premium-select"
                    >
                       {[1,2,3,4,5,6,7].map(p => <option key={p} value={p}>Part {p}</option>)}
                    </select>
                 </div>
               )}
            </div>

            {selectedMode === 'full' && (
               <div className="mt-8">
                  <h3 className="mb-4" style={{ fontSize: '1.5rem', fontWeight: 'bold' }}>Available Full Tests for {selectedYear}</h3>
                  {tests.length > 0 ? (
                     <div className="grid-2">
                        {tests.map(t => (
                           <div key={t.id} className="premium-card" style={{ display: 'flex', flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }}>
                              <span style={{ fontSize: '1.2rem', fontWeight: '500' }}>{t.title}</span>
                              <Link href={`/test/${t.id}?mode=full`} className="premium-btn btn-primary">Start</Link>
                           </div>
                        ))}
                     </div>
                  ) : (
                     <p className="text-muted">No full tests available for this year.</p>
                  )}
               </div>
            )}

            {selectedMode === 'part' && (
               <div className="mt-8">
                  <h3 className="mb-4" style={{ fontSize: '1.5rem', fontWeight: 'bold' }}>Part {selectedPartNum} for {selectedYear}</h3>
                  {partSummaries.length > 0 ? (
                     <div className="grid-2">
                        {partSummaries.map(p => (
                           <div key={p.partId} className="premium-card" style={{ display: 'flex', flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }}>
                              <span style={{ fontSize: '1.2rem', fontWeight: '500' }}>{p.testTitle} - Part {selectedPartNum}</span>
                              <Link href={`/test/${p.testId}?mode=${p.partId}`} className="premium-btn btn-primary" style={{ background: 'var(--secondary)' }}>Practice</Link>
                           </div>
                        ))}
                     </div>
                  ) : (
                     <p className="text-muted">No data available for this part in {selectedYear}.</p>
                  )}
               </div>
            )}
          </>
        )}
      </main>
    </div>
  );
}
