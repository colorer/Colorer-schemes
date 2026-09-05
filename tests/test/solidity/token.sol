// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Token {
    event Transfer(address indexed to, uint256 amount);

    mapping(address => uint256) public balance;

    function mint(address to, uint256 amount) public {
        balance[to] += amount;
        emit Transfer(to, amount);
    }
}
