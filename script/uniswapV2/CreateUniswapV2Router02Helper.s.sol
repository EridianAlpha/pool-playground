// SPDX-License-Identifier: MIT
pragma solidity =0.6.6;

import "@uniswap/v2-periphery/contracts/UniswapV2Router02.sol";

contract CreateUniswapV2Router02Helper {
    function run(address _factory) public returns (address) {
        return address(new UniswapV2Router02(_factory, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));
    }
}
