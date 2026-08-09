"use client";

import React, { useEffect, useState } from 'react';
import Link from 'next/link';
import { getUser } from '../utils/auth';

export default function LandingPage() {
  const [user, setUser] = useState(null);

  useEffect(() => {
    const init = async () => {
      setUser(getUser());
    };
    init();
  }, []);

  return (
    <div className="premium-container">
      <header className="premium-header">
        <div className="header-brand">
          <span className="gradient-text">TOEIC</span> Master
        </div>
        <nav className="header-nav">
          {user ? (
            <>
              <span className="user-greeting">Hi, {user.name}</span>
              <Link href="/dashboard" className="premium-btn btn-primary" style={{ padding: '0.5rem 1.25rem' }}>
                Dashboard
              </Link>
            </>
          ) : (
            <>
              <Link href="/login" className="nav-item">Login</Link>
              <Link href="/register" className="premium-btn btn-primary" style={{ padding: '0.5rem 1.25rem' }}>
                Register
              </Link>
            </>
          )}
        </nav>
      </header>

      <main className="premium-main text-center mt-8">
        <div className="glass-panel" style={{ maxWidth: '1050px', margin: '0 auto', padding: '5rem 3rem', position: 'relative', overflow: 'hidden' }}>

          <div style={{ position: 'absolute', top: '-10%', left: '-10%', width: '40%', height: '40%', background: 'var(--primary)', filter: 'blur(100px)', opacity: 0.15, borderRadius: '50%', zIndex: 0 }}></div>
          <div style={{ position: 'absolute', bottom: '-10%', right: '-10%', width: '40%', height: '40%', background: 'var(--secondary)', filter: 'blur(100px)', opacity: 0.15, borderRadius: '50%', zIndex: 0 }}></div>

          <div style={{ position: 'relative', zIndex: 1 }}>

            <h1 style={{ fontSize: '4rem', marginBottom: '1.5rem', lineHeight: 1.1, textShadow: '0 4px 20px rgba(0,0,0,0.5)' }}>
              Master the <span className="gradient-text">TOEIC Test</span><br />Like Never Before
            </h1>

            <p className="subtitle" style={{ fontSize: '1.25rem', marginBottom: '3rem', maxWidth: '650px', margin: '0 auto 3rem' }}>
              Experience the most accurate simulation of the official IIG computer-based TOEIC format. Practice full tests or target specific parts to maximize your score with our premium simulator.
            </p>

            <div style={{ display: 'flex', gap: '1.5rem', justifyContent: 'center', flexWrap: 'wrap' }}>
              {user ? (
                <Link href="/tests" className="premium-btn btn-primary" style={{ fontSize: '1.125rem', padding: '1rem 2.5rem', minWidth: '220px' }}>
                  Start Practicing Now
                </Link>
              ) : (
                <Link href="/register" className="premium-btn btn-primary" style={{ fontSize: '1.125rem', padding: '1rem 2.5rem', minWidth: '220px' }}>
                  Get Started for Free
                </Link>
              )}
              <a href="#features" className="premium-btn" style={{ fontSize: '1.125rem', padding: '1rem 2.5rem', background: 'rgba(255,255,255,0.05)', border: '1px solid var(--border)', color: 'white', minWidth: '220px', transition: 'all 0.3s' }}
                onMouseOver={(e) => { e.currentTarget.style.background = 'rgba(255,255,255,0.1)' }}
                onMouseOut={(e) => { e.currentTarget.style.background = 'rgba(255,255,255,0.05)' }}>
                View Features
              </a>
            </div>

            <div style={{ marginTop: '4rem', display: 'flex', justifyContent: 'center', gap: '4rem', color: 'var(--text-muted)' }}>
              <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '0.5rem' }}>
                <div style={{ fontSize: '2.5rem', fontWeight: 800, color: 'var(--text-main)' }}>10+</div>
                <div style={{ fontSize: '0.875rem', textTransform: 'uppercase', letterSpacing: '1px', fontWeight: 600 }}>Full Tests</div>
              </div>
              <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '0.5rem' }}>
                <div style={{ fontSize: '2.5rem', fontWeight: 800, color: 'var(--text-main)' }}>100%</div>
                <div style={{ fontSize: '0.875rem', textTransform: 'uppercase', letterSpacing: '1px', fontWeight: 600 }}>IIG Format</div>
              </div>
              <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '0.5rem' }}>
                <div style={{ fontSize: '2.5rem', fontWeight: 800, color: 'var(--text-main)' }}>Free</div>
                <div style={{ fontSize: '0.875rem', textTransform: 'uppercase', letterSpacing: '1px', fontWeight: 600 }}>To Start</div>
              </div>
            </div>
          </div>
        </div>
      </main>

      <footer style={{ textAlign: 'center', padding: '2rem', color: 'var(--text-muted)', borderTop: '1px solid var(--border)', marginTop: '2rem', fontSize: '0.875rem' }}>
        <p>&copy; 2026 TOEIC Simulator. Not affiliated with ETS or IIG.</p>
      </footer>
    </div>
  );
}
