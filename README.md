# SETTLER - Ethereum Settlers

- [1. Overview](#1-overview)
- [2. Clone repository](#2-clone-repository)
  - [2.1. Install Dependencies](#21-install-dependencies)
  - [2.2. Create the `.env` file](#22-create-the-env-file)
- [3. Testing](#3-testing)
  - [3.1. Tests (Fork)](#31-tests-fork)
  - [3.2. Coverage (Fork)](#32-coverage-fork)
- [4. Deployment](#4-deployment)
- [5. License](#5-license)

## 1. Overview

An ERC20 token called `Ethereum Settler` (SETTLER) and an ERC721 NFT token called `Ethereum Settlement` (SETTLEMENT).

Minting a Settlement NFT is free and can be done by anyone. The only cost is the gas fee for the transaction.

Holding a Settlement NFT earns the holder a newly minted SETTLER tokens every second.

A Settlement NFT can only be held by one address at a time, but there is nothing stopping multiple addresses from each holding a different Settlement NFT. This means that the SETTLER token can have no monetary value, as it is not a scarce resource and an unlimited amount can be created simply by minting more Settlement NFTs. However, the SETTLER token could have utility in future when used in conjunction with a Settlement NFT. E.g. A future NFT mint could require a certain amount of SETTLER tokens and a Settlement NFT that is over a certain age.

## 2. Clone repository

```bash
git clone https://github.com/EridianAlpha/ethereum-settler.git
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

Deploys SimpleSwap and all modules to the Anvil chain specified in the `.env` file.

| Chain        | Command                    |
| ------------ | -------------------------- |
| Anvil        | `make deploy anvil`        |
| Holesky      | `make deploy holesky`      |
| Base Sepolia | `make deploy base-sepolia` |
| Base Mainnet | `make deploy base-mainnet` |

## 5. License

[MIT](https://choosealicense.com/licenses/mit/)
