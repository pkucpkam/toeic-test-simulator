// src/utils/history.js
export const saveTestResult = (testId, mode, score, timeTaken, totalQuestions) => {
  if (typeof window === 'undefined') return;
  const history = getTestHistory();
  
  const newResult = {
    id: Date.now().toString(),
    testId,
    mode,
    score,
    totalQuestions,
    timeTaken, // in seconds
    date: new Date().toISOString()
  };
  
  history.push(newResult);
  localStorage.setItem('test_history', JSON.stringify(history));
  return newResult;
};

export const getTestHistory = () => {
  if (typeof window === 'undefined') return [];
  const historyStr = localStorage.getItem('test_history');
  return historyStr ? JSON.parse(historyStr) : [];
};
