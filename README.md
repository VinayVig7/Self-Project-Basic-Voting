# 🗳️ Voting Smart Contract

A decentralized on-chain voting system written in Solidity. This project enables users to propose ideas, cast votes, and execute proposals with strict timing and threshold rules to ensure transparency and fairness.

---

## 📌 Features

- 📤 Create proposals with a title and a fixed voting window
- ✅ Vote only during the allowed time period
- 🔒 Prevent double voting with address tracking
- ⏳ Set thresholds like minimum votes and delay before voting begins
- 🧠 Enum-based state management (`PENDING`, `ACTIVE`, `EXECUTED`)
- 🧾 Emits events for off-chain UI integration and tracking

---

## 🛠️ Built With

- [Solidity ^0.8.24](https://docs.soliditylang.org/)
- [Foundry](https://book.getfoundry.sh/) (Smart contract toolkit)
- [forge-std](https://github.com/foundry-rs/forge-std) (Standard library for testing and scripting)

---

## 📁 Project Structure

.
├── src/
│ └── Voting.sol # Main Voting contract
├── script/
│ └── DeployVoting.s.sol # Deployment script using keystore
├── test/
│ ├── Voting.t.sol # Unit tests for contract logic
│ └── DeployVotingTest.t.sol # Test for deployment script
├── foundry.toml # Foundry configuration file
└── README.md # This file

---

## 🚀 Deployment (Using Keystore)

This project uses **keystore-based deployment** instead of exposing raw private keys. Ensure your keystore file and password are correctly set up.

### ✅ Setup

Install Foundry and build the project:

```bash
forge install
forge build
```

## 📦 Deploy the Contract
```bash
forge script script/DeployVoting.s.sol \
  --rpc-url $RPC_URL \
  --broadcast \
  --keystore $ETH_KEYSTORE \
  --password $ETH_PASSWORD
  ```

## 🧪 Run Tests
```bash
forge test -vv
```

```markdown
## 📜 Contract Overview

### Constructor

```solidity
constructor(uint256 votingTime, uint256 minimumVoteThreshold, uint256 waitingTime)
```

### Key Functions

| Function                          | Description                                                  |
|----------------------------------|--------------------------------------------------------------|
| `createProposal(string)`         | Creates a new proposal with delayed start                    |
| `vote(uint256)`                  | Casts a vote (only if allowed)                               |
| `executeProposal(uint256)`       | Executes proposal if minimum threshold and time met          |
| `getProposal(uint256)`           | Retrieves full proposal struct                               |
| `hasVoted(uint256, address)`     | Checks if an address has already voted                       |

---

## 🔐 Security & Validations

- `Voting__AlreadyVoted`: Prevents double voting  
- `Voting__VotingEnded`: Prevents voting after deadline  
- `Voting__VotingNotStarted`: Ensures voting starts after delay  
- `Voting__ProposalNotExecutable`: Validates execution conditions  
- `Voting__NoProposal`: Handles invalid or missing proposal IDs  

---

## 📄 License

MIT © 2025

---
🛠️ Developed with ❤️ by **Vinay Vig**
```