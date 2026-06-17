"use client";

import React, { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { register } from '../../utils/auth';

export default function RegisterPage() {
  const router = useRouter();
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleRegister = (e) => {
    e.preventDefault();
    if (!name || !email || !password) return;
    register(name, email, password);
    router.push('/dashboard');
  };

  return (
    <div className="auth-page">
      <div className="auth-box">
        <h1 className="auth-title">Create Account</h1>
        <p className="auth-subtitle">Start your journey to a higher TOEIC score</p>
        
        <form onSubmit={handleRegister}>
          <div className="auth-form-group">
            <label className="auth-label">Full Name</label>
            <input 
              type="text" 
              required
              className="auth-input"
              value={name}
              onChange={e => setName(e.target.value)}
              placeholder="Nguyen Van A"
            />
          </div>
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
            Register
          </button>
        </form>
        
        <p className="auth-footer">
          Already have an account? <Link href="/login" className="auth-link">Sign in here</Link>
        </p>
      </div>
    </div>
  );
}
