// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Script, console} from "lib/forge-std/src/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

import {PoolPlayground} from "src/PoolPlayground.sol";

contract Deploy is Script {
    function run() public returns (address deployedPoolPlaygroundAddress) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getActiveNetworkConfig();

        PoolPlayground.ContractAddress[] memory contractAddresses = config.contractAddresses;

        vm.startBroadcast(msg.sender);
        deployedPoolPlaygroundAddress = address(new PoolPlayground(contractAddresses));
        vm.stopBroadcast();
    }
}
