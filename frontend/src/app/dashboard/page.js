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
        const res = await apiClient.get('/analytics/history');
        setHistory(res.data);
      } catch (err) {
        console.error("Error fetching history", err);
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

  return (
    <div className="premium-container">
      <header className="premium-header">
        <div className="header-brand">TOEIC Master</div>
        <nav className="header-nav">
           <span className="user-greeting">Hi, {user.name}</span>
           <Link href="/tests" className="nav-item">Practice Tests</Link>
           <button onClick={handleLogout} className="nav-item btn-logout">Logout</button>
        </nav>
      </header>

      <main className="premium-main">
        <div className="glass-panel text-center mb-12">
          <h1 className="text-4xl font-extrabold gradient-text">Your Dashboard</h1>
          <p className="subtitle">Track your progress and review your performance.</p>
        </div>

        <div className="glass-panel">
          <h2 className="card-title mb-4">Recent Test Attempts</h2>
          
          {history.length > 0 ? (
             <div className="history-table-wrapper">
                <table className="premium-table">
                   <thead>
                      <tr>
                         <th>Test Name</th>
                         <th>Type</th>
                         <th>Date</th>
                         <th>Duration</th>
                         <th>Score (Correct)</th>
                      </tr>
                   </thead>
                   <tbody>
                      {history.map(attempt => (
                         <tr key={attempt.id}>
                            <td>{attempt.testTitle}</td>
                            <td>
                               <span className={`card-badge ${attempt.attemptType === 'FULL' ? 'bg-primary' : 'bg-secondary'}`} style={{marginBottom: 0}}>
                                  {attempt.attemptType}
                               </span>
                            </td>
                            <td>{new Date(attempt.startedAt).toLocaleDateString()}</td>
                            <td>{Math.floor(attempt.durationSeconds / 60)}m {attempt.durationSeconds % 60}s</td>
                            <td>
                               <span className="score-badge">{attempt.totalCorrect} pts</span>
                            </td>
                         </tr>
                      ))}
                   </tbody>
                </table>
             </div>
          ) : (
             <div className="text-center mt-8">
                <p className="text-muted">You haven&apos;t taken any tests yet.</p>
                <Link href="/tests" className="premium-btn btn-primary mt-4">Start Practicing</Link>
             </div>
          )}
        </div>
      </main>
    </div>
  );
}
