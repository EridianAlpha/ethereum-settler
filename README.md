# Ethereum Settlers

- [1. Overview](#1-overview)
- [2. Clone repository](#2-clone-repository)
  - [2.1. Install Dependencies](#21-install-dependencies)
  - [2.2. Create the `.env` file](#22-create-the-env-file)
- [3. Testing](#3-testing)
  - [3.1. Tests](#31-tests)
  - [3.2. Coverage](#32-coverage)
- [4. Deployment](#4-deployment)
  - [4.1. Deploy NFT and Token Contract](#41-deploy-nft-and-token-contract)
  - [4.2. Deploy View Aggregator Contract](#42-deploy-view-aggregator-contract)
- [5. Interactions](#5-interactions)
  - [5.1. Mint Settlement NFT](#51-mint-settlement-nft)
  - [5.2. Get NFT Mint Timestamp](#52-get-nft-mint-timestamp)
  - [5.3. Get Settler Balance](#53-get-settler-balance)
  - [5.4. Get Sequential Data](#54-get-sequential-data)
  - [5.5. Get Random Data](#55-get-random-data)
- [6. License](#6-license)

## 1. Overview

An ERC20 token called `Ethereum Settler` (SETTLER) and an ERC721 NFT token called `Ethereum Settlement` (SETTLEMENT).

Minting a Settlement NFT is free and can be done by anyone. The only cost is the gas fee for the transaction.

Holding a Settlement NFT gives the holder a newly minted SETTLER tokens every second.

Invariant: A Settlement NFT can only be held by one address at a time.

There is nothing stopping multiple addresses from each holding different Settlement NFTs. E.g. Mint ➜ Send ➜ Mint ➜ Send, etc. This means that the SETTLER token can have no monetary value, as it is not a scarce resource and an unlimited amount can be created simply by minting more Settlement NFTs.

The ViewAggregator contract is used to perform batch queries on the Settlement contract to get sequential or random data. This is a view only helper contract that is deployed separately from the Settlement contract.

Live on [https://settlers.eridian.xyz](https://settlers.eridian.xyz)

## 2. Clone repository

```bash
git clone https://github.com/EridianAlpha/ethereum-settlers.git
```

### 2.1. Install Dependencies

This should happen automatically when first running a command, but the installation can be manually triggered with the following commands:

```bash
git submodule init
git submodule update
make install
```

### 2.2. Create the `.env` file

Use the `.env.example` file as a template to create a `.env` file.

## 3. Testing

### 3.1. Tests

```bash
make test
make test-fork

make test-v
make test-v-fork

make test-summary
make test-summary-fork
```

### 3.2. Coverage

```bash
make coverage
make coverage-fork

make coverage-report
make coverage-report-fork
```

## 4. Deployment

### 4.1. Deploy NFT and Token Contract

Deploy the SettlementNft contract which deploys the SettlerTokens contract.

| Chain        | Command                    |
| ------------ | -------------------------- |
| Anvil        | `make deploy anvil`        |
| Holesky      | `make deploy holesky`      |
| Mainnet      | `make deploy mainnet`      |
| Base Sepolia | `make deploy base-sepolia` |
| Base Mainnet | `make deploy base-mainnet` |

### 4.2. Deploy View Aggregator Contract

Deploy the ViewAggregator contract.
Input value as a the Settlement contract deployment address e.g. `0x123...`.

| Chain        | Command                                  |
| ------------ | ---------------------------------------- |
| Anvil        | `make deployViewAggregator anvil`        |
| Holesky      | `make deployViewAggregator holesky`      |
| Mainnet      | `make deployViewAggregator mainnet`      |
| Base Sepolia | `make deployViewAggregator base-sepolia` |
| Base Mainnet | `make deployViewAggregator base-mainnet` |

## 5. Interactions

Interactions are defined in [./script/Interactions.s.sol](./script/Interactions.s.sol)

### 5.1. Mint Settlement NFT

Call the `mint()` function on the SettlementNft contract.

| Chain        | Command                     |
| ------------ | --------------------------- |
| Anvil        | `make mintNft anvil`        |
| Holesky      | `make mintNft holesky`      |
| Mainnet      | `make mintNft mainnet`      |
| Base Sepolia | `make mintNft base-sepolia` |
| Base Mainnet | `make mintNft base-mainnet` |

### 5.2. Get NFT Mint Timestamp

Call the `getMintTimestamp()` function on the SettlementNft contract.
Input value as a token ID e.g. `1`.

| Chain        | Command                              |
| ------------ | ------------------------------------ |
| Anvil        | `make getMintTimestamp anvil`        |
| Holesky      | `make getMintTimestamp holesky`      |
| Mainnet      | `make getMintTimestamp mainnet`      |
| Base Sepolia | `make getMintTimestamp base-sepolia` |
| Base Mainnet | `make getMintTimestamp base-mainnet` |

### 5.3. Get Settler Balance

Call the `getSettlerBalance()` function on the SettlementNft contract.
Input value as an address e.g. `0x123...`.

| Chain        | Command                               |
| ------------ | ------------------------------------- |
| Anvil        | `make getSettlerBalance anvil`        |
| Holesky      | `make getSettlerBalance holesky`      |
| Mainnet      | `make getSettlerBalance mainnet`      |
| Base Sepolia | `make getSettlerBalance base-sepolia` |
| Base Mainnet | `make getSettlerBalance base-mainnet` |

### 5.4. Get Sequential Data

Call the `getSequentialData()` function on the ViewAggregator contract.
Input value 1 as the starting token ID e.g. `1`.
Input value 2 as the ending token ID e.g. `10`.

| Chain        | Command                               |
| ------------ | ------------------------------------- |
| Anvil        | `make getSequentialData anvil`        |
| Holesky      | `make getSequentialData holesky`      |
| Mainnet      | `make getSequentialData mainnet`      |
| Base Sepolia | `make getSequentialData base-sepolia` |
| Base Mainnet | `make getSequentialData base-mainnet` |

### 5.5. Get Random Data

Call the `getRandomData()` function on the ViewAggregator contract.
Input value as a number of NFTs to return e.g. `20`.

| Chain        | Command                           |
| ------------ | --------------------------------- |
| Anvil        | `make getRandomData anvil`        |
| Holesky      | `make getRandomData holesky`      |
| Mainnet      | `make getRandomData mainnet`      |
| Base Sepolia | `make getRandomData base-sepolia` |
| Base Mainnet | `make getRandomData base-mainnet` |

## 6. License

[MIT](https://choosealicense.com/licenses/mit/)
