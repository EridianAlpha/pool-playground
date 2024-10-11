# ================================================================
# │                 GENERIC MAKEFILE CONFIGURATION               │
# ================================================================
-include .env

.PHONY: test

help:
	@echo "Usage:"
	@echo "  make deploy anvil\n

# ================================================================
# │                      NETWORK CONFIGURATION                   │
# ================================================================
get-network-args: $(word 2, $(MAKECMDGOALS))-network

# Network Arguments
ANVIL_NETWORK_ARGS = --rpc-url $(ANVIL_RPC_URL) --private-key $(ANVIL_PRIVATE_KEY)
ETHEREUM_HOLESKY_NETWORK_ARGS = --rpc-url $(ETHEREUM_HOLESKY_RPC_URL) --private-key $(ETHEREUM_HOLESKY_PRIVATE_KEY)
ETHEREUM_SEPOLIA_NETWORK_ARGS = --rpc-url $(ETHEREUM_SEPOLIA_RPC_URL) --private-key $(ETHEREUM_SEPOLIA_PRIVATE_KEY)
BASE_SEPOLIA_NETWORK_ARGS = --rpc-url $(BASE_SEPOLIA_RPC_URL) --private-key $(BASE_SEPOLIA_PRIVATE_KEY)
ARBITRUM_SEPOLIA_NETWORK_ARGS = --rpc-url $(ARBITRUM_SEPOLIA_RPC_URL) --private-key $(ARBITRUM_SEPOLIA_PRIVATE_KEY)
OPTIMISM_SEPOLIA_NETWORK_ARGS = --rpc-url $(OPTIMISM_SEPOLIA_RPC_URL) --private-key $(OPTIMISM_SEPOLIA_PRIVATE_KEY)

anvil: # Added to stop error output when running commands e.g. make deploy anvil
	@echo
anvil-network:
	$(eval \
		NETWORK_ARGS := --broadcast \
						${ANVIL_NETWORK_ARGS} \
	)

ethereum-holesky: # Added to stop error output when running commands e.g. make deploy ethereum-holesky
	@echo
ethereum-holesky-network:
	$(eval \
		NETWORK_ARGS := --broadcast \
						${ETHEREUM_HOLESKY_NETWORK_ARGS} \
						--verify \
						--etherscan-api-key ${ETHERSCAN_API_KEY} \
	)

ethereum-sepolia: # Added to stop error output when running commands e.g. make deploy ethereum-sepolia
	@echo
ethereum-sepolia-network:
	$(eval \
		NETWORK_ARGS := --broadcast \
						${ETHEREUM_SEPOLIA_NETWORK_ARGS} \
						--verify \
						--etherscan-api-key ${ETHERSCAN_API_KEY} \
	)

base-sepolia: # Added to stop error output when running commands e.g. make deploy base-sepolia
	@echo
base-sepolia-network: 
	$(eval \
		NETWORK_ARGS := --broadcast \
						${BASE_SEPOLIA_NETWORK_ARGS} \
						--verify \
						--etherscan-api-key ${BASESCAN_API_KEY} \
	)

arbitrum-sepolia: # Added to stop error output when running commands e.g. make deploy arbitrum-sepolia
	@echo
arbitrum-sepolia-network: 
	$(eval \
		NETWORK_ARGS := --broadcast \
						${ARBITRUM_SEPOLIA_NETWORK_ARGS} \
						--verify \
						--etherscan-api-key ${ARBISCAN_API_KEY} \
	)

optimism-sepolia: # Added to stop error output when running commands e.g. make deploy optimism-sepolia
	@echo
optimism-sepolia-network: 
	$(eval \
		NETWORK_ARGS := --broadcast \
						${OPTIMISM_SEPOLIA_NETWORK_ARGS} \
						--verify \
						--etherscan-api-key ${OPSCAN_API_KEY} \
	)

# ================================================================
# │                    LOCAL TESTING AND COVERAGE                │
# ================================================================
test:; forge test
test-v:; forge test -vvvv
test-summary:; forge test --summary

coverage:
	@forge coverage --report summary --report lcov 
	@echo

coverage-report:
	@forge coverage --report debug > coverage-report.txt
	@echo Output saved to coverage-report.txt

# ================================================================
# │                     FORK TESTING AND COVERAGE                │
# ================================================================
test-fork:; forge test --fork-url ${FORK_RPC_URL}
test-v-fork:; forge test --fork-url ${FORK_RPC_URL} -vvvv
test-summary-fork:; forge test --fork-url ${FORK_RPC_URL} --summary

coverage-fork:
	@forge coverage --fork-url ${FORK_RPC_URL} --report summary --report lcov 
	@echo

coverage-report-fork:
	@forge coverage --fork-url ${FORK_RPC_URL} --report debug > coverage-report-fork.txt
	@echo Output saved to coverage-report-fork.txt

# ================================================================
# │                   USER INPUT - ASK FOR VALUE                 │
# ================================================================
ask-for-value:
	@echo "Enter value: "
	@read value; \
	echo $$value > MAKE_CLI_INPUT_VALUE.tmp;

# If multiple values are passed (comma separated), convert the first value to wei
convert-value-to-wei:
	@value=$$(cat MAKE_CLI_INPUT_VALUE.tmp); \
	first_value=$$(echo $$value | cut -d',' -f1); \
	remaining_inputs=$$(echo $$value | cut -d',' -f2-); \
	if [ "$$first_value" = "$$value" ]; then \
		remaining_inputs=""; \
	fi; \
 	wei_value=$$(echo "$$first_value * 10^18 / 1" | bc); \
	if [ -n "$$remaining_inputs" ]; then \
		final_value=$$wei_value,$$remaining_inputs; \
	else \
		final_value=$$wei_value; \
	fi; \
 	echo $$final_value > MAKE_CLI_INPUT_VALUE.tmp;

# If multiple values are passed (comma separated), convert the first value to USDC
convert-value-to-USDC:
	@value=$$(cat MAKE_CLI_INPUT_VALUE.tmp); \
	first_value=$$(echo $$value | cut -d',' -f1); \
	remaining_inputs=$$(echo $$value | cut -d',' -f2-); \
	if [ "$$first_value" = "$$value" ]; then \
		remaining_inputs=""; \
	fi; \
 	usdc_value=$$(echo "$$first_value * 10^6 / 1" | bc); \
	if [ -n "$$remaining_inputs" ]; then \
		final_value=$$usdc_value,$$remaining_inputs; \
	else \
		final_value=$$usdc_value; \
	fi; \
 	echo $$final_value > MAKE_CLI_INPUT_VALUE.tmp;

store-value:
	$(eval \
		MAKE_CLI_INPUT_VALUE := $(shell cat MAKE_CLI_INPUT_VALUE.tmp) \
	)

remove-value:
	@rm -f MAKE_CLI_INPUT_VALUE.tmp

# ================================================================
# │                CONTRACT SPECIFIC CONFIGURATION               │
# ================================================================
install:
	forge install foundry-rs/forge-std@v1.9.2 --no-commit && \
	forge install Cyfrin/foundry-devops@0.2.3 --no-commit && \
	forge install openzeppelin/openzeppelin-contracts@v5.0.2 --no-commit && \
	forge install uniswap/v2-core --no-commit && \
	forge install EridianAlpha/v2-periphery --no-commit && \
	forge install uniswap/swap-router-contracts --no-commit && \
	forge install uniswap/uniswap-lib --no-commit

# ================================================================
# │                         RUN COMMANDS                         │
# ================================================================
interactions-script = @forge script script/Interactions.s.sol:Interactions ${NETWORK_ARGS} -vvvv

# ================================================================
# │            RUN COMMANDS - POOL PLAYGROUND DEPLOYMENT         │
# ================================================================
deploy-script:; @forge script script/Deploy.s.sol:Deploy --sig "run()" ${NETWORK_ARGS} -vvvv
deploy: get-network-args \
	deploy-script

# ================================================================
# │                RUN COMMANDS - UNISWAPV2 DEPLOYMENT           │
# ================================================================

deploy-uniswapV2-script:
	@echo "Deploying UniswapV2Factory..."; \
	DEPLOYED_UNISWAPV2_FACTORY_ADDR=$$(forge create lib/v2-core/contracts/UniswapV2Factory.sol:UniswapV2Factory --constructor-args 0x0000000000000000000000000000000000000000 $(NETWORK_ARGS) --json | jq -r '.deployedTo'); \
	echo "Deployed UniswapV2Factory at: $$DEPLOYED_UNISWAPV2_FACTORY_ADDR"; \
	\
	echo ""; \
	echo "Deploying UniswapV2Router02..."; \
	DEPLOYED_UNISWAPV2_ROUTER02_ADDR=$$(forge create lib/v2-periphery/contracts/UniswapV2Router02.sol:UniswapV2Router02 --constructor-args $$DEPLOYED_UNISWAPV2_FACTORY_ADDR 0x0000000000000000000000000000000000000000 $(NETWORK_ARGS) --json | jq -r '.deployedTo'); \
	echo "Deployed UniswapV2Router02 at: $$DEPLOYED_UNISWAPV2_ROUTER02_ADDR"; \
	\
	if [ ! -z "$(VERIFY_ARGS)" ]; then \
		echo ""; \
		echo "Verifying UniswapV2Factory..."; \
		forge verify-contract $$DEPLOYED_UNISWAPV2_FACTORY_ADDR lib/v2-core/contracts/UniswapV2Factory.sol:UniswapV2Factory --constructor-args 0x0000000000000000000000000000000000000000000000000000000000000000 --compiler-version 0.5.16 --watch --flatten $(VERIFY_ARGS); \
		\
		echo ""; \
		echo "Verifying UniswapV2Router02..."; \
		ENCODED_CONSTRUCTOR_ARGS=$$(cast abi-encode "constructor(address,address)" $$DEPLOYED_UNISWAPV2_FACTORY_ADDR 0x0000000000000000000000000000000000000000); \
		forge verify-contract $$DEPLOYED_UNISWAPV2_ROUTER02_ADDR lib/v2-periphery/contracts/UniswapV2Router02.sol:UniswapV2Router02 --constructor-args $$ENCODED_CONSTRUCTOR_ARGS --compiler-version 0.6.6 --watch --flatten $(VERIFY_ARGS); \
	fi

deploy-uniswapV2-anvil:; @$(MAKE) deploy-uniswapV2-script NETWORK_ARGS="$(ANVIL_NETWORK_ARGS)"
deploy-uniswapV2-ethereum-holesky:; @$(MAKE) deploy-uniswapV2-script NETWORK_ARGS="$(ETHEREUM_HOLESKY_NETWORK_ARGS)" VERIFY_ARGS="--chain-id 17000 --etherscan-api-key ${ETHERSCAN_API_KEY}"
deploy-uniswapV2-ethereum-sepolia:; @$(MAKE) deploy-uniswapV2-script NETWORK_ARGS="$(ETHEREUM_SEPOLIA_NETWORK_ARGS)" VERIFY_ARGS="--chain-id 11155111 --etherscan-api-key ${ETHERSCAN_API_KEY}"
deploy-uniswapV2-base-sepolia:; @$(MAKE) deploy-uniswapV2-script NETWORK_ARGS="$(BASE_SEPOLIA_NETWORK_ARGS)" VERIFY_ARGS="--chain-id 84532 --etherscan-api-key ${BASESCAN_API_KEY}"
deploy-uniswapV2-arbitrum-sepolia:; @$(MAKE) deploy-uniswapV2-script NETWORK_ARGS="$(ARBITRUM_SEPOLIA_NETWORK_ARGS)" VERIFY_ARGS="--chain-id 421614 --etherscan-api-key ${ARBISCAN_API_KEY}"
deploy-uniswapV2-optimism-sepolia:; @$(MAKE) deploy-uniswapV2-script NETWORK_ARGS="$(OPTIMISM_SEPOLIA_NETWORK_ARGS)" VERIFY_ARGS="--chain-id 11155420 --etherscan-api-key ${OPSCAN_API_KEY}"

# ================================================================
# │            RUN COMMANDS - DEPLOY PLAYGROUND INSTANCE         │
# ================================================================
deployPlaygroundInstance-script:; $(interactions-script) --sig "deployPlaygroundInstance()"
deployPlaygroundInstance: get-network-args \
	deployPlaygroundInstance-script
