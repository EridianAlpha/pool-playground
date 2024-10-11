// SPDX-License-Identifier: MIT
pragma solidity =0.5.16;

import "@uniswap/v2-core/contracts/UniswapV2Factory.sol";

contract CreateUniswapV2FactoryHelper {
    function run() public returns (address) {
        return address(new UniswapV2Factory(0x18e433c7Bf8A2E1d0197CE5d8f9AFAda1A771360));
    }
}
