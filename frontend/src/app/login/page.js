"use client";

import React, { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { login } from '../../utils/auth';

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleLogin = async (e) => {
    e.preventDefault();
    if (!email || !password) return;
    try {
      await login(email, password);
      router.push('/dashboard');
    } catch (err) {
      alert("Login failed. Check your credentials.");
    }
  };

  return (
    <div className="auth-page">
      <div className="auth-box">
        <h1 className="auth-title">Welcome Back</h1>
        <p className="auth-subtitle">Sign in to continue your TOEIC preparation</p>
        
        <form onSubmit={handleLogin}>
          <div className="auth-form-group">
            <label className="auth-label">Email</label>
            <input 
              type="email" 
              required
              className="auth-input"
              value={email}
              onChange={e => setEmail(e.target.value)}
              placeholder="you@example.com"
            />
          </div>
          <div className="auth-form-group">
            <label className="auth-label">Password</label>
            <input 
              type="password" 
              required
              className="auth-input"
              value={password}
              onChange={e => setPassword(e.target.value)}
              placeholder="••••••••"
            />
          </div>
          <button type="submit" className="auth-btn">
            Sign In
          </button>
        </form>
        
        <p className="auth-footer">
          Don&apos;t have an account? <Link href="/register" className="auth-link">Register here</Link>
        </p>
      </div>
    </div>
  );
}
