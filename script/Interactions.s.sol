// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

// ================================================================
// │                           IMPORTS                            │
// ================================================================

// Forge and Script Imports
import {console} from "lib/forge-std/src/Script.sol";
import {GetDeployedContract} from "script/GetDeployedContract.s.sol";

// Contract Imports
import {PoolPlayground} from "src/PoolPlayground.sol";

// Library Directive Imports
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

// Interface Imports
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// ================================================================
// │                         INTERACTIONS                         │
// ================================================================
contract Interactions is GetDeployedContract {
    function test() public override {} // Added to remove this whole contract from coverage report.

    // Library directives
    using Address for address payable;

    // Contract variables
    PoolPlayground public poolPlayground;
    uint256 TOKEN_DECIMALS;

    function interactionsSetup() public {
        poolPlayground = PoolPlayground(payable(getDeployedContract("PoolPlayground")));
        TOKEN_DECIMALS = poolPlayground.TOKEN_DECIMALS();
    }

    function deployPlaygroundInstance() public {
        interactionsSetup();
        vm.startBroadcast();

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
            PoolPlayground.TokenAmounts({diamond: 0, wood: 20 * TOKEN_DECIMALS, stone: 200 * TOKEN_DECIMALS});

        // Deploy the playground instance
        poolPlayground.deploy(userTokenAmounts, poolTokenAmounts);

        vm.stopBroadcast();
    }
}
