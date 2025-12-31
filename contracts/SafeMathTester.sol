// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract SafeMathTester {
    uint8 public bigNumber = 255;

    function add() public {
        unchecked {
            bigNumber = bigNumber + 1;
        } // This fails 

    }
}