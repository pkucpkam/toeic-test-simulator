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
    <div className="landing-page">
      <header className="page-header">
        <div className="page-header-inner">
          <div className="logo-box">IIG VIET NAM</div>
          <nav className="page-nav">
            {user ? (
              <>
                <span style={{fontWeight: 600, fontSize: '0.875rem'}}>Hi, {user.name}</span>
                <Link href="/dashboard" className="btn-nav-primary">
                  Dashboard
                </Link>
              </>
            ) : (
              <>
                <Link href="/login" className="nav-link">Login</Link>
                <Link href="/register" className="btn-nav-primary">
                  Register
                </Link>
              </>
            )}
          </nav>
        </div>
      </header>

      <main className="landing-main">
        <h1 className="landing-title">
          Master the TOEIC Test
        </h1>
        <p className="landing-desc">
          Experience the most accurate simulation of the official IIG computer-based TOEIC format. Practice full tests or target specific parts to maximize your score.
        </p>
        
        <div className="flex gap-4">
          {user ? (
             <Link href="/tests" className="btn-cta">
                Start Practicing
             </Link>
          ) : (
             <Link href="/register" className="btn-cta">
                Get Started for Free
             </Link>
          )}
        </div>
      </main>

      <footer className="landing-footer">
        <p>&copy; 2026 TOEIC Simulator. Not affiliated with ETS or IIG.</p>
      </footer>
    </div>
  );
}
