# Solidity Design Patterns

A collection of smart contract patterns for learning Solidity design patterns and TypeScript automation.

## Overview

This project is a **learning exercise** to demonstrate various Solidity design patterns. It includes:

### Oracle Pattern
- **Oracle Contract**: Stores and manages exchange rates with enum-based currency types
- **Oracle Consumer**: Gas-optimized contract that consumes oracle data with built-in staleness checks
- **Off-chain Feeder**: TypeScript service that fetches real exchange rates and updates the oracle

### Proxy Pattern
- **Proxy Contract**: EIP-1967 compliant transparent proxy for contract upgrades
- **ProxyAdmin**: Administrative contract for managing proxy upgrades
- **Implementation Contracts**: Upgradeable logic contracts with versioning support

## Key Features

### Oracle Pattern
- **Gas Optimization**: Single contract call for rate retrieval with timestamp-based staleness checking
- **Type Safety**: Uses Solidity enums for currency types (EUR=0, USD=1)
- **Owner Protection**: Only contract owner can update rates
- **Staleness Protection**: Automatic rejection of rates older than 1 hour
- **Real-time Updates**: Automated off-chain service updates rates every 3 seconds

### Proxy Pattern
- **EIP-1967 Compliance**: Uses standard storage slots for implementation address
- **Transparent Proxy**: Admin calls are intercepted, user calls are delegated to implementation
- **Access Control**: Owner-only upgrades through ProxyAdmin contract
- **Upgrade Safety**: Validates new implementations and supports initialization data
- **Event Emission**: Tracks implementation updates for transparency

## Architecture

### Smart Contracts

#### Oracle Pattern

**Oracle.sol**
- Stores exchange rates with timestamps
- Uses `Currency` enum for type safety
- Emits events on rate updates
- Returns rate and timestamp in single call

**OracleConsumer.sol**  
- Consumes oracle data efficiently
- Performs staleness checks locally to save gas
- Provides conversion utilities (XOF to USD/EUR)
- Public rate getter functions with built-in validation

#### Proxy Pattern

**Proxy.sol**
- EIP-1967 compliant transparent proxy contract
- Delegates all non-admin calls to implementation
- Restricts admin to upgrade function only
- Uses assembly for gas-efficient storage access

**ProxyAdmin.sol**
- Manages proxy upgrades with owner-only access
- Validates implementation contracts before upgrade
- Supports initialization data during upgrades
- Provides secure ownership transfer mechanism

**ProxyImplementation.sol / ProxyImplementationV2.sol**
- Example implementation contracts showing upgrade patterns
- V2 demonstrates storage compatibility and feature additions
- Implements consistent interface across versions

### Off-chain Service

#### oracle.ts
- Fetches live exchange rates from external API
- Updates oracle contract automatically
- Handles transaction errors and retries
- Logs all operations for monitoring

## Usage

### Smart Contract Deployment

```shell
forge build
forge script script/Deploy.s.sol --rpc-url <rpc_url> --private-key <private_key>
```

### Off-chain Service Setup

```bash
cd off-chain
npm install
```

Create `.env` file:
```
RPC_URL=your_rpc_endpoint
PRIVATE_KEY=your_wallet_private_key  
ORACLE_ADDRESS=deployed_oracle_contract_address
```

Run the oracle feeder:
```bash
npm start
```

### Interacting with Oracle

```solidity
// Get USD to XOF rate (reverts if stale)
(uint256 rate, uint256 timestamp) = consumer.getUSDToXOFRate();

// Convert 100 USD to XOF
uint256 xofAmount = consumer.convertUSDToXOF(100 * 1e18);

// Get EUR to XOF rate
(uint256 eurRate, uint256 timestamp) = consumer.getEURToXOFRate();
```

### Interacting with Proxy

```solidity
// Deploy proxy with initial implementation
Proxy proxy = new Proxy(implementationAddress, adminAddress);

// Upgrade implementation (admin only)
ProxyAdmin admin = ProxyAdmin(adminAddress);
admin.updateImplementation(address(proxy), newImplementationAddress, initData);

// Call implementation functions through proxy
IProxyImplementation(address(proxy)).depositMoney(amount);
```

## Learning Objectives

This educational project demonstrates:
- Gas optimization techniques (single call retrieval, local validation)
- Solidity design patterns (Oracle pattern, Proxy pattern, Consumer pattern)
- Enum usage for type safety and gas efficiency
- EIP-1967 proxy standards and upgrade patterns
- Off-chain automation with TypeScript
- Error handling and custom error types
- Owner access control patterns
- Contract upgradeability and storage compatibility

## Gas Optimization

The pattern optimizes gas usage by:
- Combining rate and timestamp retrieval in single call
- Moving staleness validation to consumer contract
- Using enums instead of strings for currency identification
- Eliminating redundant external calls

## Development

### Build
```shell
forge build
```

### Test
```shell
forge test
```

### Format
```shell
forge fmt
```

---

## Foundry Toolkit

This project uses Foundry for Ethereum development:

- **Forge**: Testing framework
- **Cast**: Contract interaction tool  
- **Anvil**: Local Ethereum node
- **Chisel**: Solidity REPL

Documentation: https://book.getfoundry.sh/