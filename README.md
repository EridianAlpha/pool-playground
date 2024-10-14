# Pool Playground

- [1. Overview](#1-overview)
- [2. Installation](#2-installation)
- [3. Clone repository](#3-clone-repository)
  - [3.1. Install Dependencies](#31-install-dependencies)
  - [3.2. Create the `.env` file](#32-create-the-env-file)
- [4. Testing](#4-testing)
  - [4.1. Tests](#41-tests)
  - [4.2. Coverage](#42-coverage)
- [5. Deployment](#5-deployment)
  - [5.1. Deploying Uniswap V2 Contracts (optional)](#51-deploying-uniswap-v2-contracts-optional)
  - [5.2. Deploying PoolPlayground Contract](#52-deploying-poolplayground-contract)
- [6. Interactions](#6-interactions)
  - [6.1. Deploy Playground Instance](#61-deploy-playground-instance)
- [7. License](#7-license)

## 1. Overview

An interactive educational playground for visualizing and learning Uniswap V2 mechanics by swapping testnet ERC20 tokens.

Live on [https://pool.eridian.xyz](https://pool.eridian.xyz)

## 2. Installation

## 3. Clone repository

```bash
git clone https://github.com/EridianAlpha/pool-playground.git
```

### 3.1. Install Dependencies

This should happen automatically when first running a command, but the installation can be manually triggered with the following commands:

```bash
git submodule init
git submodule update
make install
```

### 3.2. Create the `.env` file

Use the `.env.example` file as a template to create a `.env` file.

## 4. Testing

### 4.1. Tests

```bash
make test
make test-fork

make test-v
make test-v-fork

make test-summary
make test-summary-fork
```

### 4.2. Coverage

```bash
make coverage
make coverage-fork

make coverage-report
make coverage-report-fork
```

## 5. Deployment

### 5.1. Deploying Uniswap V2 Contracts (optional)

This step is optional and only necessary if you need to deploy the Uniswap V2 core contracts to a new chain. The Uniswap V2 core contracts have already been deployed on Mainnet (used for forks only), Holesky, Sepolia, Base Sepolia, Arbitrum Sepolia, and Optimism Sepolia chains. The addresses of these existing deployments can be found in the `.env.example` file.

Fork the Uniswap v2-periphery repository and modify the `v2-periphery/contracts/libraries/UniswapV2Library.sol` contract with the correct init code hash on line 24. Without changing this init code hash, the contract will not be able to calculate the correct pair address. There are a number of reasons why the init code hash changes, but the most likely reason is that the contract was deployed with a different compiler version or with different compiler settings.

You can try to configure your complier to match the settings of the original deployment, but this is not always possible. The best way to get the correct init code hash is to inspect the creation bytecode of the contract that you are using and manually change the init code hash.

```bash
# Get the creation bytecode of the UniswapV2Pair contract
CREATION_BYTECODE=$(forge inspect lib/v2-core/contracts/UniswapV2Pair.sol:UniswapV2Pair bytecode)

# Calculate the init code hash of the UniswapV2Pair contract
cast keccak "$CREATION_BYTECODE"
0x0be7e5aaf721ce53efd2148867ffca974ca93687937cd12b66ab2acef87168ed

# Remove the 0x from the start and use that as the "init code hash"
# in `v2-periphery/contracts/libraries/UniswapV2Library.sol` line 24
0be7e5aaf721ce53efd2148867ffca974ca93687937cd12b66ab2acef87168ed

```

Once you have the correct init code hash updated in your own fork of the Uniswap v2-periphery repository, you can install it to your local environment.

```bash
# Example of installing the EridianAlpha/v2-periphery repository with the modified init code hash
forge install EridianAlpha/v2-periphery --no-commit
```

After installing the modified Uniswap v2-periphery repository, you can deploy the Uniswap V2 Factory and Router02 contracts to the specified chain.

| Chain            | Command                                  |
| ---------------- | ---------------------------------------- |
| Anvil            | `make deploy-uniswapV2-anvil`            |
| Holesky          | `make deploy-uniswapV2-ethereum-holesky` |
| Sepolia          | `make deploy-uniswapV2-ethereum-sepolia` |
| Base Sepolia     | `make deploy-uniswapV2-base-sepolia`     |
| Arbitrum Sepolia | `make deploy-uniswapV2-arbitrum-sepolia` |
| Optimism Sepolia | `make deploy-uniswapV2-optimism-sepolia` |

### 5.2. Deploying PoolPlayground Contract

Deploys PoolPlayground to the specified chain.

| Chain            | Command                        |
| ---------------- | ------------------------------ |
| Anvil            | `make deploy anvil`            |
| Holesky          | `make deploy ethereum-holesky` |
| Sepolia          | `make deploy ethereum-sepolia` |
| Base Sepolia     | `make deploy base-sepolia`     |
| Arbitrum Sepolia | `make deploy arbitrum-sepolia` |
| Optimism Sepolia | `make deploy optimism-sepolia` |

## 6. Interactions

Interactions are defined in `./script/Interactions.s.sol`

If `DEPLOYED_CONTRACT_ADDRESS` is set in the `.env` file, that contract address will be used for interactions.
If that variable is not set, the latest deployment on the specified chain will be used.

### 6.1. Deploy Playground Instance

Call the `deploy()` function on the PoolPlayground contract.
The input parameters are defined in the `Interactions.s.sol` script.

| Chain            | Command                                          |
| ---------------- | ------------------------------------------------ |
| Anvil            | `make deployPlaygroundInstance anvil`            |
| Holesky          | `make deployPlaygroundInstance ethereum-holesky` |
| Sepolia          | `make deployPlaygroundInstance ethereum-sepolia` |
| Base Sepolia     | `make deployPlaygroundInstance base-sepolia`     |
| Arbitrum Sepolia | `make deployPlaygroundInstance arbitrum-sepolia` |
| Optimism Sepolia | `make deployPlaygroundInstance optimism-sepolia` |

## 7. License

[MIT](https://choosealicense.com/licenses/mit/)
