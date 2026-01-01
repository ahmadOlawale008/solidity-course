// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice () internal view returns (uint256) {
        //ABI and Address of contract is needed
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (,int256 price,,, ) = priceFeed.latestRoundData();
    
        // ETH in terms of usd
        // The reason is i did is because msg.value is returned as wei which is 18 digits 
        //but price here returns 8 digits hence we convert to wei by multiplying ** 10

        return  uint256(price * 1e10);
    }

    function getConversionRate (uint256 ethAmount) internal view returns (uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;

        return ethAmountInUsd;
    }
    
    function getVersion () public view returns (uint256){
        return AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306).version();
    }
}