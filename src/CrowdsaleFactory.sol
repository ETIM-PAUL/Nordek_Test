// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "./Crowdsale.sol";

contract CrowdsaleFactory {
  error OnlyOwner();
    error StartDateGreaterThanEndDate();
    error ZeroPrice();
    error InvalidStartDate();
    error InvalidCliffDuration();
    error InvalidVestingPeriod();

    function createCrowdsale(address _token, uint _pricePerToken, uint _startDate, uint _cliffDuration, uint _vestingPeriod, uint _endDate)
        external
        returns (bool success)
    {
        if(_pricePerToken == 0){
            revert ZeroPrice();
        }

         if(_startDate > _endDate){
            revert StartDateGreaterThanEndDate();
        }

        if(block.timestamp > _startDate){
            revert InvalidStartDate();
        }

        if (_cliffDuration < _endDate){
            revert InvalidCliffDuration();
        }

        if (_vestingPeriod < _cliffDuration){
            revert InvalidVestingPeriod();
        }
        
        Crowdsale crowdsale = new Crowdsale(_token, _pricePerToken, _startDate, _cliffDuration, _vestingPeriod, _endDate);
    success = true;
    }
}