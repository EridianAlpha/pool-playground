// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {TestSetup} from "test/TestSetup.t.sol";
import {PoolPlayground} from "src/PoolPlayground.sol";
import {IUniswapV2Pair} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// UniswapV2 Imports
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract Deploy is TestSetup {
    function test_deploy() public {
        vm.broadcast(user1);

        PoolPlayground.TokenAmounts memory userTokenAmounts = PoolPlayground.TokenAmounts({
            diamond: 10 * TOKEN_DECIMALS,
            wood: 50 * TOKEN_DECIMALS,
            stone: 100 * TOKEN_DECIMALS
        });

        PoolPlayground.TokenAmounts[] memory poolTokenAmounts = new PoolPlayground.TokenAmounts[](3);
        poolTokenAmounts[0] =
            PoolPlayground.TokenAmounts({diamond: 10 * TOKEN_DECIMALS, wood: 100 * TOKEN_DECIMALS, stone: 0});
        poolTokenAmounts[1] =
            PoolPlayground.TokenAmounts({diamond: 10 * TOKEN_DECIMALS, wood: 0, stone: 100 * TOKEN_DECIMALS});
        poolTokenAmounts[2] =
            PoolPlayground.TokenAmounts({diamond: 0, wood: 100 * TOKEN_DECIMALS, stone: 100 * TOKEN_DECIMALS});

        // Deploy the playground instance
        poolPlayground.deploy(userTokenAmounts, poolTokenAmounts);

        // Get the user token addresses
        PoolPlayground.TokenAddresses memory userTokenAddresses = poolPlayground.getUserTokens(user1);

        // Get the UniswapV2Factory instance
        IUniswapV2Factory uniswapV2Factory = IUniswapV2Factory(poolPlayground.getContractAddress("uniswapV2Factory"));

        // Get the pair addresses
        address diamondWoodPair = uniswapV2Factory.getPair(userTokenAddresses.diamond, userTokenAddresses.wood);
        address diamondStonePair = uniswapV2Factory.getPair(userTokenAddresses.diamond, userTokenAddresses.stone);
        address woodStonePair = uniswapV2Factory.getPair(userTokenAddresses.wood, userTokenAddresses.stone);

        // Check ending user balances are correct
        assertEq(IERC20(userTokenAddresses.diamond).balanceOf(user1), userTokenAmounts.diamond);
        assertEq(IERC20(userTokenAddresses.wood).balanceOf(user1), userTokenAmounts.wood);
        assertEq(IERC20(userTokenAddresses.stone).balanceOf(user1), userTokenAmounts.stone);

        // Check pair reserves for Diamond/Wood
        verifyPairReserves(
            diamondWoodPair, userTokenAddresses.diamond, poolTokenAmounts[0].diamond, poolTokenAmounts[0].wood
        );

        // Check pair reserves for Diamond/Stone
        verifyPairReserves(
            diamondStonePair, userTokenAddresses.diamond, poolTokenAmounts[1].diamond, poolTokenAmounts[1].stone
        );

        // Check pair reserves for Wood/Stone
        verifyPairReserves(woodStonePair, userTokenAddresses.wood, poolTokenAmounts[2].wood, poolTokenAmounts[2].stone);

        // Log the token addresses and pair details
        // verboseDeploymentLogs(userTokenAddresses);
    }

    function verifyPairReserves(address pair, address token0, uint256 expectedAmount0, uint256 expectedAmount1)
        internal
        view
    {
        IUniswapV2Pair uniswapPair = IUniswapV2Pair(pair);
        (uint112 reserve0, uint112 reserve1,) = uniswapPair.getReserves();

        if (uniswapPair.token0() == token0) {
            assertEq(reserve0, expectedAmount0);
            assertEq(reserve1, expectedAmount1);
        } else {
            assertEq(reserve0, expectedAmount1);
            assertEq(reserve1, expectedAmount0);
        }
    }

    function verboseDeploymentLogs(PoolPlayground.TokenAddresses memory userTokenAddresses) internal view {
        // Get the UniswapV2Factory instance
        IUniswapV2Factory uniswapV2Factory = IUniswapV2Factory(poolPlayground.getContractAddress("uniswapV2Factory"));

        // Get the pair addresses
        address diamondWoodPair = uniswapV2Factory.getPair(userTokenAddresses.diamond, userTokenAddresses.wood);
        address diamondStonePair = uniswapV2Factory.getPair(userTokenAddresses.diamond, userTokenAddresses.stone);
        address woodStonePair = uniswapV2Factory.getPair(userTokenAddresses.wood, userTokenAddresses.stone);

        // Log the token addresses
        console.log("Token Addresses");
        console.log("  Diamond: ", userTokenAddresses.diamond);
        console.log("  Wood:    ", userTokenAddresses.wood);
        console.log("  Stone:   ", userTokenAddresses.stone);

        // Log the contract balances
        console.log("Contract Balances");
        console.log("  Diamond: ", IERC20(userTokenAddresses.diamond).balanceOf(address(poolPlayground)));
        console.log("  Wood:    ", IERC20(userTokenAddresses.wood).balanceOf(address(poolPlayground)));
        console.log("  Stone:   ", IERC20(userTokenAddresses.stone).balanceOf(address(poolPlayground)));

        // Log the user balances
        console.log("User Balances");
        console.log("  Diamond: ", IERC20(userTokenAddresses.diamond).balanceOf(user1));
        console.log("  Wood:    ", IERC20(userTokenAddresses.wood).balanceOf(user1));
        console.log("  Stone:   ", IERC20(userTokenAddresses.stone).balanceOf(user1));

        // Log the token0, token1, and reserves for each pair
        logPairDetails("Diamond/Wood Pair:  ", diamondWoodPair);
        logPairDetails("Diamond/Stone Pair: ", diamondStonePair);
        logPairDetails("Wood/Stone Pair:    ", woodStonePair);
    }

    function logPairDetails(string memory _pairName, address _pairAddress) internal view {
        // Create an instance of the pair contract
        IUniswapV2Pair pair = IUniswapV2Pair(_pairAddress);

        // Get the addresses of token0 and token1
        address token0 = pair.token0();
        address token1 = pair.token1();

        // Get the reserves
        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();

        // Log token addresses and their reserves
        console.log(_pairName);
        console.log("  Pair Address: ", _pairAddress);
        console.log("  Token0:       ", token0);
        console.log("  Token1:       ", token1);
        console.log("  Reserve0:     ", reserve0);
        console.log("  Reserve1:     ", reserve1);
    }
}
