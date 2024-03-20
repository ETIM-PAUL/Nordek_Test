// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Crowdsale is ERC20 {
    address owner;
    uint8 startDate;
    uint8 endDate;
    uint8 cliffDuration;
    uint8 pricePerToken;
    uint immutable totalSupplyLimit;
    bool paused;

    mapping (address => receipt) public crowdsale_participants

    error OnlyOwner();
    error InvalidAddress();
    error ZeroAmount();
    error CrowdsaleHalted();
    error CrowdsaleNotStarted();
    error CrowdsaleEnded();
    error TotalSupplyWillBeExceeded();

    event TokensReleased();

    constructor(tokenName, tokenSymbol, _totalSupplyLimit, _pricePerToken, _startDate, _cliffDuration, _endDate) ERC20(tokenName, tokenSymbol) {
        owner = msg.sender;
        totalSupplyLimit = _totalSupplyLimit;
        pricePerToken = _pricePerToken;
        startDate = _startDate;
        endDate = _endDate;
        cliffDuration=_cliffDuration;
    }

    uint ExpectedAmount = 10_000 ether;
    uint precision = 1e32;

    function decimals() public view override returns (uint8) {
        return 8;
    }

    function buyTokens() external payable {
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

        //here, we give a receipt to the buyer
        crowdsale_participants[msg.sender] = receipt + amount;
    }

    function release() external {
        if(paused){
            revert CrowdsaleHalted();
        }
        uint receipt = crowdsale_participants[msg.sender]
        uint256 vested = vestedAmount(receipt);
        require(vested > receipt, "No tokens available for release");

        uint256 amount = vested - receipt;
        released = receipt + amount;

        //here, we release the token
        _mint(msg.sender, amount);

        emit TokensReleased(amount);
    }

    function vestedAmount(uint _receipt) internal view returns (uint256) {
        if (block.timestamp < cliffDuration) {
            return 0;
        } else if (block.timestamp >= (startDate + endDate)) {
            return _receipt;
        } else {
            return _receipt * (block.timestamp - (startDate)) / (endDate);
        }
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
        if(payee == address(0)){
            revert InvalidAddress();
        }
        // this checks to make sure only contract owner can withdraw;
        if(msg.sender != owner){
            revert OnlyOwner();
        }

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
