import React from 'react';

/**
 * Apply inline markdown patterns (bold, italic) to a string.
 * Safe to call on both plain text AND HTML strings —
 * the character class [^*<>\n] avoids matching across tags.
 */
function applyInlineMarkdown(text) {
  // Bold: **text**
  let s = text.replace(/\*\*([^*<>\n]+)\*\*/g, '<strong>$1</strong>');
  // Italic: *text* (single *, not double)
  s = s.replace(/(?<!\*)\*([^*<>\n]+)\*(?!\*)/g, '<em>$1</em>');
  return s;
}

/**
 * Convert plain-text markdown to HTML.
 * Handles: paragraphs, line breaks, bold, italic, headings.
 * Single \n within a paragraph → space (standard markdown behaviour).
 * Double \n → new paragraph.
 */
function markdownToHtml(text) {
  // 1. Escape raw HTML entities so we don't inject user content
  let s = text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;');

  // 2. Headings (#, ##, ...)
  s = s.replace(/^(#{1,6})\s+(.+)$/gm, (_, hashes, content) => {
    const level = hashes.length;
    return `<h${level}>${applyInlineMarkdown(content)}</h${level}>`;
  });

  // 3. Split into paragraphs at blank lines
  const blocks = s.split(/\n{2,}/);
  return blocks
    .map(block => {
      const b = block.trim();
      if (!b) return '';
      // Don't re-wrap headings we already produced above
      if (/^<h[1-6]>/.test(b)) return b;
      // Smart newline join:
      // - word char \n word char → direct join (PDF hard-wrap continuation, e.g. "meetin\ng")
      // - anything else         → join with a space (sentence/phrase break)
      const joined = b.replace(/(\w)\n(\w)/g, '$1$2').replace(/\n/g, ' ');
      return `<p>${applyInlineMarkdown(joined)}</p>`;
    })
    .filter(Boolean)
    .join('\n');
}

// Smart renderer: detects HTML (from Quill) vs plain Markdown
function PassageRenderer({ content, style }) {
  if (!content) return null;

  const trimmed = content.trim();

  // Detect HTML output from Quill editor (starts with a structural HTML tag)
  const isHtml = /^<(p|div|br|strong|em|ul|ol|li|h[1-6]|span|table|blockquote)[\s>/]/i.test(trimmed);

  // For Quill HTML  → keep the HTML structure, but also convert any ** patterns inside it
  // For plain Markdown → full conversion to HTML
  const html = isHtml ? applyInlineMarkdown(trimmed) : markdownToHtml(trimmed);

  return (
    <div
      className="rich-text-content"
      style={{ maxWidth: '100%', ...style }}
      dangerouslySetInnerHTML={{ __html: html }}
    />
  );
}


const OptionsList = ({ question, selections, onSelectOption, hideText = false, mode, checkedQuestions, onCheckAnswer, showCheckButton = true }) => {
  const optionsToRender = question.options || ["(A)", "(B)", "(C)", "(D)"];
  const isChecked = checkedQuestions && checkedQuestions[question.id];
  const hasSelection = selections && selections[question.id];

  return (
    <div className="iig-option-list" style={{ marginBottom: '1.5rem', maxWidth: '100%' }}>
      {optionsToRender.map((opt, i) => {
        const optionLabel = (hideText && !isChecked) ? opt.substring(0, 3) : opt;
        const isSelected = selections[question.id] === opt;
        
        let labelStyle = {};
        if (isChecked) {
          const isCorrect = question.correctAnswer && opt.startsWith(`(${question.correctAnswer})`);
          if (isCorrect) {
            labelStyle = { backgroundColor: '#e8f5e9', borderColor: '#4caf50' };
          } else if (isSelected && !isCorrect) {
            labelStyle = { backgroundColor: '#ffebee', borderColor: '#f44336' };
          }
        }
        
        return (
          <label 
             key={i} 
             className="iig-option-label"
             style={labelStyle}
          >
            <input 
              type="radio" 
              name={`q${question.id}`} 
              value={opt} 
              checked={isSelected}
              onChange={() => !isChecked && onSelectOption(question.id, opt)}
              disabled={isChecked}
              className="iig-option-input"
            />
            <span className="iig-option-text">{optionLabel}</span>
          </label>
        );
      })}
      
      {mode !== 'full' && showCheckButton && !isChecked && hasSelection && (
        <button 
          onClick={() => onCheckAnswer(question.id)}
          className="iig-check-btn"
        >
          Check Answer
        </button>
      )}

      {isChecked && question.explanation && (
        <div style={{
          marginTop: '1rem', padding: '0.875rem 1rem',
          background: 'rgba(16,185,129,0.08)', border: '1px solid rgba(16,185,129,0.2)',
          borderRadius: '8px', fontSize: '0.875rem', color: '#1a2e3b'
        }}>
          <div style={{ fontWeight: 700, color: '#10b981', marginBottom: '0.75rem', fontSize: '0.95rem' }}>
            💡 Explanation:
          </div>
          {question.explanation.split('\n').map((line, i) => {
            const match = line.trim().match(/^([A-D])\s+(.*)/);
            if (match) {
              return (
                <div key={i} style={{ marginBottom: '0.5rem', lineHeight: '1.5', display: 'flex', gap: '0.5rem' }}>
                  <span style={{
                    fontWeight: 'bold', background: 'rgba(16,185,129,0.2)', color: '#065f46',
                    padding: '0 6px', borderRadius: '4px', height: 'fit-content', flexShrink: 0
                  }}>
                    {match[1]}
                  </span>
                  <span>{match[2]}</span>
                </div>
              );
            }
            if (!line.trim()) return null;
            return <div key={i} style={{ marginBottom: '0.5rem', lineHeight: '1.6' }}>{line}</div>;
          })}
        </div>
      )}
    </div>
  );
};

// Transcript / Translation container displayed when answer is checked
function GroupTranscriptView({ passageText, transcript }) {
  if (!passageText && !transcript) return null;

  return (
    <div style={{
      marginTop: '1.25rem',
      padding: '1rem 1.25rem',
      background: 'rgba(59, 130, 246, 0.04)',
      border: '1px solid rgba(59, 130, 246, 0.2)',
      borderRadius: '8px',
      fontSize: '0.9rem',
      color: '#1a2e3b'
    }}>
      {passageText && (
        <div style={{ marginBottom: transcript ? '1.25rem' : 0 }}>
          <div style={{
            fontWeight: 700,
            color: '#1d4ed8',
            marginBottom: '0.5rem',
            fontSize: '0.95rem',
            display: 'flex',
            alignItems: 'center',
            gap: '0.4rem'
          }}>
            <span>📝</span> English Transcript:
          </div>
          <PassageRenderer content={passageText} />
        </div>
      )}

      {transcript && (
        <div style={{
          borderTop: passageText ? '1px dashed rgba(59, 130, 246, 0.25)' : 'none',
          paddingTop: passageText ? '1rem' : 0
        }}>
          <div style={{
            fontWeight: 700,
            color: '#0369a1',
            marginBottom: '0.5rem',
            fontSize: '0.95rem',
            display: 'flex',
            alignItems: 'center',
            gap: '0.4rem'
          }}>
            <span>🇻🇳</span> Dịch tiếng Việt:
          </div>
          <PassageRenderer content={transcript} />
        </div>
      )}
    </div>
  );
}

export function ListeningPicture({ question, selectedOption, onSelectOption, mode, checkedQuestions, onCheckAnswer }) {
  const isChecked = checkedQuestions && checkedQuestions[question.id];
  const group = question.groupData;

  return (
    <>
      <div className="iig-col-left">
        <div className="iig-instruction">{question.instruction}</div>
        <div style={{ textAlign: 'center' }}>
          {group?.imageUrl ? (
             /* eslint-disable-next-line @next/next/no-img-element */
             <img src={`${process.env.NEXT_PUBLIC_API_URL}/media/${group.imageUrl}`} alt="Question visual" style={{ maxWidth: '100%', maxHeight: '50vh', objectFit: 'contain', border: '1px solid #e0e0e0', padding: '4px' }} />
          ) : (
             <div style={{ fontStyle: 'italic', color: '#777' }}>Image not provided</div>
          )}
        </div>
        {mode !== 'full' && group?.audioUrl && (
           <div style={{ marginTop: '1.5rem' }}>
              <audio src={group.audioUrl.startsWith('http') ? group.audioUrl : `${process.env.NEXT_PUBLIC_API_URL}/media/${group.audioUrl}`} controls style={{ width: '100%' }} />
           </div>
        )}
        {isChecked && <GroupTranscriptView passageText={group?.passageText} transcript={group?.transcript} />}
      </div>
      <div className="iig-col-right">
        <div className="iig-question-header">Question</div>
        <div className="iig-question-text">
          {question.questionNumber}. {(isChecked && question.questionText) ? question.questionText : `Question ${question.questionNumber}`}
        </div>
        <OptionsList question={question} selections={{ [question.id]: selectedOption }} onSelectOption={onSelectOption} hideText={true} mode={mode} checkedQuestions={checkedQuestions} onCheckAnswer={onCheckAnswer} />
      </div>
    </>
  );
}

export function ListeningResponse({ question, selectedOption, onSelectOption, mode, checkedQuestions, onCheckAnswer }) {
  const isChecked = checkedQuestions && checkedQuestions[question.id];
  const group = question.groupData;

  return (
    <>
      <div className="iig-col-left">
        <div className="iig-instruction">{question.instruction}</div>
        {mode !== 'full' && group?.audioUrl && (
           <div style={{ marginTop: '1rem' }}>
              <audio src={group.audioUrl.startsWith('http') ? group.audioUrl : `${process.env.NEXT_PUBLIC_API_URL}/media/${group.audioUrl}`} controls style={{ width: '100%' }} />
           </div>
        )}
        {isChecked && <GroupTranscriptView passageText={group?.passageText} transcript={group?.transcript} />}
      </div>
      <div className="iig-col-right">
        <div className="iig-question-header">Question</div>
        <div className="iig-question-text">
          {question.questionNumber}. {(isChecked && question.questionText) ? question.questionText : `Question ${question.questionNumber}`}
        </div>
        <OptionsList question={question} selections={{ [question.id]: selectedOption }} onSelectOption={onSelectOption} hideText={true} mode={mode} checkedQuestions={checkedQuestions} onCheckAnswer={onCheckAnswer} />
      </div>
    </>
  );
}

export function ListeningAudioGroup({ questions, group, selections, onSelectOption, mode, checkedQuestions, onCheckAnswer }) {
  const isChecked = questions.some(q => checkedQuestions && checkedQuestions[q.id]);
  const allChecked = questions.every(q => checkedQuestions && checkedQuestions[q.id]);
  const allAnswered = questions.every(q => selections && selections[q.id]);
  const answeredCount = questions.filter(q => selections && selections[q.id]).length;

  return (
    <>
      <div className="iig-col-left">
        {questions.length > 0 && (
          <div className="iig-instruction">{questions[0].instruction}</div>
        )}
        {group?.imageUrl && (
          <div style={{ textAlign: 'center', marginBottom: '1.5rem' }}>
             {/* eslint-disable-next-line @next/next/no-img-element */}
             <img src={`${process.env.NEXT_PUBLIC_API_URL}/media/${group.imageUrl}`} alt="Group visual" style={{ maxWidth: '100%', maxHeight: '50vh', objectFit: 'contain', border: '1px solid #e0e0e0', padding: '4px' }} />
          </div>
        )}
        {mode !== 'full' && group?.audioUrl && (
           <div style={{ marginTop: '1rem' }}>
              <audio src={group.audioUrl.startsWith('http') ? group.audioUrl : `${process.env.NEXT_PUBLIC_API_URL}/media/${group.audioUrl}`} controls style={{ width: '100%' }} />
           </div>
        )}
        {isChecked && <GroupTranscriptView passageText={group?.passageText} transcript={group?.transcript} />}
      </div>
      <div className="iig-col-right">
        <div className="iig-question-header">Question</div>
        {questions.map(q => (
          <div key={q.id}>
            <div className="iig-question-text">{q.questionNumber}. {q.questionText}</div>
            <OptionsList question={q} selections={selections} onSelectOption={onSelectOption} mode={mode} checkedQuestions={checkedQuestions} onCheckAnswer={onCheckAnswer} showCheckButton={false} />
          </div>
        ))}

        {mode !== 'full' && !allChecked && (
          <div style={{ marginTop: '1.5rem', paddingTop: '1rem', borderTop: '1px solid #e0e0e0' }}>
            <button 
              onClick={() => {
                const ids = questions.map(q => q.id);
                onCheckAnswer(ids);
              }}
              disabled={!allAnswered}
              className="iig-check-btn"
              style={{
                width: '100%',
                padding: '10px 16px',
                fontSize: '0.95rem',
                fontWeight: 'bold',
                opacity: allAnswered ? 1 : 0.6,
                cursor: allAnswered ? 'pointer' : 'not-allowed',
                backgroundColor: allAnswered ? '#004b87' : '#94a3b8'
              }}
            >
              {allAnswered ? 'Check Answers' : `Select all answers to check (${answeredCount}/${questions.length})`}
            </button>
          </div>
        )}
      </div>
    </>
  );
}

export function IncompleteSentence({ question, selectedOption, onSelectOption, mode, checkedQuestions, onCheckAnswer }) {
  return (
    <div className="iig-col-single">
      <div className="iig-instruction">{question.instruction}</div>
      <div className="iig-question-header">Question</div>
      <div className="iig-question-text" style={{ fontSize: '1.15rem' }}>{question.questionNumber}. {question.questionText}</div>
      <OptionsList question={question} selections={{ [question.id]: selectedOption }} onSelectOption={onSelectOption} mode={mode} checkedQuestions={checkedQuestions} onCheckAnswer={onCheckAnswer} />
    </div>
  );
}

export function ReadingPassageGroup({ questions, group, selections, onSelectOption, mode, checkedQuestions, onCheckAnswer }) {
  const isChecked = questions.some(q => checkedQuestions && checkedQuestions[q.id]);
  const allChecked = questions.every(q => checkedQuestions && checkedQuestions[q.id]);
  const allAnswered = questions.every(q => selections && selections[q.id]);
  const answeredCount = questions.filter(q => selections && selections[q.id]).length;

  return (
    <>
      <div className="iig-col-left">
        {questions.length > 0 && (
          <div className="iig-instruction">{questions[0].instruction}</div>
        )}
        <div className="iig-passage-box">
           {group?.passageText ? (
             <PassageRenderer content={group.passageText} />
           ) : (
             "Passage text not available."
           )}
        </div>
        {isChecked && group?.transcript && (
          <GroupTranscriptView transcript={group.transcript} />
        )}
      </div>
      <div className="iig-col-right">
        <div className="iig-question-header">Question</div>
        {questions.map(q => (
          <div key={q.id}>
            <div className="iig-question-text">{q.questionNumber}. {q.questionText}</div>
            <OptionsList question={q} selections={selections} onSelectOption={onSelectOption} hideText={!q.options} mode={mode} checkedQuestions={checkedQuestions} onCheckAnswer={onCheckAnswer} showCheckButton={false} />
          </div>
        ))}

        {mode !== 'full' && !allChecked && (
          <div style={{ marginTop: '1.5rem', paddingTop: '1rem', borderTop: '1px solid #e0e0e0' }}>
            <button 
              onClick={() => {
                const ids = questions.map(q => q.id);
                onCheckAnswer(ids);
              }}
              disabled={!allAnswered}
              className="iig-check-btn"
              style={{
                width: '100%',
                padding: '10px 16px',
                fontSize: '0.95rem',
                fontWeight: 'bold',
                opacity: allAnswered ? 1 : 0.6,
                cursor: allAnswered ? 'pointer' : 'not-allowed',
                backgroundColor: allAnswered ? '#004b87' : '#94a3b8'
              }}
            >
              {allAnswered ? 'Check Answers' : `Select all answers to check (${answeredCount}/${questions.length})`}
            </button>
          </div>
        )}
      </div>
    </>
  );
}

