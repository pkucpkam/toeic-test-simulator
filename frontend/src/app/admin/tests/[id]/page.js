'use client';

import React, { useEffect, useState } from 'react';
import apiClient from '@/utils/apiClient';
import { useParams } from 'next/navigation';

export default function EditTestPage() {
  const { id } = useParams();
  const [test, setTest] = useState(null);
  const [parts, setParts] = useState([]);
  const [groupsByPart, setGroupsByPart] = useState({});
  const [loading, setLoading] = useState(true);

  // Edit states
  const [editingItem, setEditingItem] = useState(null); // { type: 'test'|'part'|'group'|'question', data: any, partId?: any }
  const [saving, setSaving] = useState(false);
  
  // Accordion state
  const [expandedParts, setExpandedParts] = useState({});

  useEffect(() => {
    fetchData();
  }, [id]);

  const fetchData = async () => {
    try {
      const testRes = await apiClient.get(`/tests/${id}`);
      setTest(testRes.data);

      const partsRes = await apiClient.get(`/tests/${id}/parts`);
      const partsData = partsRes.data;
      setParts(partsData);

      // Fetch questions for each part
      const groupsMap = {};
      for (const part of partsData) {
        const groupsRes = await apiClient.get(`/tests/parts/${part.id}/questions`);
        groupsMap[part.id] = groupsRes.data;
      }
      setGroupsByPart(groupsMap);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const togglePart = (partId) => {
    setExpandedParts(prev => ({ ...prev, [partId]: !prev[partId] }));
  };

  const handleSave = async (e) => {
    e.preventDefault();
    setSaving(true);
    try {
      if (editingItem.type === 'test') {
        await apiClient.put(`/admin/tests/${test.id}`, editingItem.data);
      } else if (editingItem.type === 'part') {
        await apiClient.put(`/admin/parts/${editingItem.data.id}`, editingItem.data);
      } else if (editingItem.type === 'group') {
        await apiClient.put(`/admin/groups/${editingItem.data.id}`, editingItem.data);
      } else if (editingItem.type === 'question') {
        await apiClient.put(`/admin/questions/${editingItem.data.id}`, editingItem.data);
      }
      setEditingItem(null);
      await fetchData(); // Refresh data
    } catch (err) {
      alert("Save failed");
      console.error(err);
    } finally {
      setSaving(false);
    }
  };

  const renderEditModal = () => {
    if (!editingItem) return null;
    
    return (
      <div style={{
        position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
        backgroundColor: 'rgba(0,0,0,0.5)', display: 'flex', alignItems: 'center', justifyContent: 'center',
        zIndex: 50, padding: '20px'
      }}>
        <div style={{
          backgroundColor: '#fff', borderRadius: '12px', padding: '32px', width: '100%', maxWidth: '600px',
          maxHeight: '90vh', overflowY: 'auto', boxShadow: '0 25px 50px -12px rgba(0,0,0,0.25)'
        }}>
          <h2 style={{ margin: '0 0 24px 0', fontSize: '1.5rem', fontWeight: '700' }}>
            Edit {editingItem.type.charAt(0).toUpperCase() + editingItem.type.slice(1)}
          </h2>
          
          <form onSubmit={handleSave}>
            {editingItem.type === 'test' && (
              <>
                <Field label="Title" value={editingItem.data.title} onChange={v => setEditingItem({ ...editingItem, data: { ...editingItem.data, title: v }})} />
                <Field label="Year" type="number" value={editingItem.data.year} onChange={v => setEditingItem({ ...editingItem, data: { ...editingItem.data, year: parseInt(v) }})} />
                <Field label="Full Audio URL" value={editingItem.data.fullAudioUrl} onChange={v => setEditingItem({ ...editingItem, data: { ...editingItem.data, fullAudioUrl: v }})} />
              </>
            )}

            {editingItem.type === 'part' && (
              <>
                <Field label="Part Name" value={editingItem.data.name} onChange={v => setEditingItem({ ...editingItem, data: { ...editingItem.data, name: v }})} />
              </>
            )}

            {editingItem.type === 'group' && (
              <>
                <Field label="Audio URL" value={editingItem.data.audioUrl} onChange={v => setEditingItem({ ...editingItem, data: { ...editingItem.data, audioUrl: v }})} />
                <Field label="Image URL" value={editingItem.data.imageUrl} onChange={v => setEditingItem({ ...editingItem, data: { ...editingItem.data, imageUrl: v }})} />
                <Field label="Passage Text" isTextArea value={editingItem.data.passageText} onChange={v => setEditingItem({ ...editingItem, data: { ...editingItem.data, passageText: v }})} />
                <Field label="Transcript" isTextArea value={editingItem.data.transcript} onChange={v => setEditingItem({ ...editingItem, data: { ...editingItem.data, transcript: v }})} />
              </>
            )}

            {editingItem.type === 'question' && (
              <>
                <Field label="Question Text" isTextArea value={editingItem.data.questionText} onChange={v => setEditingItem({ ...editingItem, data: { ...editingItem.data, questionText: v }})} />
                <Field label="Option A" value={editingItem.data.optionA} onChange={v => setEditingItem({ ...editingItem, data: { ...editingItem.data, optionA: v }})} />
                <Field label="Option B" value={editingItem.data.optionB} onChange={v => setEditingItem({ ...editingItem, data: { ...editingItem.data, optionB: v }})} />
                <Field label="Option C" value={editingItem.data.optionC} onChange={v => setEditingItem({ ...editingItem, data: { ...editingItem.data, optionC: v }})} />
                <Field label="Option D" value={editingItem.data.optionD} onChange={v => setEditingItem({ ...editingItem, data: { ...editingItem.data, optionD: v }})} />
                
                <div style={{ marginBottom: '16px' }}>
                  <label style={{ display: 'block', marginBottom: '6px', fontWeight: '500', color: '#374151' }}>Correct Answer</label>
                  <select 
                    value={editingItem.data.correctAnswer} 
                    onChange={e => setEditingItem({ ...editingItem, data: { ...editingItem.data, correctAnswer: e.target.value }})}
                    style={{ width: '100%', padding: '10px 12px', border: '1px solid #d1d5db', borderRadius: '6px', backgroundColor: '#fff' }}
                  >
                    <option value="A">A</option>
                    <option value="B">B</option>
                    <option value="C">C</option>
                    <option value="D">D</option>
                  </select>
                </div>
                
                <Field label="Explanation" isTextArea value={editingItem.data.explanation} onChange={v => setEditingItem({ ...editingItem, data: { ...editingItem.data, explanation: v }})} />
              </>
            )}

            <div style={{ display: 'flex', gap: '12px', marginTop: '32px', justifyContent: 'flex-end' }}>
              <button type="button" onClick={() => setEditingItem(null)} style={{
                padding: '10px 20px', backgroundColor: '#fff', border: '1px solid #d1d5db', borderRadius: '8px',
                fontWeight: '600', color: '#374151', cursor: 'pointer'
              }}>Cancel</button>
              
              <button type="submit" disabled={saving} style={{
                padding: '10px 20px', backgroundColor: '#4f46e5', border: 'none', borderRadius: '8px',
                fontWeight: '600', color: '#fff', cursor: saving ? 'wait' : 'pointer'
              }}>
                {saving ? 'Saving...' : 'Save Changes'}
              </button>
            </div>
          </form>
        </div>
      </div>
    );
  };

  if (loading) return <div style={{ padding: '40px' }}>Loading test structure...</div>;
  if (!test) return <div style={{ padding: '40px' }}>Test not found</div>;

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '32px', backgroundColor: '#fff', padding: '24px', borderRadius: '16px', border: '1px solid #e5e7eb' }}>
        <div>
          <h1 style={{ margin: 0, fontSize: '2rem', fontWeight: '700', color: '#111827', marginBottom: '8px' }}>{test.title}</h1>
          <p style={{ margin: 0, color: '#6b7280' }}>Year: {test.year}</p>
        </div>
        <button onClick={() => setEditingItem({ type: 'test', data: test })} style={{
          padding: '10px 20px', backgroundColor: '#111827', color: 'white', border: 'none', borderRadius: '8px', fontWeight: '600', cursor: 'pointer'
        }}>
          Edit Test Info
        </button>
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
        {parts.map(part => {
          const isExpanded = expandedParts[part.id];
          const groups = groupsByPart[part.id] || [];
          
          return (
            <div key={part.id} style={{ backgroundColor: '#fff', borderRadius: '12px', border: '1px solid #e5e7eb', overflow: 'hidden' }}>
              <div 
                style={{ padding: '16px 24px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', cursor: 'pointer', backgroundColor: isExpanded ? '#f9fafb' : '#fff' }}
                onClick={() => togglePart(part.id)}
              >
                <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                  <span style={{ fontSize: '1.25rem' }}>{isExpanded ? '📂' : '📁'}</span>
                  <h3 style={{ margin: 0, fontWeight: '600', color: '#1f2937' }}>Part {part.partNumber}: {part.name}</h3>
                </div>
                <div style={{ display: 'flex', gap: '12px' }}>
                  <button onClick={(e) => { e.stopPropagation(); setEditingItem({ type: 'part', data: part }); }} style={{
                    padding: '6px 12px', backgroundColor: '#fff', border: '1px solid #d1d5db', borderRadius: '6px', fontSize: '0.875rem', fontWeight: '500', cursor: 'pointer'
                  }}>
                    Edit Name
                  </button>
                </div>
              </div>

              {isExpanded && (
                <div style={{ padding: '24px', borderTop: '1px solid #e5e7eb', backgroundColor: '#fcfcfd' }}>
                  <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
                    {groups.map((group, index) => (
                      <div key={group.id} style={{ border: '1px solid #e5e7eb', borderRadius: '12px', padding: '20px', backgroundColor: '#fff' }}>
                        <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '16px' }}>
                          <div style={{ color: '#4b5563', fontWeight: '500' }}>Group {index + 1}</div>
                          <button onClick={() => setEditingItem({ type: 'group', data: group })} style={{
                            padding: '4px 12px', backgroundColor: '#f3f4f6', border: 'none', borderRadius: '6px', fontSize: '0.875rem', fontWeight: '500', cursor: 'pointer', color: '#374151'
                          }}>
                            Edit Media / Passage
                          </button>
                        </div>
                        
                        {(group.passageText || group.imageUrl || group.audioUrl) && (
                          <div style={{ marginBottom: '20px', padding: '16px', backgroundColor: '#f9fafb', borderRadius: '8px', fontSize: '0.9rem', color: '#4b5563' }}>
                            {group.audioUrl && <div style={{ marginBottom: '8px' }}>🎵 Audio: {group.audioUrl}</div>}
                            {group.imageUrl && <div style={{ marginBottom: '8px' }}>🖼️ Image: {group.imageUrl}</div>}
                            {group.passageText && <div>📄 {group.passageText.substring(0, 100)}...</div>}
                          </div>
                        )}

                        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))', gap: '16px' }}>
                          {group.questions?.map(q => (
                            <div key={q.id} style={{ border: '1px solid #f3f4f6', borderRadius: '8px', padding: '16px', position: 'relative' }}>
                              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '12px' }}>
                                <div style={{ fontWeight: '600', color: '#111827', backgroundColor: '#e0e7ff', padding: '2px 8px', borderRadius: '4px', fontSize: '0.8rem' }}>
                                  Q{q.questionNumber}
                                </div>
                                <button onClick={() => setEditingItem({ type: 'question', data: q })} style={{
                                  background: 'none', border: 'none', color: '#4f46e5', fontWeight: '600', fontSize: '0.875rem', cursor: 'pointer'
                                }}>Edit</button>
                              </div>
                              
                              {q.questionText && <div style={{ marginBottom: '12px', fontSize: '0.95rem', fontWeight: '500' }}>{q.questionText}</div>}
                              
                              <ul style={{ listStyle: 'none', padding: 0, margin: 0, fontSize: '0.9rem', color: '#4b5563' }}>
                                <li style={{ fontWeight: q.correctAnswer === 'A' ? '700' : '400', color: q.correctAnswer === 'A' ? '#059669' : 'inherit' }}>A. {q.optionA}</li>
                                <li style={{ fontWeight: q.correctAnswer === 'B' ? '700' : '400', color: q.correctAnswer === 'B' ? '#059669' : 'inherit' }}>B. {q.optionB}</li>
                                <li style={{ fontWeight: q.correctAnswer === 'C' ? '700' : '400', color: q.correctAnswer === 'C' ? '#059669' : 'inherit' }}>C. {q.optionC}</li>
                                <li style={{ fontWeight: q.correctAnswer === 'D' ? '700' : '400', color: q.correctAnswer === 'D' ? '#059669' : 'inherit' }}>D. {q.optionD}</li>
                              </ul>
                            </div>
                          ))}
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>
          );
        })}
      </div>

      {renderEditModal()}
    </div>
  );
}

// Simple form field component
function Field({ label, value, onChange, type = 'text', isTextArea = false }) {
  const commonStyle = {
    width: '100%', padding: '10px 12px', border: '1px solid #d1d5db', borderRadius: '6px', 
    backgroundColor: '#fff', fontSize: '0.95rem', color: '#111827', fontFamily: 'inherit', boxSizing: 'border-box'
  };

  return (
    <div style={{ marginBottom: '16px' }}>
      <label style={{ display: 'block', marginBottom: '6px', fontWeight: '500', color: '#374151' }}>{label}</label>
      {isTextArea ? (
        <textarea 
          value={value || ''} 
          onChange={e => onChange(e.target.value)} 
          style={{ ...commonStyle, minHeight: '100px', resize: 'vertical' }} 
        />
      ) : (
        <input 
          type={type} 
          value={value || ''} 
          onChange={e => onChange(e.target.value)} 
          style={commonStyle} 
        />
      )}
    </div>
  );
}
