import React from 'react';

const OptionsList = ({ question, selections, onSelectOption, hideText = false, mode, checkedQuestions, onCheckAnswer }) => {
  const optionsToRender = question.options || ["(A)", "(B)", "(C)", "(D)"];
  const isChecked = checkedQuestions && checkedQuestions[question.id];
  const hasSelection = selections && selections[question.id];

  return (
    <div className="iig-option-list" style={{ marginBottom: '1.5rem' }}>
      {optionsToRender.map((opt, i) => {
        const optionLabel = hideText ? opt.substring(0, 3) : opt;
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
      
      {mode !== 'full' && !isChecked && hasSelection && (
        <button 
          onClick={() => onCheckAnswer(question.id)}
          className="iig-check-btn"
        >
          Check Answer
        </button>
      )}

      {isChecked && question.explanation && (
        <div className="iig-explanation-box">
          <strong>Explanation: </strong> {question.explanation}
        </div>
      )}
    </div>
  );
};

export function ListeningPicture({ question, selectedOption, onSelectOption, mode, checkedQuestions, onCheckAnswer }) {
  return (
    <>
      <div className="iig-col-left">
        <div className="iig-instruction">{question.instruction}</div>
        <div style={{ textAlign: 'center' }}>
          {question.groupData?.imageUrl ? (
             /* eslint-disable-next-line @next/next/no-img-element */
             <img src={`${process.env.NEXT_PUBLIC_API_URL}/media/${question.groupData.imageUrl}`} alt="Question visual" style={{ maxWidth: '100%', border: '1px solid #e0e0e0', padding: '4px' }} />
          ) : (
             <div style={{ fontStyle: 'italic', color: '#777' }}>Image not provided</div>
          )}
        </div>
        {mode !== 'full' && question.groupData?.audioUrl && (
           <div style={{ marginTop: '1.5rem' }}>
              <audio src={question.groupData.audioUrl.startsWith('http') ? question.groupData.audioUrl : `${process.env.NEXT_PUBLIC_API_URL}/media/${question.groupData.audioUrl}`} controls style={{ width: '100%' }} />
           </div>
        )}
      </div>
      <div className="iig-col-right">
        <div className="iig-question-header">Question</div>
        <div style={{ marginBottom: '1rem', fontWeight: 'bold' }}>{question.questionNumber}. Question {question.questionNumber}</div>
        <OptionsList question={question} selections={{ [question.id]: selectedOption }} onSelectOption={onSelectOption} hideText={true} mode={mode} checkedQuestions={checkedQuestions} onCheckAnswer={onCheckAnswer} />
      </div>
    </>
  );
}

export function ListeningResponse({ question, selectedOption, onSelectOption, mode, checkedQuestions, onCheckAnswer }) {
  return (
    <>
      <div className="iig-col-left">
        <div className="iig-instruction">{question.instruction}</div>
        {mode !== 'full' && question.groupData?.audioUrl && (
           <div style={{ marginTop: '1rem' }}>
              <audio src={question.groupData.audioUrl.startsWith('http') ? question.groupData.audioUrl : `${process.env.NEXT_PUBLIC_API_URL}/media/${question.groupData.audioUrl}`} controls style={{ width: '100%' }} />
           </div>
        )}
      </div>
      <div className="iig-col-right">
        <div className="iig-question-header">Question</div>
        <div style={{ marginBottom: '1rem', fontWeight: 'bold' }}>{question.questionNumber}. Question {question.questionNumber}</div>
        <OptionsList question={question} selections={{ [question.id]: selectedOption }} onSelectOption={onSelectOption} hideText={true} mode={mode} checkedQuestions={checkedQuestions} onCheckAnswer={onCheckAnswer} />
      </div>
    </>
  );
}

export function ListeningAudioGroup({ questions, group, selections, onSelectOption, mode, checkedQuestions, onCheckAnswer }) {
  return (
    <>
      <div className="iig-col-left">
        {questions.length > 0 && (
          <div className="iig-instruction">{questions[0].instruction}</div>
        )}
        {group?.imageUrl && (
          <div style={{ textAlign: 'center', marginBottom: '1.5rem' }}>
             <img src={`${process.env.NEXT_PUBLIC_API_URL}/media/${group.imageUrl}`} alt="Group visual" style={{ maxWidth: '100%', border: '1px solid #e0e0e0', padding: '4px' }} />
          </div>
        )}
        {mode !== 'full' && group?.audioUrl && (
           <div style={{ marginTop: '1rem' }}>
              <audio src={group.audioUrl.startsWith('http') ? group.audioUrl : `${process.env.NEXT_PUBLIC_API_URL}/media/${group.audioUrl}`} controls style={{ width: '100%' }} />
           </div>
        )}
      </div>
      <div className="iig-col-right">
        <div className="iig-question-header">Question</div>
        {questions.map(q => (
          <div key={q.id}>
            <div style={{ marginBottom: '1rem', fontWeight: 'bold' }}>{q.questionNumber}. {q.questionText}</div>
            <OptionsList question={q} selections={selections} onSelectOption={onSelectOption} mode={mode} checkedQuestions={checkedQuestions} onCheckAnswer={onCheckAnswer} />
          </div>
        ))}
      </div>
    </>
  );
}

export function IncompleteSentence({ question, selectedOption, onSelectOption, mode, checkedQuestions, onCheckAnswer }) {
  return (
    <>
      <div className="iig-col-left">
        <div className="iig-instruction">{question.instruction}</div>
      </div>
      <div className="iig-col-right">
        <div className="iig-question-header">Question</div>
        <div style={{ marginBottom: '1rem', fontWeight: 'bold' }}>{question.questionNumber}. {question.questionText}</div>
        <OptionsList question={question} selections={{ [question.id]: selectedOption }} onSelectOption={onSelectOption} mode={mode} checkedQuestions={checkedQuestions} onCheckAnswer={onCheckAnswer} />
      </div>
    </>
  );
}

export function ReadingPassageGroup({ questions, group, selections, onSelectOption, mode, checkedQuestions, onCheckAnswer }) {
  return (
    <>
      <div className="iig-col-left">
        {questions.length > 0 && (
          <div className="iig-instruction">{questions[0].instruction}</div>
        )}
        <div style={{ border: '1px solid #e0e0e0', padding: '1.5rem', whiteSpace: 'pre-wrap', lineHeight: '1.6', fontSize: '0.95rem' }}>
           {group?.passageText || "Passage text not available."}
        </div>
      </div>
      <div className="iig-col-right">
        <div className="iig-question-header">Question</div>
        {questions.map(q => (
          <div key={q.id}>
            <div style={{ marginBottom: '1rem', fontWeight: 'bold' }}>{q.questionNumber}. {q.questionText}</div>
            <OptionsList question={q} selections={selections} onSelectOption={onSelectOption} hideText={!q.options} mode={mode} checkedQuestions={checkedQuestions} onCheckAnswer={onCheckAnswer} />
          </div>
        ))}
      </div>
    </>
  );
}
