import React from 'react';

export default function Header({ sectionTitle, answeredCount, totalQuestions, timeLeftFormatted }) {
  return (
    <header className="app-header">
      <div className="header-logo">
        IIG VIET NAM
      </div>
      <div className="header-title">
        {sectionTitle}
      </div>
      <div className="header-controls">
        <button className="header-btn btn-blue">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"></polygon><path d="M19.07 4.93a10 10 0 0 1 0 14.14M15.54 8.46a5 5 0 0 1 0 7.07"></path></svg>
        </button>
        <button className="header-btn">
          {answeredCount}/{totalQuestions}
        </button>
        <button className="header-btn btn-blue">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
          {timeLeftFormatted}
        </button>
        <button className="header-btn btn-orange">
          Submit
        </button>
      </div>
    </header>
  );
}
