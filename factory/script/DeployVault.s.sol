// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/VaultFactory.sol";

contract DeployVault is Script {

    function run() external {

        vm.startBroadcast();

        VaultFactory factory = new VaultFactory();

        vm.stopBroadcast();
    }
}