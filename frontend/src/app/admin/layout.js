'use client';

import React from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';

export default function AdminLayout({ children }) {
  const pathname = usePathname();

  const menuItems = [
    { name: 'Tests Management', path: '/admin/tests', icon: '📝' },
  ];

  return (
    <div style={{ display: 'flex', minHeight: '100vh', backgroundColor: '#f5f7fa', fontFamily: 'var(--font-geist-sans)' }}>
      {/* Sidebar */}
      <aside style={{
        width: '260px',
        backgroundColor: '#ffffff',
        borderRight: '1px solid #eaeaea',
        display: 'flex',
        flexDirection: 'column',
        boxShadow: '4px 0 24px rgba(0,0,0,0.02)'
      }}>
        <div style={{ padding: '24px', borderBottom: '1px solid #eaeaea' }}>
          <h2 style={{ margin: 0, fontSize: '1.25rem', fontWeight: '700', color: '#111827', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <span style={{ fontSize: '1.5rem' }}>⚙️</span> Admin CMS
          </h2>
        </div>
        <nav style={{ flex: 1, padding: '16px 12px' }}>
          {menuItems.map((item) => {
            const isActive = pathname.startsWith(item.path);
            return (
              <Link key={item.path} href={item.path} style={{ textDecoration: 'none' }}>
                <div style={{
                  padding: '12px 16px',
                  borderRadius: '8px',
                  backgroundColor: isActive ? '#f3f4f6' : 'transparent',
                  color: isActive ? '#111827' : '#4b5563',
                  fontWeight: isActive ? '600' : '500',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '12px',
                  transition: 'all 0.2s ease',
                  marginBottom: '8px',
                }}>
                  <span style={{ fontSize: '1.25rem' }}>{item.icon}</span>
                  {item.name}
                </div>
              </Link>
            );
          })}
        </nav>
        <div style={{ padding: '16px', borderTop: '1px solid #eaeaea' }}>
          <Link href="/" style={{ textDecoration: 'none' }}>
            <div style={{ padding: '12px', textAlign: 'center', color: '#6b7280', fontWeight: '500', borderRadius: '8px', border: '1px solid #e5e7eb', transition: 'all 0.2s ease' }}>
              ← Back to App
            </div>
          </Link>
        </div>
      </aside>

      {/* Main Content */}
      <main style={{ flex: 1, padding: '32px 48px', overflowY: 'auto', height: '100vh', boxSizing: 'border-box' }}>
        <div style={{ maxWidth: '1200px', margin: '0 auto' }}>
          {children}
        </div>
      </main>
    </div>
  );
}
