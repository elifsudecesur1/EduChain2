import React, { useState } from 'react';
import { ethers } from 'ethers';
import { useNavigate } from 'react-router-dom';

const WalletConnect = () => {
  const [walletAddress, setWalletAddress] = useState(null);
  const [network, setNetwork] = useState(null);
  const navigate = useNavigate();

  const connectWallet = async () => {
    if (window.ethereum) {
      try {
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        await provider.send("eth_requestAccounts", []);
        const signer = provider.getSigner();
        const address = await signer.getAddress();

        const { chainId } = await provider.getNetwork();

        if (chainId === 656476) { 
          setWalletAddress(address);
          setNetwork("Arbitrum Sepolia Testnet");
          navigate('/profile-setup'); 
        } else {
          alert('Please connect to the correct network.');
        }
      } catch (err) {
        console.error("Error connecting to wallet", err);
      }
    } else {
      alert("MetaMask is not installed!");
    }
  };

  return (
    <div style={styles.container}>
      <div style={styles.card}>
        <h2 style={styles.title}>Connect Your Wallet</h2>
        <button style={styles.button} onClick={connectWallet}>
          Connect Wallet
        </button>
        {walletAddress && (
          <div style={styles.walletInfo}>
            <p><strong>Connected Wallet:</strong> {walletAddress}</p>
            <p><strong>Network:</strong> {network}</p>
          </div>
        )}
      </div>
    </div>
  );
};

// Inline CSS styles
const styles = {
  container: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    height: '100vh',
    backgroundColor: '#21a8f2',
    fontFamily: 'Arial, sans-serif',
  },
  card: {
    backgroundColor: '#ffffff',
    padding: '30px',
    borderRadius: '15px',
    boxShadow: '0 10px 20px rgba(0, 0, 0, 0.1)',
    textAlign: 'center',
    maxWidth: '400px',
    width: '100%',
  },
  title: {
    fontSize: '24px',
    color: '#ff8210',
    marginBottom: '20px',
  },
  button: {
    backgroundColor: '#ff8210',
    color: '#ffffff',
    padding: '15px 25px',
    fontSize: '16px',
    border: 'none',
    borderRadius: '10px',
    cursor: 'pointer',
    transition: 'background-color 0.3s ease',
  },
  buttonHover: {
    backgroundColor: '#d36c0d', // Darker shade for hover effect
  },
  walletInfo: {
    marginTop: '20px',
    textAlign: 'left',
    fontSize: '16px',
    color: '#333', // Dark text color for readability
  },
};

export default WalletConnect;
