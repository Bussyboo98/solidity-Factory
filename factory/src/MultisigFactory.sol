// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;
import "./MultisigTransact.sol";

contract MultisigFactory{
    address [] public wallets;

    event WalletCreated(address walletAddress);

    function createChild(address[] memory _owners, uint _required) external{ 
        MultisigTransact multisigTransact = new MultisigTransact(_owners, _required);

        wallets.push(address(multisigTransact));
        emit WalletCreated(address(multisigTransact));
        
    }

    function getWallets() public view returns(address[] memory){
        return wallets;
    }

}