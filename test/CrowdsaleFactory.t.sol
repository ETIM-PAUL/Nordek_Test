// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import {Test, console2} from "forge-std/Test.sol";
import {CrowdsaleFactory} from "../src/CrowdsaleFactory.sol";
import {CSD} from "../src/CSD.sol";

contract CrowdsaleFactoryTest is Test {
    CrowdsaleFactory public crowdsaleFactory;
    CSD public csd;
    address user1;
    address user2;
    uint currentTime;

    function setUp() public {
      crowdsaleFactory = new CrowdsaleFactory();
    csd = new CSD("Crowdsale","CSD",100e18);
        user1 = vm.addr(1);
        user2 = vm.addr(2);
        currentTime = currentTime;
    }

    function testZeroPriceRevert() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                CrowdsaleFactory.ZeroPrice.selector
            )
        );
    crowdsaleFactory.createCrowdsale(address(csd), 0, currentTime + 180 seconds, currentTime + 2 days, currentTime + 5 days, currentTime + 3600 seconds);
    }

    function testStartDateErrorRevert() public {
       vm.expectRevert(
            abi.encodeWithSelector(
                CrowdsaleFactory.StartDateGreaterThanEndDate.selector
            )
        );
    crowdsaleFactory.createCrowdsale(address(csd), 1e17, currentTime + 3800 seconds, currentTime + 2 days, currentTime + 5 days, currentTime + 3600 seconds);
    }

    function testInvalidStartDateRevert() public {
      vm.warp(1710973699);
       vm.expectRevert(
            abi.encodeWithSelector(
                CrowdsaleFactory.InvalidStartDate.selector
            )
        );
    crowdsaleFactory.createCrowdsale(address(csd), 1e17, currentTime, currentTime + 2 days, currentTime + 5 days, currentTime + 3600 seconds);
    }

    function testInvalidCliffDurationRevert() public {
       vm.expectRevert(
            abi.encodeWithSelector(
                CrowdsaleFactory.InvalidCliffDuration.selector
            )
        );
    crowdsaleFactory.createCrowdsale(address(csd), 1e17, currentTime + 180 seconds, currentTime + 1800 seconds, currentTime + 5 days, currentTime + 3600 seconds);

    }

    function testInvalidVestingPeriodRevert() public {
       vm.expectRevert(
            abi.encodeWithSelector(
                CrowdsaleFactory.InvalidVestingPeriod.selector
            )
        );
    crowdsaleFactory.createCrowdsale(address(csd), 1e17, currentTime + 3600 seconds, currentTime + 3 days, currentTime + 2 days, currentTime + 8600 seconds);

    }

    function testCreateCrowdsale() public {
      bool _success = crowdsaleFactory.createCrowdsale(address(csd), 1e17, currentTime + 180 seconds, currentTime + 2 days, currentTime + 5 days, currentTime + 3600 seconds);
      assertTrue(_success);
    }

}
