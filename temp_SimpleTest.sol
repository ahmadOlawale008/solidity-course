// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

contract SimpleTest {
    uint256 public number = 42;
    
    function getNumber() public view returns (uint256) {
        return number;
    }
}