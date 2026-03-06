// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transferFrom(address from, address to, uint amount) external returns (bool);
    function transfer(address to, uint amount) external returns (bool);
    function balanceOf(address account) external view returns (uint);
}

contract Vault {

    address public token;
    address public owner;
    uint public totalDeposited;

    mapping(address => uint) public deposits;

    event DepositSuccessful(address indexed sender, uint256 indexed amount);

    constructor(address _token, address _owner) {
        token = _token;
        owner = _owner;
    }

    function deposit(uint256 amount) external {
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        deposits[msg.sender] += amount;

        totalDeposited += amount;

        emit DepositSuccessful(msg.sender, amount);

    }

    function withdraw(uint amount) external {

        require(deposits[msg.sender] >= amount,"not enough token");

        deposits[msg.sender] -= amount;

        IERC20(token).transfer(msg.sender,amount);

        totalDeposited -= amount;
    }

}