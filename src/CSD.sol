// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CSD is ERC20 {
    address owner;
    uint immutable totalSupplyLimit;

    error OnlyOwner();
    error InvalidAddress();
    error ZeroAmount();
    error TotalSupplyWillBeExceeded();

    constructor(string memory tokenName, string memory tokenSymbol, uint _totalSupplyLimit) ERC20(tokenName, tokenSymbol) {
        owner = msg.sender;
        totalSupplyLimit = _totalSupplyLimit;
    }

    function mint(address reciever, uint amount) external {
        if(msg.sender != owner){
            revert OnlyOwner();
        }
        if(reciever == address(0)){
            revert InvalidAddress();
        }
        if(amount == 0){
            revert ZeroAmount();
        }
        if((totalSupply() + amount)  > totalSupplyLimit){
            revert TotalSupplyWillBeExceeded();
        }
        _mint(reciever, amount);
    }

    function balanceOfUser(address _user) external returns (uint bal)  {
        bal = balanceOf(_user);
    }
}
