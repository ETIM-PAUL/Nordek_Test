// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./Crowdsale.sol";

contract CrowdsaleFactory {
  error OnlyOwner();
    error EmptyString();
    error ZeroTotalSupply();
    error ZeroPrice();
    error InvalidStartDate();
    error InvalidCliffDuration();
    error InvalidEndDate();

    function createCrowdsale(address _token, uint _pricePerToken, uint _startDate, uint _cliffDuration, uint _vestingPeriod, uint _endDate)
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

         if(_startDate > _endDate){
            revert StartDateGreaterThanEndDate();
        }

        if(block.timestamp < _startDate){
            revert InvalidStartDate();
        }

        if(_endDate < block.timestamp){
            revert InvalidEndDate();
        }

        if (_cliffDuration < _endDate){
            revert InvalidCliffDuration();
        }

        if (_vestingPeriod < _cliffDuration){
            revert InvalidVestingPeriod();
        }
        
        crowdsale = new Crowdsale(_token, _pricePerToken, _startDate, _cliffDuration, _vestingPeriod, _endDate);
    }
}