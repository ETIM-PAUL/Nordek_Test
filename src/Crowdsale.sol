// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Crowdsale {
    using SafeMath for uint256;
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
    error CrowdsaleHalted();
    error CrowdsaleNotStarted();
    error CrowdsaleEnded();
    error TotalSupplyWillBeExceeded();

    event TokensReleased(uint);

    constructor(address _token, uint _pricePerToken, uint _startDate, uint _cliffDuration, uint _vestingPeriod, uint _endDate) {
        owner = msg.sender;
        pricePerToken = _pricePerToken;
        startDate = _startDate;
        endDate = _endDate;
        cliffDuration=_cliffDuration;
        vestingPeriod=_vestingPeriod;
        token = ERC20(_token);
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


        //here, we give a receipt to the buyer
        TokensPurchaser storage purchaser = crowdsale_participants[msg.sender];
        purchaser.amount = purchaser.amount + amount;

        // Set vesting start time if it hasn't been set yet
        if (purchaser.purchasedTime == 0) {
            purchaser.purchasedTime = block.timestamp;
        }
        totalReceipt+amount;
    }

    function getTokensRelease() external {
        if(paused){
            revert CrowdsaleHalted();
        }
        TokensPurchaser storage purchaser = crowdsale_participants[msg.sender];
        require(purchaser.amount > 0, "No tokens to release");
        require(block.timestamp >= purchaser.purchasedTime + cliffDuration, "Cliff period has not passed yet");

        uint256 tokensReleased = vestedAmount(purchaser);
        purchaser.amount = purchaser.amount.sub(tokensReleased);

        token.transfer(msg.sender, tokensReleased);
        emit TokensReleased(tokensReleased);
    }

    function vestedAmount(TokensPurchaser memory purchaser) internal view returns (uint256) {
         uint256 timeSinceStart = block.timestamp.sub(purchaser.purchasedTime);
        uint256 vestedTokens = 0;

        if (timeSinceStart >= cliffDuration) {
            uint256 vestedPeriod = timeSinceStart.sub(cliffDuration);
            uint256 totalVestingPeriod = vestingPeriod.sub(cliffDuration);
            vestedTokens = (purchaser.amount).mul(vestedPeriod).div(totalVestingPeriod);
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

    function returnCurrentTime()
        external
        view
        returns (uint time)
    {
        //This returns the amount of ethers our contract holds
        time = block.timestamp;
    }
    function returnBalance()
        external
        view
        returns (uint etherbalance)
    {
        //This returns the amount of ethers our contract holds
        etherbalance = address(this).balance;
    }

    function getSupply() view external returns (uint supply) {
        supply = token.totalSupply();
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
