import React from 'react';
import { Route, Routes } from 'react-router-dom';
import ConversationPage from './pages/conversation-page';
import NotFound from './pages/not_found';
import Settings from './pages/settings';
function App() {
  return (
    <>
      <Routes>
        <Route path='/chat' element={<ConversationPage />} />
        <Route path='/settings' element={<Settings />}></Route>
        <Route path='*' element={<NotFound />} />
      </Routes>
    </>
  );
}

export default App;
