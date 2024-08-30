import React, { useState, useEffect } from "react";
import './App.css';  

function App() {
  const [account, setAccount] = useState("");

  const connectWallet = async () => {
    if (window.ethereum) {
      try {
        const accounts = await window.ethereum.request({ method: "eth_requestAccounts" });
        setAccount(accounts[0]);
      } catch (error) {
        console.error("Error connecting to MetaMask:", error);
      }
    } else {
      alert("MetaMask is not installed. Please install it to use this app: https://metamask.io/download.html");
    }
  };

  useEffect(() => {
    if (window.ethereum) {
      window.ethereum.on("accountsChanged", (accounts) => {
        setAccount(accounts[0]);
      });
    }
  }, []);

  return (
    <div className="app-container">
      <h1>Connect to MetaMask</h1>
      {account ? (
        <div>
          <p>Connected Wallet Address:</p>
          <p className="wallet-address">{account}</p>
        </div>
      ) : (
        <button onClick={connectWallet} className="connect-button">
          Connect Wallet
        </button>
      )}
    </div>
  );
}

export default App;
