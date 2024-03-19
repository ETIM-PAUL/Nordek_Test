// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {CSD} from "../src/CSD.sol";

contract CSDTest is Test {
    CSD public csd;

    function setUp() public {
        csd = new CSD();
    }

}
