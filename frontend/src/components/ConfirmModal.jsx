import React from 'react';

export default function ConfirmModal({ 
  isOpen, 
  title = "Confirm Action", 
  message = "Are you sure?", 
  onConfirm, 
  onCancel, 
  confirmText = "Confirm", 
  cancelText = "Cancel",
  type = "danger"
}) {
  if (!isOpen) return null;

  const overlayStyle = {
    position: 'fixed',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(10, 15, 28, 0.7)',
    backdropFilter: 'blur(4px)',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    zIndex: 9999,
  };

  const contentStyle = {
    backgroundColor: '#1e293b',
    border: '1px solid rgba(255, 255, 255, 0.1)',
    borderRadius: '16px',
    padding: '24px',
    width: '90%',
    maxWidth: '400px',
    boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.5)',
    color: '#f8fafc',
    fontFamily: "'Inter', sans-serif"
  };

  const titleStyle = {
    fontSize: '1.25rem',
    fontWeight: '700',
    marginBottom: '12px',
    color: '#f8fafc',
    fontFamily: "'Outfit', sans-serif"
  };

  const messageStyle = {
    fontSize: '1rem',
    color: '#94a3b8',
    marginBottom: '24px',
    lineHeight: '1.5'
  };

  const buttonContainerStyle = {
    display: 'flex',
    justifyContent: 'flex-end',
    gap: '12px'
  };

  const baseButtonStyle = {
    padding: '8px 16px',
    borderRadius: '8px',
    fontSize: '0.9rem',
    fontWeight: '600',
    cursor: 'pointer',
    border: 'none',
    transition: 'all 0.2s ease',
  };

  const cancelButtonStyle = {
    ...baseButtonStyle,
    backgroundColor: 'transparent',
    color: '#94a3b8',
    border: '1px solid rgba(255,255,255,0.1)'
  };

  const confirmButtonStyle = {
    ...baseButtonStyle,
    backgroundColor: type === 'danger' ? '#ef4444' : '#3b82f6',
    color: 'white',
    boxShadow: type === 'danger' ? '0 4px 14px 0 rgba(239, 68, 68, 0.39)' : '0 4px 14px 0 rgba(59, 130, 246, 0.39)'
  };

  return (
    <div style={overlayStyle}>
      <div style={contentStyle}>
        <div style={titleStyle}>{title}</div>
        <div style={messageStyle}>{message}</div>
        <div style={buttonContainerStyle}>
          <button 
            style={cancelButtonStyle} 
            onClick={onCancel}
            onMouseOver={(e) => { e.currentTarget.style.backgroundColor = 'rgba(255,255,255,0.05)'; e.currentTarget.style.color = '#f8fafc'; }}
            onMouseOut={(e) => { e.currentTarget.style.backgroundColor = 'transparent'; e.currentTarget.style.color = '#94a3b8'; }}
          >
            {cancelText}
          </button>
          <button 
            style={confirmButtonStyle} 
            onClick={onConfirm}
            onMouseOver={(e) => { e.currentTarget.style.transform = 'translateY(-2px)'; }}
            onMouseOut={(e) => { e.currentTarget.style.transform = 'translateY(0)'; }}
          >
            {confirmText}
          </button>
        </div>
      </div>
    </div>
  );
}
