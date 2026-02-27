// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {MultisigFactory} from "../src/MultisigFactory.sol";
import {MultisigTransact} from "../src/MultisigTransact.sol";

contract MultisigFactoryTest is Test {
    MultisigFactory multisigFactory;

    address owner1 = address(1);
    address owner2 = address(2);
    address owner3 = address(3);

    address[] owners;

    function setUp() public{
        multisigFactory = new MultisigFactory();
        owners.push(owner1);
        owners.push(owner2);
        owners.push(owner3);
    }

     function testCreateChildWallet() public {

        multisigFactory.createChild(owners, 2);

        address wallet = multisigFactory.wallets(0);

        assertTrue(wallet != address(0));
    }



}
