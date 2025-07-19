# Decentralized Organ Donation System

A blockchain-based organ donation platform built on Stacks using Clarity smart contracts to ensure transparency, security, and efficient matching of donors and recipients.

## System Overview

The system consists of five interconnected smart contracts:

### 1. Donor Registry Contract (`donor-registry.clar`)
- Maintains organ donation consent and preferences
- Stores donor information and organ availability
- Manages donor registration and updates

### 2. Compatibility Matching Contract (`compatibility-matching.clar`)
- Identifies suitable organ recipients based on medical compatibility
- Implements matching algorithms for blood type, tissue compatibility
- Prioritizes recipients based on urgency and compatibility scores

### 3. Transplant Coordination Contract (`transplant-coordination.clar`)
- Manages surgical scheduling and logistics
- Coordinates between hospitals, surgeons, and medical teams
- Tracks transplant procedures from initiation to completion

### 4. Medical History Contract (`medical-history.clar`)
- Securely stores donor and recipient health information
- Maintains privacy while allowing authorized access
- Tracks medical conditions and contraindications

### 5. Success Tracking Contract (`success-tracking.clar`)
- Monitors transplant outcomes and survival rates
- Collects post-transplant data for analysis
- Generates success metrics and reports

## Key Features

- **Transparency**: All transactions recorded on blockchain
- **Privacy**: Medical data encrypted and access-controlled
- **Efficiency**: Automated matching reduces wait times
- **Trust**: Immutable records prevent fraud
- **Global Access**: Cross-border organ sharing capabilities

## Contract Interactions

\`\`\`
Donor Registry ←→ Medical History
↓
Compatibility Matching ←→ Medical History
↓
Transplant Coordination
↓
Success Tracking
\`\`\`

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Node.js and npm
- Stacks wallet for testing

### Installation

\`\`\`bash
git clone <repository-url>
cd decentralized-organ-donation
npm install
\`\`\`

### Testing

\`\`\`bash
npm test
\`\`\`

### Deployment

\`\`\`bash
clarinet deploy
\`\`\`

## Usage

### Register as Donor
1. Call `register-donor` function with personal and medical information
2. Specify organs available for donation
3. Set preferences for recipient matching

### Register as Recipient
1. Call `register-recipient` function with medical requirements
2. System automatically matches with compatible donors
3. Receive notifications when matches are found

### Medical Professionals
1. Access authorized medical data for transplant decisions
2. Update transplant status and outcomes
3. Schedule and coordinate procedures

## Security Considerations

- All medical data is encrypted
- Access control through role-based permissions
- Audit trails for all transactions
- Privacy-preserving matching algorithms

## Contributing

Please read our contributing guidelines and submit pull requests for improvements.

## License

This project is licensed under the MIT License.
