import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';

const ProfileSetup = () => {
  const [role, setRole] = useState(null);
  const navigate = useNavigate();

  const handleRoleSelection = (selectedRole) => {
    setRole(selectedRole);
  };

  const handleContinue = () => {
    if (role) {
      console.log(`Creating profile as: ${role}`);
      navigate('/mainpage', { state: { role } }); // Pass role to MainPage
    } else {
      alert('Please select a role!');
    }
  };

  return (
    <div style={styles.container}>
      <div style={styles.card}>
        <div style={styles.imageContainer}>
          <img src={`${process.env.PUBLIC_URL}/resim1.png`} alt="Profile Setup" style={styles.image} />
        </div>
        <div style={styles.content}>
          <h2 style={styles.title}>Set Up Your Profile</h2>
          <p>Please select a role:</p>
          <div style={styles.buttonGroup}>
            <button
              onClick={() => handleRoleSelection('Verifier')}
              style={role === 'Verifier' ? styles.selectedButton : styles.button}
            >
              Verifier
            </button>
            <button
              onClick={() => handleRoleSelection('Employee')}
              style={role === 'Employee' ? styles.selectedButton : styles.button}
            >
              Employee
            </button>
            <button
              onClick={() => handleRoleSelection('Employer')}
              style={role === 'Employer' ? styles.selectedButton : styles.button}
            >
              Employer
            </button>
          </div>
          <button onClick={handleContinue} style={styles.continueButton}>
            Continue
          </button>
        </div>
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
    backgroundColor: '#f3f2ef',
  },
  card: {
    display: 'flex',
    backgroundColor: '#ffffff',
    borderRadius: '8px',
    boxShadow: '0 4px 12px rgba(0, 0, 0, 0.1)',
    overflow: 'hidden',
    width: '700px',
    height: '450px',
  },
  imageContainer: {
    width: '40%',
    backgroundColor: '#f3f2ef',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
  },
  image: {
    width: '100%',
    height: 'auto',
    objectFit: 'cover',
  },
  content: {
    width: '60%',
    textAlign: 'center',
  },
  title: {
    color: '#0a66c2',
    marginBottom: '20px',
  },
  buttonGroup: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    width: '100%',
    marginBottom: '20px',
  },
  button: {
    margin: '10px 0',
    padding: '15px 20px',
    borderRadius: '8px',
    border: '1px solid #0a66c2',
    backgroundColor: '#ffffff',
    color: '#0a66c2',
    cursor: 'pointer',
    fontSize: '16px',
    width: '80%',
    transition: 'background-color 0.3s ease, box-shadow 0.3s ease',
  },
  selectedButton: {
    margin: '10px 0',
    padding: '15px 20px',
    borderRadius: '8px',
    border: '1px solid #0a66c2',
    backgroundColor: '#0a66c2',
    color: '#ffffff',
    cursor: 'pointer',
    fontSize: '16px',
    width: '80%',
    boxShadow: '0 4px 8px rgba(0, 0, 0, 0.2)',
    transition: 'background-color 0.3s ease, box-shadow 0.3s ease',
  },
  continueButton: {
    padding: '15px 30px',
    borderRadius: '8px',
    backgroundColor: '#0a66c2',
    color: '#ffffff',
    border: 'none',
    cursor: 'pointer',
    fontSize: '16px',
    transition: 'background-color 0.3s ease, box-shadow 0.3s ease',
  },
};

export default ProfileSetup;
