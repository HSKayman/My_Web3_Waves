// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

contract SDF {
    uint256 private data = 2 * 1e17;
    uint80 _roundId;

    function latestRoundData() external view returns (uint80, uint256, uint256, uint256, uint80){
        return(uint80(_roundId), uint256(data), uint256(block.timestamp), uint256(block.timestamp), uint80(0));
    }

    function update(uint256 _data) external {
        data = _data * 1e15;
        _roundId+=1;
    }
}



