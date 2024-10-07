// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {Deploy} from "script/Deploy.s.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {PoolPlayground} from "src/PoolPlayground.sol";
import {Token} from "src/Token.sol";

contract TestSetup is Test {
    // Added to remove this whole testing file from coverage report.
    function test() public {}

    PoolPlayground poolPlayground;
    uint256 TOKEN_DECIMALS;

    // Setup testing constants
    uint256 internal constant GAS_PRICE = 1;
    uint256 internal constant STARTING_BALANCE = 10 ether;
    uint256 internal constant SEND_VALUE = 1 ether;
    uint256 internal constant BLOCK_PERIOD = 12;
    uint256 internal constant BLOCK_NUMBER_INCREASE = 1;

    // Create users
    address defaultFoundryCaller = address(uint160(uint256(keccak256("foundry default caller"))));
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");

    function setUp() external {
        // Deploy contract
        Deploy deploy = new Deploy();
        (address poolPlaygroundAddress) = deploy.run();

        poolPlayground = PoolPlayground(poolPlaygroundAddress);
        TOKEN_DECIMALS = poolPlayground.TOKEN_DECIMALS();

        // Give all the users a starting balance of ETH
        vm.deal(user1, STARTING_BALANCE);
        vm.deal(user2, STARTING_BALANCE);
    }
}
