## CSD ERC20 Tokens

_ERC20 Token for implementing crowdsale._

```solidity
The contract is implemented using openxeppelin ERC20 contract template
```

### mint function with checks

```solidity
the mint function mints token to an address. It has checks for only owner, address zero, zero minting tokens, total supply check.
```

## CrowdsaleFactory Contract

_A Factory contract that allows any account to create a crowdsale with its own state and functions_

### createCrowdsale function with checks

```solidity
the create crowdsale function allows creation of a single crowdsale contract entity with checks for zero price per token, invalid start and end date, invalid cliff date abd invalid vesting period date
```

## Crowdsale Contract

_A crowdsale contract that allows purchase of erc20 tokens and give a receipt for each purchase. This receipt can then be used for redemption of the tokens only during a vesting period or after a vesting period/

### buyTokens function with checks

```solidity
the buyTokens function takes in an address and an amount of ethers, it then has checks for zero amount, insufficient payment based on the token price, zero address check, contract halt state, crowdsale kickoff, crowdsale end time.

The contract calculates the amount of tokens you will get based on the price of the token, and then gives u a receipt based on that amount.
```

### getTokensRelease function with checks

```solidity
the getTokensRelease function takes an address and then have checks for invalid address, if crowdsale hasn't been paused, tokens released as well as in case of tokens have all been released for the passed address. 

The amount to be released is calculated based on the difference in receipt purchased time and the vesting period.
```

### pauseContract function with checks

```solidity
the pausedContract function allows only the contract owner to pause the contract, incase of exploit or any issue.
```

### unPauseContract function with checks

```solidity
the unPausedContract function allows only the contract owner to un-pause the contract after pause.
```

### withdrawEther function with checks

```solidity
the withdrawEther function pays the passed address the balance of the contract in ethers. It has checks for only owner and zero address.
```

### expectedTokens function

```solidity
the expectedTokens function allows accounts to see a preview of how much they will get based on the amount of ethers there are willing to pay.
```

### To deploy and verify for CSD ERC20 contract

###### Run this command "forge init"
##### Run this command 
forge create --rpc-url urdesiredchainRPC \
    --constructor-args tokenName tokenSymbol totalSupplyLimit \
    --private-key yourPrivateKey \
    --etherscan-api-key yourEtherscanKey \
    --verify \
    src/CSD.sol:CSD
    
    to run deploy and verify CSD ERC20 contract


### To deploy and verify for CrowdsaleFactory contract

###### Run this command "forge init"
##### Run this command
forge create --rpc-url urdesiredchainRPC \
    --constructor-args erc20Address pricePerToken startDate cliffDuration vestingPeriod endDate \
    --private-key yourPrivateKey \
    --etherscan-api-key yourEtherscanKey \
    --verify \
    src/CrowdsaleFactory.sol:CrowdsaleFactory
    
    to run deploy and verify CrowdsaleFactory contract


### To run the test for CSD ERC20 contract

###### Run this command "forge init"
##### Run this command next "forge test -vvvvv --match-contract CSDTest" to run test for CSD ERC20 contract

### To run the test for CrowdsaleFactory contract

###### Run this command "forge init"
##### Run this command next "forge test -vvvvv --match-contract CrowdsaleFactoryTest" to run test for CrowdsaleFactory contract

### To run the test for Crowdsale contract

###### Run this command "forge init"
##### Run this command next "forge test -vvvvv --match-contract CrowdsaleTest" to run test for Crowdsale contract

#### All the contracts have written tests in foundry to test possible contract functions, as well as possible issues. Although to deploy the contract on mainnet, all contracts need to pass through different stages of audits