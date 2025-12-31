// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "./PriceConverter.sol";

/*
 * Get funds from users
 * Withdraw funds
 * Set a minimum funding value in USD
 */
error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 50 * 1e18;
    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;
    address public immutable i_owner;

    constructor() {
        i_owner = msg.sender;
    }
    
    receive() external payable { 
        fund();
    }
    
    fallback() external payable { 
        fund();
    }

    function fund() public payable {
        // Want to be able to set a minimum fund amount in USD
        // 1. How do we send ETH to this contract?
        require(
            msg.value.getConversionRate() >= MINIMUM_USD,
            "Didn't send enough"
        );
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function callMeRightAway() public {}

    function withdraw() public isOwner {
        for (uint256 fundIndex = 0; fundIndex < funders.length; fundIndex++) {
            address funder = funders[fundIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        // transfer
        // send
        // call

        // msg.sender = address
        // payable(msg.sender) = payable address
        // bool transferStatus = payable(msg.sender).transfer(address(this).balance);
        (bool transferStatus, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(transferStatus, "Transfer Failed");
    }

    modifier isOwner() {
        if (msg.sender != i_owner) {
            revert NotOwner();
        }
        _;
    }
}
