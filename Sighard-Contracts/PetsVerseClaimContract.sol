// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IERC20 {
    /**
    * @dev Emitted when `value` tokens are moved from one account (`from`) to
    * another (`to`).
    *
    * Note that `value` may be zero.
    */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
    * @dev Emitted when the allowance of a `spender` for an `owner` is set by
    * a call to {approve}. `value` is the new allowance.
    */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
    * @dev Returns the amount of tokens in existence.
    */
    function totalSupply() external view returns (uint256);

    /**
    * @dev Returns the amount of tokens owned by `account`.
    */
    function balanceOf(address account) external view returns (uint256);

    /**
    * @dev Moves `amount` tokens from the caller's account to `to`.
    *
    * Returns a boolean value indicating whether the operation succeeded.
    *
    * Emits a {Transfer} event.
    */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
    * @dev Returns the remaining number of tokens that `spender` will be
    * allowed to spend on behalf of `owner` through {transferFrom}. This is
    * zero by default.
    *
    * This value changes when {approve} or {transferFrom} are called.
    */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
    * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
    *
    * Returns a boolean value indicating whether the operation succeeded.
    *
    * IMPORTANT: Beware that changing an allowance with this method brings the risk
    * that someone may use both the old and the new allowance by unfortunate
    * transaction ordering. One possible solution to mitigate this race
    * condition is to first reduce the spender's allowance to 0 and set the
    * desired value afterwards:
    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    *
    * Emits an {Approval} event.
    */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
    * @dev Moves `amount` tokens from `from` to `to` using the
    * allowance mechanism. `amount` is then deducted from the caller's
    * allowance.
    *
    * Returns a boolean value indicating whether the operation succeeded.
    *
    * Emits a {Transfer} event.
    */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
    * @dev Returns the address of the current owner.
    */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
    * @dev Throws if the sender is not the owner.
    */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
    * @dev Leaves the contract without owner. It will not be possible to call
    * `onlyOwner` functions anymore. Can only be called by the current owner.
    *
    * NOTE: Renouncing ownership will leave the contract without an owner,
    * thereby removing any functionality that is only available to the owner.
    */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
    * @dev Transfers ownership of the contract to a new account (`newOwner`).
    * Can only be called by the current owner.
    */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
    * @dev Transfers ownership of the contract to a new account (`newOwner`).
    * Internal function without access restriction.
    */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract ClaimContract is Ownable{

    struct Claim{
        address user;
        uint256 amount;
        uint256 claimedAmount;
    }
    
    mapping(address => uint256) _balances;
    mapping(address => uint256) _claimedBalances;
    IERC20 public climableToken;
    bool pauseClaim;

    constructor(address _climableToken) {
        climableToken = IERC20(_climableToken);
        pauseClaim = true;
    }

    function claimStuckTokens(address token) external onlyOwner {
        if (token == address(0x0)) {
            payable(msg.sender).transfer(address(this).balance);
            return;
        }
        IERC20 ERC20token = IERC20(token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(msg.sender, balance);
    }

    function setBalances(address[] memory addresses, uint256[] memory amounts) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            _balances[addresses[i]] += amounts[i];
        }
    }

    function setDirectBalances(address[] memory addresses, uint256[] memory amounts) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            _balances[addresses[i]] = amounts[i];
        }
    }

    function setClaimStatus(bool _pauseClaim) external onlyOwner {
        require(pauseClaim != _pauseClaim, "Claim status is already set");
        pauseClaim = _pauseClaim;
    }

    function claim() external{
        uint256 amount = _balances[msg.sender];
        require(!pauseClaim, "Claim is paused");
        require(amount > 0, "No tokens to claim");
        _balances[msg.sender] = 0;
        _claimedBalances[msg.sender]=amount;
        bool succes = climableToken.transfer(msg.sender, amount);
        
        if(!succes){
            _balances[msg.sender] = amount;
            _claimedBalances[msg.sender]=0;
        }

    }

    function getClaimableAmount(address user) external view returns(uint256){
        return _balances[user];
    }

    function getClaimedAmount(address user) external view returns(uint256){
        return _claimedBalances[user];
    }

    function getBalance(address[] memory user) external view returns(Claim[] memory){
        Claim[] memory claims = new Claim[](user.length);
        for(uint256 i=0;i<user.length;++i){
            claims[i].user=user[i];
            claims[i].amount=_balances[user[i]];
            claims[i].claimedAmount=_claimedBalances[user[i]];
        }
        return claims;
    }

}