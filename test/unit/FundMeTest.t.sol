// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {Script} from "forge-std/Script.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test, Script {
    FundMe fundMe;
    DeployFundMe deployFundMe;
    address USER = makeAddr("user"); // create a fake address to send tx
    uint256 constant SEND_ETHER = 0.1 ether;
    uint256 constant FAKE_BALANCE = 1 ether;

    // address priceFeed = 0x694AA1769357215DE4FAC081bf1f309aDC325306;

    function setUp() external {
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, FAKE_BALANCE); // send fake balance to fake address
    }

    // function testDemo() public view {
    //     console.log("Hi, log");
    // }

    // function testPriceFeedAddress() public {
    //     assertEq(address(fundMe.getPriceFeed()), address(priceFeed));
    // }

    function testMinimumUSD() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersion() public {
        uint256 version = fundMe.getVersion();
        // console.log(version);
        assertEq(version, 4);
    }

    function testFundFailWithNotEnoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundDataStructure() public {
        vm.prank(USER); // The next tx will be sent by USER
        fundMe.fund{value: SEND_ETHER}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_ETHER);
    }

    function testAddsFunderToFunderArray() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_ETHER}();

        address funder = fundMe.getFunder(0);
        assertEq(USER, funder);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_ETHER}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawWithMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (
            uint160 funderIndex = startingFunderIndex;
            funderIndex < numberOfFunders;
            funderIndex++
        ) {
            hoax(address(funderIndex), SEND_ETHER);
            fundMe.fund{value: SEND_ETHER}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawWithMultipleFundersCheaper() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (
            uint160 funderIndex = startingFunderIndex;
            funderIndex < numberOfFunders;
            funderIndex++
        ) {
            hoax(address(funderIndex), SEND_ETHER);
            fundMe.fund{value: SEND_ETHER}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
    }
}
