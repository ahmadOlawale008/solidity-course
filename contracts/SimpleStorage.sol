// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

contract SimpleStorage {
    uint256 favNumber;
    mapping (uint256 => string) public userMapping;

    User public user1 = User({favNumber: 12, name: "Ahmad"});
    User public user2 = User({favNumber: 7, name: "Joseph"});

    User[] public users;

    struct User{
        uint256 favNumber;
        string name;
    }

    function store(uint256 _favNumber) public {
        favNumber = _favNumber;
    }
    
    function retrieve() public view returns (uint256){
        return favNumber;
    }

    function addUser(uint256 _favNumber, string memory _name) public {
        users.push(User({favNumber: _favNumber, name: _name}));
        userMapping[_favNumber] = _name;
    }
}
