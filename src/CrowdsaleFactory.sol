// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./Crowdsale.sol";

contract CrowdsaleFactory {
  error OnlyOwner();
    error EmptyString();
    error ZeroTotalSupply();
    error ZeroPrice();
    error InvalidStartDate();
    error InvalidEndDate();

    function createCrowdsale(string calldata _tokenName, string calldata _tokenSymbol, uint _totalSupplyLimit, uint _pricePerToken, uint _startDate, uint _endDate)
        external
        returns (Crowdsale crowdsale)
    {
      if(bytes(_tokenName).lenth == 0 || bytes(_tokenSymbol).lenth == 0){
            revert EmptyString();
        }
        if(_totalSupplyLimit == 0){
            revert ZeroTotalSupply();
        }
        if(_pricePerToken == 0){
            revert ZeroPrice();
        }
        if(_startDate == 0){
            revert InvalidStartDate();
        }
        
        if(_startDate == 0){
            revert InvalidEndDate();
        }
        
        crowdsale = new Crowdsale(_tokenName, _tokenSymbol, _totalSupplyLimit, _pricePerToken, _startDate, _endDate);
    }
}