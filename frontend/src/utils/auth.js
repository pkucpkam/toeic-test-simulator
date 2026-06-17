import apiClient from './apiClient';

export const login = async (email, password) => {
  const response = await apiClient.post('/auth/login', { email, password });
  const { accessToken, refreshToken } = response.data;
  
  localStorage.setItem('accessToken', accessToken);
  localStorage.setItem('refreshToken', refreshToken);
  
  const user = { email, name: email.split('@')[0] };
  localStorage.setItem('user', JSON.stringify(user));
  
  return user;
};

export const register = async (name, email, password) => {
  const response = await apiClient.post('/auth/register', { fullName: name, email, password });
  const { accessToken, refreshToken } = response.data;
  
  localStorage.setItem('accessToken', accessToken);
  localStorage.setItem('refreshToken', refreshToken);
  
  const user = { email, name };
  localStorage.setItem('user', JSON.stringify(user));
  
  return user;
};

export const logout = () => {
  localStorage.removeItem('accessToken');
  localStorage.removeItem('refreshToken');
  localStorage.removeItem('user');
};

export const getUser = () => {
  // TEMPORARY: Auto-login for personal use
  return { email: 'phucpham.1803@gmail.com', name: 'pkucpkam' };
};
