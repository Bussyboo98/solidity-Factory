// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./Vault.sol";

contract VaultFactory{
   mapping(address => address) public tokenVault;

    event VaultCreated(address token, address vault);

    function createVault(address token) external returns (address vault){
        require(tokenVault[token] == address(0), "Vault already exists");

        bytes32 salt = keccak256(abi.encodePacked(token));

        vault = address(new Vault{salt: salt}(token, msg.sender));

        tokenVault[token] = vault;

        emit VaultCreated(token, vault);
    }

    function deposit(address token,uint amount) external {

        address vault = tokenVault[token];

        if(vault == address(0)){

            bytes32 salt = keccak256(abi.encodePacked(token));

            vault = address(new Vault{salt:salt}(token,msg.sender));

            tokenVault[token] = vault;
        }

        IERC20(token).transferFrom(msg.sender,vault,amount);

        Vault(vault).deposit(amount);
    }
}