// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Crowdsale {
ERC20 public token;
    address owner;
    uint startDate;
    uint endDate;
    uint cliffDuration;
    uint vestingPeriod;
    uint pricePerToken;
    uint public totalReceipt;
    bool paused;

    struct TokensPurchaser {
        uint amount;
        uint purchasedTime;
    }

    mapping (address => TokensPurchaser) public crowdsale_participants;

    error OnlyOwner();
    error InvalidAddress();
    error ZeroAmount();
    error InsufficientPrice();
    error CrowdsaleHalted();
    error CrowdsaleNotStarted();
    error CrowdsaleEnded();
    error CliffPeriodNotOver();
    error NoTokenForReleased();
    error ExcessReleaseTokensRevert();

    event TokensPurchased(address,uint);
    event TokensReleased(address,uint);

    constructor(address _owner, address _token, uint _pricePerToken, uint _startDate, uint _cliffDuration, uint _vestingPeriod, uint _endDate) {
        owner = _owner;
        pricePerToken = _pricePerToken;
        startDate = _startDate;
        endDate = _endDate;
        cliffDuration=_cliffDuration;
        vestingPeriod=_vestingPeriod;
        token = ERC20(_token);
    }

    function buyTokens(address _purchaser) external payable {
        if(msg.value == 0){
            revert ZeroAmount();
        }
        if(msg.value < pricePerToken){
            revert InsufficientPrice();
        }
        if(_purchaser == address(0)){
            revert InvalidAddress();
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


        //here, we give a receipt to the buyer
        TokensPurchaser storage purchaser = crowdsale_participants[_purchaser];
        purchaser.amount = purchaser.amount + amount;

        // Set purchase time if it hasn't been set yet
        if (purchaser.purchasedTime == 0) {
            purchaser.purchasedTime = block.timestamp;
        }
        totalReceipt+amount;
        emit TokensPurchased(_purchaser,amount);
    }

    function getTokensRelease(address _purchaser) external {
        if(paused){
            revert CrowdsaleHalted();
        }
        if(_purchaser == address(0)){
            revert InvalidAddress();
        }
        TokensPurchaser storage purchaser = crowdsale_participants[_purchaser];
        uint256 tokensReleased = vestedAmount(purchaser.amount, purchaser.purchasedTime);
        if(block.timestamp < cliffDuration){revert CliffPeriodNotOver();}
        if(tokensReleased <= 0){revert NoTokenForReleased();}
        if(purchaser.amount <= 0){revert ExcessReleaseTokensRevert();}

        crowdsale_participants[_purchaser].amount = purchaser.amount - tokensReleased;

        token.transfer(_purchaser, tokensReleased*1e18);
        emit TokensReleased(_purchaser, tokensReleased * 1e18);
    }

    function vestedAmount(uint amount, uint purchasedTime) internal view returns (uint256) {
         uint256 timeSinceStart = block.timestamp - purchasedTime;
        uint256 vestedTokens = 0;

        if (timeSinceStart < vestingPeriod) {
            // Calculate the amount of tokens vested based on the vesting duration
            vestedTokens = (amount * timeSinceStart) / vestingPeriod;
        } else {
            // All tokens have vested after the vesting duration
            vestedTokens = amount;
        }
        return vestedTokens;
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

    function expectedTokens(uint _amountInEth) view external returns (uint _expectedTokens) {
        _expectedTokens = _amountInEth / pricePerToken;
    }

    receive() external payable {
    // This function is executed when a contract receives plain Ether (without data)
}
}
