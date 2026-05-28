// src/contractDetails.js
export const ADDRESS = "0xd9145CCE52D386f254917e481eB44e9943F39138";

export const ABI = [
  {
    "anonymous": false,
    "inputs": [
      { "indexed": true, "internalType": "address", "name": "user", "type": "address" },
      { "indexed": false, "internalType": "uint256", "name": "newScore", "type": "uint256" }
    ],
    "name": "ScoreUpdated",
    "type": "event"
  },
  {
    "inputs": [{ "internalType": "uint256", "name": "score", "type": "uint256" }],
    "name": "getCreditRating",
    "outputs": [{ "internalType": "string", "name": "", "type": "string" }],
    "stateMutability": "pure",
    "type": "function"
  },
  {
    "inputs": [{ "internalType": "address", "name": "", "type": "address" }],
    "name": "profiles",
    "outputs": [
      { "internalType": "uint256", "name": "score" },
      { "internalType": "bool", "name": "exists" }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [{ "internalType": "uint256", "name": "_score", "type": "uint256" }],
    "name": "updateScore",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  }
];
