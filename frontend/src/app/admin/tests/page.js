'use client';

import React, { useEffect, useState } from 'react';
import apiClient from '@/utils/apiClient';
import Link from 'next/link';

export default function AdminTestsPage() {
  const [tests, setTests] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchTests();
  }, []);

  const fetchTests = async () => {
    try {
      // Dùng endpoint lấy danh sách test cho Admin. 
      // Do không có endpoint GET all tests (hiện tại frontend loop qua các năm), ta sẽ get các years rồi fetch.
      const yearsRes = await apiClient.get('/tests/years');
      const years = yearsRes.data;
      
      let allTests = [];
      for (const y of years) {
        const testsRes = await apiClient.get(`/tests?year=${y}`);
        allTests = [...allTests, ...testsRes.data];
      }
      setTests(allTests);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <div style={{ textAlign: 'center', padding: '40px', color: '#6b7280' }}>Loading tests...</div>;
  }

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '32px' }}>
        <h1 style={{ margin: 0, fontSize: '2rem', fontWeight: '700', color: '#111827' }}>Tests Management</h1>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))', gap: '24px' }}>
        {tests.map(test => (
          <div key={test.id} style={{
            backgroundColor: '#ffffff',
            borderRadius: '16px',
            padding: '24px',
            boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03)',
            border: '1px solid #f3f4f6',
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'space-between'
          }}>
            <div>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '12px' }}>
                <h3 style={{ margin: 0, fontSize: '1.25rem', fontWeight: '600', color: '#1f2937', lineHeight: '1.4' }}>{test.title}</h3>
                <span style={{ backgroundColor: '#e0e7ff', color: '#4338ca', padding: '4px 8px', borderRadius: '6px', fontSize: '0.875rem', fontWeight: '600' }}>
                  {test.year}
                </span>
              </div>
            </div>
            
            <div style={{ marginTop: '24px' }}>
              <Link href={`/admin/tests/${test.id}`} style={{ textDecoration: 'none' }}>
                <button style={{
                  width: '100%',
                  padding: '10px 16px',
                  backgroundColor: '#4f46e5',
                  color: 'white',
                  border: 'none',
                  borderRadius: '8px',
                  fontSize: '0.95rem',
                  fontWeight: '600',
                  cursor: 'pointer',
                  transition: 'background-color 0.2s ease'
                }}
                onMouseOver={(e) => e.currentTarget.style.backgroundColor = '#4338ca'}
                onMouseOut={(e) => e.currentTarget.style.backgroundColor = '#4f46e5'}
                >
                  Manage Content →
                </button>
              </Link>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
