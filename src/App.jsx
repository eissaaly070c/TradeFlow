import { useState, useEffect } from 'react';
import { ethers } from 'ethers';
import { ABI, ADDRESS } from './contractDetails';

function App() {
  const [score, setScore] = useState(0);
  const [inputScore, setInputScore] = useState('');
  const [status, setStatus] = useState('');

  useEffect(() => {
    checkConnection();
  }, []);

  const checkConnection = async () => {
    if (window.ethereum) {
      const provider = new ethers.BrowserProvider(window.ethereum);
      const signer = await provider.getSigner();
      const contract = new ethers.Contract(ADDRESS, ABI, signer);
      const userAddress = await signer.getAddress();
      const profile = await contract.profiles(userAddress);
      setScore(Number(profile.score));
    }
  };

  const updateScore = async () => {
    try {
      const provider = new ethers.BrowserProvider(window.ethereum);
      const signer = await provider.getSigner();
      const contract = new ethers.Contract(ADDRESS, ABI, signer);
      setStatus("جاري التحديث...");
      const tx = await contract.updateScore(parseInt(inputScore));
      await tx.wait();
      setScore(parseInt(inputScore));
      setStatus("تم التحديث!");
    } catch (err) {
      setStatus("خطأ في التحديث");
    }
  };

  return (
    <div>
      <h1>Credit Score: {score}</h1>
      <input type="number" onChange={(e) => setInputScore(e.target.value)} />
      <button onClick={updateScore}>تحديث</button>
      <p>{status}</p>
    </div>
  );
}

export default App;
