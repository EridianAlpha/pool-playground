// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

// OpenZeppelin Imports
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

// ================================================================
// │                  POOL PLAYGROUND TOKEN CONTRACT              │
// ================================================================

/// @title Pool Playground Token
/// @author EridianAlpha
/// @notice An ERC20 token contract used in the Pool Playground project.
contract Token is ERC20, ERC20Permit {
    constructor(uint256 initialMintAmount, string memory name, string memory symbol)
        ERC20(name, symbol)
        ERC20Permit(name)
    {
        _mint(msg.sender, initialMintAmount);
    }
}
