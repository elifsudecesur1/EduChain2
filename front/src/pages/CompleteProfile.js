import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';

const CompleteProfile = () => {
  const [name, setName] = useState('');
  const [occupation, setOccupation] = useState('');
  const [role, setRole] = useState('Employee'); // Default to 'Employee'
  const navigate = useNavigate();

  const handleSaveProfile = () => {
    if (name && occupation && role) {
      // Save the profile data (this can be saved in a global state or local storage)
      const profileData = { name, occupation, role };
      localStorage.setItem('profileData', JSON.stringify(profileData));
      navigate('/mainpage');
    } else {
      alert('Please fill in all fields.');
    }
  };

  return (
    <div style={styles.container}>
      <div style={styles.card}>
        <h2 style={styles.title}>Complete Your Profile</h2>
        <div style={styles.formGroup}>
          <label>Name:</label>
          <input
            type="text"
            value={name}
            onChange={(e) => setName(e.target.value)}
            style={styles.input}
          />
        </div>
        <div style={styles.formGroup}>
          <label>Occupation:</label>
          <input
            type="text"
            value={occupation}
            onChange={(e) => setOccupation(e.target.value)}
            style={styles.input}
          />
        </div>
        <div style={styles.formGroup}>
          <label>Role:</label>
          <select
            value={role}
            onChange={(e) => setRole(e.target.value)}
            style={styles.input}
          >
            <option value="Verifier">Verifier</option>
            <option value="Employee">Employee</option>
            <option value="Employer">Employer</option>
          </select>
        </div>
        <button onClick={handleSaveProfile} style={styles.saveButton}>
          Save Profile
        </button>
      </div>
    </div>
  );
};

const styles = {
  container: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    height: '100vh',
    fontFamily: 'Arial, sans-serif',
    backgroundColor: '#f7f9fc',
    padding: '20px',
  },
  card: {
    width: '400px',
    padding: '20px',
    backgroundColor: '#ffffff',
    borderRadius: '12px',
    boxShadow: '0 6px 20px rgba(0, 0, 0, 0.1)',
  },
  title: {
    color: '#0a66c2',
    marginBottom: '20px',
    fontSize: '24px',
    fontWeight: 'bold',
  },
  formGroup: {
    marginBottom: '15px',
  },
  input: {
    width: '100%',
    padding: '10px',
    borderRadius: '5px',
    border: '1px solid #ccc',
  },
  saveButton: {
    marginTop: '20px',
    padding: '15px 30px',
    borderRadius: '8px',
    backgroundColor: '#0a66c2',
    color: '#ffffff',
    border: 'none',
    cursor: 'pointer',
    fontSize: '16px',
    width: '100%',
    transition: 'background-color 0.3s ease, box-shadow 0.3s ease',
  },
};

export default CompleteProfile;
