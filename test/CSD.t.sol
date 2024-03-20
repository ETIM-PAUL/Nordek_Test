// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import {Test, console2} from "forge-std/Test.sol";
import {CSD} from "../src/CSD.sol";

contract CSDTest is Test {
    CSD public csd;
    address user1;
    address user2;

    function setUp() public {
        csd = new CSD("Crowdsale","CSD",100e18);
        user1 = vm.addr(1);
        user2 = vm.addr(2);
    }

    function testOnlyOwnerRevert() public {
        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSelector(
                CSD.OnlyOwner.selector
            )
        );
    csd.mint(user1,1e18);
    }

    function testZeroAddressRevert() public {
       vm.expectRevert(
            abi.encodeWithSelector(
                CSD.InvalidAddress.selector
            )
        );
    csd.mint(address(0x0),1e18);
    }

    function testTotalSupplyRevert() public {
    csd.mint(user1,10e18);
       vm.expectRevert(
            abi.encodeWithSelector(
                CSD.TotalSupplyWillBeExceeded.selector
            )
        );
    csd.mint(user1,91e18);
    }

    function testTransfer() public {
    csd.mint(user1,1e18);
    vm.startPrank(user1);
    bool success = csd.transfer(user2, 1e17);
    assertTrue(success);
    }

    function testMint() public {
    csd.mint(user1,1e18);
    uint bal = csd.balanceOfUser(user1);
    assertEq(bal,1e18);
    }

}
