// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Script, console} from "lib/forge-std/src/Script.sol";

interface IUniswapV2FactoryHelper {
    function run() external returns (address);
}

contract DeployUniswapV2Factory is Script {
    function run(address _uniswapV2FactoryHelper) public returns (address deployedUniswapV2FactoryAddress) {
        vm.startBroadcast(msg.sender);
        IUniswapV2FactoryHelper helper = IUniswapV2FactoryHelper(_uniswapV2FactoryHelper);
        deployedUniswapV2FactoryAddress = helper.run();
        vm.stopBroadcast();
    }
}
