// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

contract RandomNumberGenerater {
    constructor () {}

    function rand() public view returns(uint256) {
        uint256 seed = uint256(keccak256(abi.encodePacked(block.timestamp + block.difficulty + ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +block.gaslimit +((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +block.number)));
        return seed;
    }

}