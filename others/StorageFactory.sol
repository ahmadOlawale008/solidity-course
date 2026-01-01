// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "./SimpleStorage.sol";

contract StorageFactory {
    SimpleStorage[] public simpleStorageArray;
    
    function createSimpleStorageContract() public {
        SimpleStorage simpleStorage = new SimpleStorage(); 
        simpleStorageArray.push(simpleStorage);
    }

    function sfStore(uint256 _simpleStorageIndex, uint256 _simpleStoragenumber) public {
        // To interact with any contract we need:
        // Address of contract
        // ABi - Application Binary Interface: This tells our code how to interact with contract.
        simpleStorageArray[_simpleStorageIndex].store(_simpleStoragenumber);
    }
    
    function sfGet(uint256 _simpleStorageIndex) public view returns (uint256){
        return simpleStorageArray[_simpleStorageIndex].retrieve();
    }   
}
