import React from 'react';

export default function Footer({ onPrev, onNext, onReviewToggle, isReviewing }) {
  return (
    <footer className="app-footer">
      <label className="checkbox-container">
        <input type="checkbox" checked={isReviewing} onChange={onReviewToggle} />
        Mark item for review
      </label>
      <div className="footer-nav">
        <button className="footer-btn btn-nav-grid" title="Question List">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
        </button>
        <button className="footer-btn btn-nav-prev" onClick={onPrev} title="Previous">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="15 18 9 12 15 6"></polyline></svg>
        </button>
        <button className="footer-btn btn-nav-next" onClick={onNext} title="Next">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg>
        </button>
      </div>
    </footer>
  );
}
