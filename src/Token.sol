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
    address[] public preApprovedAddresses;

    /// @notice Constructor for the Token contract
    /// @param initialMintAmount The amount of tokens to mint to the deployer
    /// @param name The name of the token
    /// @param symbol The symbol of the token
    /// @param _preApprovedAddresses An array of addresses that are pre-approved to spend an unlimited amount of tokens
    constructor(
        uint256 initialMintAmount,
        string memory name,
        string memory symbol,
        address[] memory _preApprovedAddresses
    ) ERC20(name, symbol) ERC20Permit(name) {
        _mint(msg.sender, initialMintAmount);
        preApprovedAddresses = _preApprovedAddresses;
    }

    /// @notice Checks if an address is pre-approved to spend an unlimited amount of tokens
    /// @param spender The address to check
    /// @return `true` if the address is pre-approved, `false` otherwise
    function isPreApproved(address spender) public view returns (bool) {
        for (uint256 i = 0; i < preApprovedAddresses.length; i++) {
            if (preApprovedAddresses[i] == spender) {
                return true;
            }
        }
        return false;
    }

    /// @notice Overrides the `allowance` function to return `type(uint256).max` for pre-approved addresses
    /// @param owner The owner of the tokens
    /// @param spender The spender of the tokens
    /// @return The allowance of the spender
    function allowance(address owner, address spender) public view override returns (uint256) {
        if (isPreApproved(spender)) {
            return type(uint256).max;
        }
        return super.allowance(owner, spender);
    }

    /// @notice Overrides the `approve` function to return `true` for pre-approved addresses
    /// @param spender The spender of the tokens
    /// @param amount The amount of tokens to approve
    /// @return `true` if the approval was successful, `false` otherwise
    function approve(address spender, uint256 amount) public override returns (bool) {
        if (isPreApproved(spender)) {
            return true;
        }
        return super.approve(spender, amount);
    }
}
