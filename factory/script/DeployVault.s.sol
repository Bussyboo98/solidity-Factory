// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import "../src/VaultFactory.sol";
import "../src/MintVaultNFT.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployVault is Script {

    address constant USDCAddress = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    function run() external {

        vm.startBroadcast();

        VaultFactory factory = new VaultFactory();

        address vault = factory.createVault(USDCAddress);

        console.log("Vault deployed:", vault);

        MintVaultNFT nft = new MintVaultNFT();

        uint256 tokenId = nft.mint(msg.sender, vault);

        console.log("NFT Token ID:", tokenId);

        console.log("Token URI:");
        console.log(nft.tokenURI(tokenId));

        vm.stopBroadcast();
    }
}