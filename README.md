# 🦎 Wildlife Protection Bounties

*A decentralized platform for incentivizing wildlife conservation through blockchain technology*

## 🌟 Overview

Wildlife Protection Bounties is a smart contract platform built on the Stacks blockchain that enables conservationists, organizations, and individuals to create bounty programs for wildlife protection activities. The system rewards users who provide verifiable evidence of conservation efforts, creating economic incentives for protecting endangered species and their habitats.

## 🚀 Features

- **🎯 Bounty Creation**: Create custom bounties for specific wildlife protection activities
- **📸 Evidence Submission**: Submit cryptographic evidence of conservation work
- **✅ Decentralized Verification**: Trusted verifiers validate submitted evidence
- **💰 Automated Rewards**: Smart contract automatically distributes STX rewards
- **📊 User Statistics**: Track your contributions and earnings
- **⏰ Time-bound Bounties**: Set expiration dates for bounties
- **🔐 Secure**: Built with robust error handling and access controls

## 🏗️ Contract Architecture

### Core Components

1. **Bounty System**: Create and manage wildlife protection bounties
2. **Evidence Chain**: Secure submission and verification of conservation evidence
3. **Verifier Network**: Trusted validators who approve legitimate conservation work
4. **Reward Distribution**: Automatic STX payments to successful claimants

### Key Functions

#### Public Functions

- `create-bounty`: Create a new wildlife protection bounty
- `claim-bounty`: Submit evidence to claim a bounty reward
- `verify-bounty`: Verify submitted evidence (verifiers only)
- `cancel-bounty`: Cancel an open or expired bounty
- `add-verifier`: Add trusted verifiers (owner only)
- `remove-verifier`: Remove verifiers (owner only)

#### Read-Only Functions

- `get-bounty`: Retrieve bounty details
- `get-user-stats`: View user statistics
- `get-verifier-status`: Check verifier status
- `get-contract-stats`: View contract statistics
- `is-bounty-expired`: Check if bounty has expired

## 🛠️ Usage Guide

### Creating a Bounty

```clarity
(contract-call? .wildlife-protection-bounties create-bounty 
  "Save the Tigers"
  "Document tiger populations in protected reserves"
  "GPS coordinates, photo evidence, and timestamp required"
  u1440) ;; 1440 blocks (~10 days)
```

### Claiming a Bounty

```clarity
(contract-call? .wildlife-protection-bounties claim-bounty
  u1
  "sha256hash-of-evidence-package")
```

### Verifying Evidence

```clarity
(contract-call? .wildlife-protection-bounties verify-bounty
  u1
  true) ;; true = approved, false = rejected
```

## 🎮 Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- STX tokens for creating bounties
- Basic understanding of Stacks blockchain

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd Wildlife-Protection-Bounties
```

2. Install dependencies:
```bash
npm install
```

3. Run tests:
```bash
npm test
```

4. Deploy locally:
```bash
clarinet integrate
```

## 📋 Contract States

### Bounty Status Flow

1. **open** → New bounty accepting claims
2. **claimed** → Evidence submitted, awaiting verification  
3. **verified** → Evidence approved, reward distributed
4. **rejected** → Evidence rejected, bounty reopened
5. **cancelled** → Bounty cancelled by creator

## 💡 Use Cases

- **🐘 Anti-Poaching**: Reward rangers for patrol documentation
- **🌳 Habitat Restoration**: Incentivize reforestation efforts
- **📊 Wildlife Surveys**: Pay for species population counts
- **🚯 Cleanup Initiatives**: Reward environmental cleanup activities
- **📱 Conservation Apps**: Integrate with mobile conservation platforms

## 🔒 Security Features

- **Access Control**: Owner-only functions for critical operations
- **Input Validation**: Comprehensive parameter checking
- **Time-based Logic**: Automatic expiration handling
- **Fraud Prevention**: Evidence hash verification system
- **Balance Checks**: Ensures sufficient funds before operations

## 📊 Error Codes

| Code | Error | Description |
|------|-------|-------------|
| u100 | `err-owner-only` | Function restricted to contract owner |
| u101 | `err-not-found` | Bounty or resource not found |
| u102 | `err-invalid-bounty` | Invalid bounty parameters |
| u103 | `err-already-claimed` | Bounty already claimed |
| u104 | `err-not-claimed` | Bounty not in claimed state |
| u105 | `err-insufficient-funds` | Insufficient STX balance |
| u106 | `err-unauthorized` | Unauthorized operation |
| u107 | `err-expired` | Bounty has expired |
| u108 | `err-not-expired` | Bounty has not expired |

## 🌍 Environmental Impact

By creating economic incentives for wildlife protection, this platform:

- **Motivates Conservation**: Direct rewards for protection efforts
- **Increases Documentation**: Better tracking of wildlife populations
- **Builds Community**: Connects conservationists globally
- **Scales Impact**: Blockchain technology enables global participation

## 🤝 Contributing

We welcome contributions to improve wildlife protection efforts!

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details

## 🦋 Join the Movement

Every contribution helps protect our planet's precious wildlife. Start creating bounties, submitting evidence, and earning rewards while making a real difference!

---

*Built with ❤️ for wildlife conservation on the Stacks blockchain* 🌿

# Wildlife Protection Bounties

