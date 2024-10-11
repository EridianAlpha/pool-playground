// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Script, console} from "lib/forge-std/src/Script.sol";

interface IUniswapV2Router02Helper {
    function run(address) external returns (address);
}

contract DeployUniswapV2Router02 is Script {
    function run(address _uniswapV2Router02Helper, address _uniswapV2Factory)
        public
        returns (address deployedUniswapV2Router02Address)
    {
        vm.startBroadcast(msg.sender);
        IUniswapV2Router02Helper helper = IUniswapV2Router02Helper(_uniswapV2Router02Helper);
        deployedUniswapV2Router02Address = helper.run(_uniswapV2Factory);
        vm.stopBroadcast();
    }
}
