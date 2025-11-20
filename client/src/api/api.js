import axios from 'axios';

const APP_URL = import.meta.env['VITE_REACT_APP_BASE_URL'];

export const fetchResponse = async (
  userMessage,
  { onChunk, onFinish, onError }
) => {
  try {
    const response = await axios.post(APP_URL + '/ask', { query: userMessage });
    if (response.status === 500) {
      onError('server error');
      return;
    }

    onFinish(response.data.answer);
    return { answer: response.data.answer, resources: response.data.resources };
  } catch (error) {
    onError('transmition error ' + error.message);
  }
};
