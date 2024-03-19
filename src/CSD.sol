// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CSD is ERC20 {
    address owner;
    uint constant TOTAL_SUPPLY_LIMIT = 1000e18;

    error OnlyOwner();
    error InvalidAddress();
    error ZeroAmount();
    error TotalSupplyWillBeExceeded();

    constructor() ERC20("Crowsdale", "CSD") {
        owner = msg.sender;
    }

    function mint(address reciever, uint amount) external {
        require(msg.sender == owner, "Only Owner");
        if(msg.sender != owner){
            revert OnlyOwner();
        }
        if(reciever == address(0)){
            revert InvalidAddress();
        }
        if(amount == 0){
            revert ZeroAmount();
        }
        if((totalSupply() + amount)  > TOTAL_SUPPLY_LIMIT){
            revert TotalSupplyWillBeExceeded();
        }
        _mint(reciever, amount);
    }

    function getSupply() view external {
        totalSupply();
    }
}
