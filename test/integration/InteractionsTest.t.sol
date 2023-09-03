// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {Script} from "forge-std/Script.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test, Script {
    FundMe fundMe;
    DeployFundMe deployFundMe;
    address USER = makeAddr("user"); // create a fake address to send tx
    uint256 constant SEND_ETHER = 0.1 ether;
    uint256 constant FAKE_BALANCE = 1 ether;

    function setUp() public {
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, SEND_ETHER);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assertEq(address(fundMe).balance, 0);
    }
}
