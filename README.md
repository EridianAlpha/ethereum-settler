# Ethereum Settlers

- [1. Overview](#1-overview)
- [2. Clone repository](#2-clone-repository)
  - [2.1. Install Dependencies](#21-install-dependencies)
  - [2.2. Create the `.env` file](#22-create-the-env-file)
- [3. Testing](#3-testing)
  - [3.1. Tests (Fork)](#31-tests-fork)
  - [3.2. Coverage (Fork)](#32-coverage-fork)
- [4. Deployment](#4-deployment)
- [5. Interactions](#5-interactions)
  - [5.1. Mint Settlement NFT](#51-mint-settlement-nft)
  - [5.2. Get NFT Mint Timestamp](#52-get-nft-mint-timestamp)
  - [5.3. Mint Settlement NFT](#53-mint-settlement-nft)
- [6. License](#6-license)

## 1. Overview

An ERC20 token called `Ethereum Settler` (SETTLER) and an ERC721 NFT token called `Ethereum Settlement` (SETTLEMENT).

Minting a Settlement NFT is free and can be done by anyone. The only cost is the gas fee for the transaction.

Holding a Settlement NFT earns the holder a newly minted SETTLER tokens every second.

A Settlement NFT can only be held by one address at a time, but there is nothing stopping multiple addresses from each holding a different Settlement NFT. This means that the SETTLER token can have no monetary value, as it is not a scarce resource and an unlimited amount can be created simply by minting more Settlement NFTs. However, the SETTLER token could have utility in future when used in conjunction with a Settlement NFT. E.g. A future NFT mint could require a certain amount of SETTLER tokens and a Settlement NFT that is over a certain age.

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

### 3.1. Tests (Fork)

```bash
make test
make test-v
make test-summary
```

### 3.2. Coverage (Fork)

```bash
make coverage
make coverage-report
```

## 4. Deployment

Deploy the SettlementNft contract which deploys the SettlerTokens contract.

| Chain        | Command                    |
| ------------ | -------------------------- |
| Anvil        | `make deploy anvil`        |
| Holesky      | `make deploy holesky`      |
| Mainnet      | `make deploy mainnet`      |
| Base Sepolia | `make deploy base-sepolia` |
| Base Mainnet | `make deploy base-mainnet` |

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

### 5.3. Mint Settlement NFT

Call the `getSettlerBalance()` function on the SettlementNft contract.
Input value as an address e.g. `0x123...`.

| Chain        | Command                               |
| ------------ | ------------------------------------- |
| Anvil        | `make getSettlerBalance anvil`        |
| Holesky      | `make getSettlerBalance holesky`      |
| Mainnet      | `make getSettlerBalance mainnet`      |
| Base Sepolia | `make getSettlerBalance base-sepolia` |
| Base Mainnet | `make getSettlerBalance base-mainnet` |

## 6. License

[MIT](https://choosealicense.com/licenses/mit/)
