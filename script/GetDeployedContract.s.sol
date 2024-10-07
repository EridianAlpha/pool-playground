// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Script} from "lib/forge-std/src/Script.sol";
import {DevOpsTools} from "@foundry-devops/src/DevOpsTools.sol";

// ================================================================
// │                      GET DEPLOYED CONTRACT                   │
// ================================================================
contract GetDeployedContract is Script {
    function test() public virtual {} // Added to remove this whole contract from coverage report.

    function getDeployedContract(string memory contractName) public view returns (address deployedContractAddress) {
        try vm.envAddress("DEPLOYED_CONTRACT_ADDRESS") returns (address addr) {
            if (addr != address(0)) {
                deployedContractAddress = addr;
            } else {
                deployedContractAddress = DevOpsTools.get_most_recent_deployment(contractName, block.chainid);
            }
        } catch {
            deployedContractAddress = DevOpsTools.get_most_recent_deployment(contractName, block.chainid);
        }
        require(deployedContractAddress != address(0), string(abi.encodePacked(contractName, " address is invalid")));
    }
}
