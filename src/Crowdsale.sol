// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Crowdsale is ERC20 {
    address owner;
    uint8 startDate;
    uint8 endDate;
    uint8 pricePerToken;
    uint immutable totalSupplyLimit;
    bool paused;

    error OnlyOwner();
    error InvalidAddress();
    error ZeroAmount();
    error CrowdsaleHalted();
    error CrowdsaleNotStarted();
    error CrowdsaleEnded();
    error TotalSupplyWillBeExceeded();

    constructor(tokenName, tokenSymbol, _totalSupplyLimit, _pricePerToken, _startDate, _endDate) ERC20(tokenName, tokenSymbol) {
        owner = msg.sender;
        totalSupplyLimit = _totalSupplyLimit;
        pricePerToken = _pricePerToken;
        startDate = _startDate;
        endDate = _endDate;
    }

    uint ExpectedAmount = 10_000 ether;
    uint precision = 1e32;

    function decimals() public view override returns (uint8) {
        return 8;
    }

    function buyTokens() external payable returns () {
        if(msg.value == 0){
            revert ZeroAmount();
        }
        if(paused){
            revert CrowdsaleHalted();
        }
        if(block.timestamp < startDate){
            revert CrowdsaleNotStarted();
        }
        if(block.timestamp > endDate){
            revert CrowdsaleEnded();
        }

        //this calculates the amount you will get based on the ethers you are paying
        uint amount = msg.value / pricePerToken;

        if((totalSupply() + amount)  > TOTAL_SUPPLY_LIMIT){
            revert TotalSupplyWillBeExceeded();
        }

        //here, we mint the amount to the buyer
        _mint(msg.sender, amount);
    }

function pauseContract() external {
    if(msg.sender != owner){
            revert OnlyOwner();
        }
    paused = true;
}
function unPauseContract() external {
    if(msg.sender != owner){
            revert OnlyOwner();
        }
    paused = false;
}
    function returnBalance()
        external
        view
        returns (uint etherbalance, uint tokenBalance)
    {
        //This returns the amount of ethers our contract holds
        etherbalance = address(this).balance;

        //This returns the amount of tokens in our contract
        tokenBalance = balanceOf(address(this));
    }

    function withdrawEther(address payee) external {
        // this checks to make sure only contract owner can withdraw;
        require(payee != address(0), "Invalid Address");
        require(msg.sender == owner, "Only Owner");

        //this transfers the ethers to the account that calls the functions
        (bool success, ) = payable(payee).call{
            value: address(this).balance
        }("");
        require(success, "transferFailed");
    }

    function getSupply() view external {
        totalSupply();
    }
    function expectedTokens(uint _amountInEth) view external returns (uint _expectedTokens) {
        _expectedTokens = _amountInEth / pricePerToken
    }

    receive() external payable {
    // This function is executed when a contract receives plain Ether (without data)
}
}
