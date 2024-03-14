// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;


// CONTEXT
abstract contract Context 
{
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}

// OWNABLE
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }


    function owner() public view virtual returns (address) {
        return _owner;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }


    modifier onlyOwner() {
        require(owner() == _msgSender(), "Caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "New owner can not be the ZERO address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// REENTRANCY GUARD
abstract contract ReentrancyGuard 
{
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}


// DICE INTERFACE
abstract contract BMDice
{
    function Drop(uint256 rollId, uint256 rollResult) external virtual;
}


abstract contract BMDiceReferee
{
     function Drop(uint256 id, uint256 result) external virtual; 
}


contract BMDiceController is ReentrancyGuard, Ownable 
{
    
    // Game Contract
    BMDice internal gameContract;

    // Roll BMDiceReferee
    BMDiceReferee internal refereeContract;
  
    constructor(address _refereeContract) 
    {
        refereeContract = BMDiceReferee(_refereeContract);
    }


    modifier onlyRefereeContract() 
    {
        require(msg.sender == address(refereeContract), "Only game contract allowed");
        _;
    }
    

    function setRollReferee(address _refereeContract) external onlyOwner 
    {
        refereeContract = BMDiceReferee(_refereeContract);
    }


    // -------------------------
    // START ----------------
    //--------------------------
    function Resolve(uint256 id) external onlyRefereeContract
    {
        uint result = (_random(id) + id * id) % 6 + 1;
        refereeContract.Drop(id, result);
    }
    
    function _random(uint256 id) internal view returns(uint)
    {
        return uint(keccak256(abi.encodePacked(block.timestamp,
                                            msg.sender,
                                            id)));
    }
    
}