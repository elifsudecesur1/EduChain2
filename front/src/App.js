import React from 'react';
import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
import WalletConnect from './components/walletconnect';
import MainPage from './pages/mainpage';
import ProfileSetup from './pages/ProfileSetup';
// import your new components here
import TasksPage from './pages/TasksPage';
import PostJobPage from './pages/PostJobPage';

const App = () => {
  return (
    <Router>
      <div>
        <Routes>
          <Route path="/" element={<WalletConnect />} />
          <Route path="/profile-setup" element={<ProfileSetup />} />
          <Route path="/mainpage" element={<MainPage />} />
          <Route path="/tasks" element={<TasksPage />} />
          <Route path="/post-job" element={<PostJobPage />} />
        </Routes>
      </div>
    </Router>
  );
}

export default App;
