// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import {Test, console2} from "forge-std/Test.sol";
import {CrowdsaleFactory} from "../src/CrowdsaleFactory.sol";
import {CSD} from "../src/CSD.sol";
import {Crowdsale} from "../src/Crowdsale.sol";

contract CrowdsaleTest is Test {
    CrowdsaleFactory public crowdsaleFactory;
    Crowdsale public crowdsale;
    CSD public csd;
    address user1;
    address user2;
    uint currentTime;

    struct TokensPurchaser {
        uint amount;
        uint purchasedTime;
    }

    function setUp() public {
      crowdsaleFactory = new CrowdsaleFactory();
    csd = new CSD("Crowdsale","CSD",100e18);
        user1 = vm.addr(1);
crowdsale = crowdsaleFactory.createCrowdsale(address(csd), 1e17, currentTime + 180 seconds, currentTime + 2 days, currentTime + 5 days, currentTime + 3600 seconds);
    }

      function testZeroAmount() external payable {
vm.prank(user1);
vm.deal(user1,10e18);
vm.warp(200);
vm.expectRevert(
            abi.encodeWithSelector(
                Crowdsale.ZeroAmount.selector
            )
        );
crowdsale.buyTokens{value:0}(user1);
      }

      function testCrowdsaleHalted() external payable {
        crowdsale.pauseContract();
vm.prank(user1);
vm.deal(user1,10e18);
vm.warp(200);
vm.expectRevert(
            abi.encodeWithSelector(
                Crowdsale.CrowdsaleHalted.selector
            )
        );
crowdsale.buyTokens{value:3e17}(user1);
      }
      
      function testNotStarted() external payable {
vm.prank(user1);
vm.deal(user1,10e18);
vm.expectRevert(
            abi.encodeWithSelector(
                Crowdsale.CrowdsaleNotStarted.selector
            )
        );
crowdsale.buyTokens{value:3e17}(user1);
      }

      function testCrowdsaleEnded() external payable {
vm.prank(user1);
vm.deal(user1,10e18);
vm.warp(3700);
vm.expectRevert(
            abi.encodeWithSelector(
                Crowdsale.CrowdsaleEnded.selector
            )
        );
crowdsale.buyTokens{value:3e17}(user1);
      }

      function testInsufficientPrice() external payable {
vm.prank(user1);
vm.deal(user1,10e18);
vm.warp(3700);
vm.expectRevert(
            abi.encodeWithSelector(
                Crowdsale.InsufficientPrice.selector
            )
        );
crowdsale.buyTokens{value:1e16}(user1);
      }

      function testPauseAndUnPauseContract() external payable {
        crowdsale.pauseContract();
vm.deal(user1,10e18);
vm.warp(200);
        crowdsale.unPauseContract();
vm.prank(user1);
crowdsale.buyTokens{value:3e17}(user1);
      }

      function testBuyTokens() external payable {
vm.prank(user1);
vm.deal(user1,10e18);
vm.warp(200);
crowdsale.buyTokens{value:3e17}(user1);
(uint amount, uint purchasedTime) = crowdsale.crowdsale_participants(user1);
assertGt(amount, 0);
assertGt(purchasedTime, 0);
      }

      function testCliffPeriodNotOver() external payable {
        csd.mint(address(crowdsale),20e18);
vm.prank(user1);
vm.deal(user1,10e18);
vm.warp(3599);
crowdsale.buyTokens{value:3e17}(user1);
vm.warp(currentTime + 1 days);
vm.expectRevert(
            abi.encodeWithSelector(
                Crowdsale.CliffPeriodNotOver.selector
            )
        );
crowdsale.getTokensRelease(user1);
      }

      function testReleaseTokens() external payable {
        csd.mint(address(crowdsale),20e18);
vm.prank(user1);
vm.deal(user1,10e18);
vm.warp(200);
crowdsale.buyTokens{value:3e17}(user1);
vm.warp(currentTime + 3 days);
vm.prank(user1);
crowdsale.getTokensRelease(user1);
assertEq(csd.balanceOf(user1), 1e18);
      }

      function testExpectedTokens() external payable {
vm.prank(user1);
vm.deal(user1,10e18);
vm.warp(200);
uint expectedAmount = crowdsale.expectedTokens(3e17);
assertEq(expectedAmount, 3);
      }

      function testWithdrawEther() external payable {
vm.startPrank(user1);
vm.deal(user1,10e18);
vm.warp(200);
crowdsale.buyTokens{value:3e17}(user1);
vm.stopPrank();
crowdsale.withdrawEther(payable(user1));
assertEq(address(crowdsale).balance, 0);
      }
}
