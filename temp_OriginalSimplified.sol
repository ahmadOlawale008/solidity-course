// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

contract OriginalSimplified {
    uint256 favNumber;
    
    function store(uint256 _favNumber) public {
        favNumber = _favNumber;
    }
    
    function retrieve() public view returns (uint256) {
        return favNumber;
    }
}