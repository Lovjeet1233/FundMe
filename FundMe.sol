// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
//get funds from users
//withdraw funds
//set a min value of fund
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

//interface code
// interface AggregatorV3Interface {
//   function decimals() external view returns (uint8);

//   function description() external view returns (string memory);

//   function version() external view returns (uint256);

//   function getRoundData(
//     uint80 _roundId
//   ) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

//   function latestRoundData()
//     external
//     view
//     returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
// }

contract FundMe {
    uint256 public minimumUsd = 5e18;
    //as msg.value will have 18 0s thats why we added 1e18
    //to check amount funded by any user
    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    address public owner;
      
    constructor() {
        owner = msg.sender;
    }

    function fund() public payable {
        // in every transaction we need some ether or wei
        // msg.value tracks the wei and we can set that value to a minimum
        //we want minimum fund that should be funded
        //payble coz msg.value" and "callvalue()" can only be used in payable public functions
        //msg.sender is a global varriable to check address of transaction
        require(
            getConversionRate(msg.value) >= minimumUsd,
            "funds is not suffiecient"
        );
        //now we are pushing address to our array
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] =
            addressToAmountFunded[msg.sender] +
            msg.value;
    }

    function getLatestPrice() public view returns (uint256) {
        AggregatorV3Interface PriceFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        (, int256 answer, , , ) = PriceFeed.latestRoundData();
        return uint256(answer) * 1e10;
    }

    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getLatestPrice();
        uint256 ethAmountInUsd = (ethAmount * ethPrice) / (1e18);
        return ethAmountInUsd;
        //ethAmountInUsd will have 18 0 at last
    }

    function getVersion() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        return priceFeed.version();
    }

    //in withdraw we are basically making funds to 0
    function withDraw() public {
        require(msg.sender == owner, "must be owner");
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        //contract SendEther {
        // function sendViaTransfer(address payable _to) public payable {
        //     _to.transfer(msg.value); // Automatically reverts on failure
        // }
        // function sendViaSend(address payable _to) public payable {
        //     bool sent = _to.send(msg.value); // Returns false on failure
        //     require(sent, "Failed to send Ether");
        // }
        // function sendViaCall(address payable _to) public payable {
        //     (bool sent, bytes memory data) = _to.call{value: msg.value}(""); // Returns false on failure
        //     require(sent, "Failed to send Ether");
        // }
        //Transfer
        payable(msg.sender).transfer(address(this).balance);
        //send
        bool isSuccess = payable(msg.sender).send(address(this).balance);
        require(isSuccess, "failed to send ether");
        //call
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "CallSuccess Failed");
    }
    // Ether is sent to contract
//      is msg.data empty?
//          /   \
//         yes  no
//         /     \
//    receive()?  fallback()
//     /   \
//   yes   no
//  /        \
//receive()  fallback()
  //what if someone sends ether without calling fund function thats why we are using receive and fallback function
  //we will only be able to send funds when we call the fund funciton
    receive() external payable {
        fund();
    }
    fallback() external payable{
        fund();
    }

}
