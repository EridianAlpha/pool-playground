# Pool Playground

- [1. Overview](#1-overview)
- [2. Clone repository](#2-clone-repository)
  - [2.1. Install Dependencies](#21-install-dependencies)
  - [2.2. Create the `.env` file](#22-create-the-env-file)
- [3. Testing](#3-testing)
  - [3.1. Tests](#31-tests)
  - [3.2. Coverage](#32-coverage)
- [4. Deployment](#4-deployment)
- [5. Interactions](#5-interactions)
- [6. License](#6-license)

## 1. Overview

An interactive educational playground for visualizing and learning Uniswap V2 mechanics by swapping testnet ERC20 tokens.

Live on [https://pool.eridian.xyz](https://pool.eridian.xyz)

## 2. Installation

## 2.1. Clone repository

```bash
git clone https://github.com/EridianAlpha/pool-playground.git
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

Fork the Uniswap v2-periphery repository and modify the UniswapV2Library.sol contract with the correct init code hash.

```bash

CREATION_BYTECODE=$(forge inspect UniswapV2Pair bytecode)
cast keccak "$CREATION_BYTECODE"

# Remove the 0x from the start and use that as the "init code hash" in UniswapV2Library.sol
0be7e5aaf721ce53efd2148867ffca974ca93687937cd12b66ab2acef87168ed

```

Deploys PoolPlayground to the specified chain.

| Chain            | Command                        |
| ---------------- | ------------------------------ |
| Anvil            | `make deploy anvil`            |
| Holesky          | `make deploy ethereum-holesky` |
| Sepolia          | `make deploy ethereum-sepolia` |
| Base Sepolia     | `make deploy base-sepolia`     |
| Arbitrum Sepolia | `make deploy arbitrum-sepolia` |
| Optimism Sepolia | `make deploy optimism-sepolia` |

## 5. Interactions

Interactions are defined in `./script/Interactions.s.sol`

If `DEPLOYED_CONTRACT_ADDRESS` is set in the `.env` file, that contract address will be used for interactions.
If that variable is not set, the latest deployment on the specified chain will be used.

## 6. License

[MIT](https://choosealicense.com/licenses/mit/)
