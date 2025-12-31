// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

contract StructTest {
    struct User {
        uint256 favNumber;
        string name;
    }
    
    User[] public users;
    
    function addUser(uint256 _favNumber, string memory _name) public {
        users.push(User(_favNumber, _name));
    }
    
    function getUserCount() public view returns (uint256) {
        return users.length;
    }
}