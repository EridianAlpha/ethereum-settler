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

anvil: # Added to stop error output when running commands e.g. make deploy anvil
	@echo
anvil-network:
	$(eval \
		NETWORK_ARGS := --broadcast \
						--rpc-url ${ANVIL_RPC_URL} \
						--private-key ${ANVIL_PRIVATE_KEY} \
	)

holesky: # Added to stop error output when running commands e.g. make deploy holesky
	@echo
holesky-network:
	$(eval \
		NETWORK_ARGS := --broadcast \
						--rpc-url ${HOLESKY_RPC_URL} \
						--private-key ${HOLESKY_PRIVATE_KEY} \
						--verify \
						--etherscan-api-key ${ETHERSCAN_API_KEY} \
	)

mainnet: # Added to stop error output when running commands e.g. make deploy mainnet
	@echo
mainnet-network:
	$(eval \
		NETWORK_ARGS := --broadcast \
						--rpc-url ${MAINNET_RPC_URL} \
						--private-key ${MAINNET_PRIVATE_KEY} \
						--verify \
						--etherscan-api-key ${ETHERSCAN_API_KEY} \
	)

base-sepolia: # Added to stop error output when running commands e.g. make deploy base-sepolia
	@echo
base-sepolia-network: 
	$(eval \
		NETWORK_ARGS := --broadcast \
						--rpc-url ${BASE_SEPOLIA_RPC_URL} \
						--private-key ${BASE_SEPOLIA_PRIVATE_KEY} \
						--verify \
						--etherscan-api-key ${BASESCAN_API_KEY} \
	)

base-mainnet: # Added to stop error output when running commands e.g. make deploy base-mainnet
	@echo
base-mainnet-network: 
	$(eval \
		NETWORK_ARGS := --broadcast \
						--rpc-url ${BASE_MAINNET_RPC_URL} \
						--private-key ${BASE_MAINNET_PRIVATE_KEY} \
						--verify \
						--etherscan-api-key ${BASESCAN_API_KEY} \
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
	forge install Cyfrin/foundry-devops@0.2.2 --no-commit && \
	forge install openzeppelin/openzeppelin-contracts@v5.0.2 --no-commit

# ================================================================
# │                         RUN COMMANDS                         │
# ================================================================
interactions-script = @forge script script/Interactions.s.sol:Interactions ${NETWORK_ARGS} -vvvv
interactionsViewAggregator-script = @forge script script/InteractionsViewAggregator.s.sol:InteractionsViewAggregator ${NETWORK_ARGS} -vvvv

# ================================================================
# │                    RUN COMMANDS - DEPLOYMENT                 │
# ================================================================
deploy-script:; @forge script script/Deploy.s.sol:Deploy --sig "run()" ${NETWORK_ARGS} -vvvv
deploy: get-network-args \
	deploy-script

deployViewAggregator-script:; @forge script script/DeployViewAggregator.s.sol:DeployViewAggregator --sig "run(address)" ${MAKE_CLI_INPUT_VALUE} ${NETWORK_ARGS} -vvvv
deployViewAggregator: get-network-args \
	ask-for-value \
	store-value \
	deployViewAggregator-script \
	remove-value

# ================================================================
# │                    RUN COMMANDS - MINT NFT                   │
# ================================================================
mintNft-script:; $(interactions-script) --sig "mintNft()"
mintNft: get-network-args \
	mintNft-script

# ================================================================
# │                     RUN COMMANDS - GETTERS                   │
# ================================================================
getMintTimestamp-script:; $(interactions-script) --sig "getMintTimestamp(uint256)" ${MAKE_CLI_INPUT_VALUE}
getMintTimestamp: get-network-args \
	ask-for-value \
	store-value \
	getMintTimestamp-script \
	remove-value

getSettlerBalance-script:; $(interactions-script) --sig "getSettlerBalance(address)" ${MAKE_CLI_INPUT_VALUE}
getSettlerBalance: get-network-args \
	ask-for-value \
	store-value \
	getSettlerBalance-script \
	remove-value

# ================================================================
# │                 RUN COMMANDS - VIEW AGGREGATOR               │
# ================================================================
getSequentialData-script:; $(interactionsViewAggregator-script) --sig "getSequentialData(uint256, uint256)" $(shell echo $(MAKE_CLI_INPUT_VALUE) | tr ',' ' ')
getSequentialData: get-network-args \
	ask-for-value \
	store-value \
	getSequentialData-script \
	remove-value

getRandomData-script:; $(interactionsViewAggregator-script) --sig "getRandomData(uint256)" ${MAKE_CLI_INPUT_VALUE}
getRandomData: get-network-args \
	ask-for-value \
	store-value \
	getRandomData-script \
	remove-value