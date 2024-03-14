// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

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

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract Pausable is Context {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    modifier whenPaused() {
        _requirePaused();
        _;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool _approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }
}

library EnumerableSet {
    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastValue;
                set._indexes[lastValue] = valueIndex; 
            }
            set._values.pop();
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

contract GuitarNftStaking is Ownable, ReentrancyGuard, Pausable, IERC721Receiver {
    using EnumerableSet for EnumerableSet.UintSet;

    address public _stakeNftAddress;
    address public _rewardTokenAddress;
    uint256 public _rewardPerBlock = 1 ether;
    uint256 public _maxNftsPerUser = 1;
    uint256 public _startBlock;
    uint256 public _endBlock;

    struct UserInfo {
        EnumerableSet.UintSet stakedNfts;
        uint256 rewards;
        uint256 lastRewardBlock;
    }
    mapping(address => UserInfo) private _userInfo;

    event RewardTokenUpdated(address oldToken, address newToken);
    event RewardPerBlockUpdated(uint256 oldValue, uint256 newValue);
    event Staked(address indexed account, uint256 tokenId);
    event Withdrawn(address indexed account, uint256 tokenId);
    event Harvested(address indexed account, uint256 amount);
    event InsufficientRewardToken(address indexed account,uint256 amountNeeded,uint256 balance);

    constructor(address __stakeNftAddress,address __rewardTokenAddress,uint256 __startBlock,uint256 __endBlock,uint256 __rewardPerBlock){
        IERC20(__rewardTokenAddress).balanceOf(address(this));
        IERC721(__stakeNftAddress).balanceOf(address(this));
        require(__rewardPerBlock > 0, "Invalid reward per block");
        require(
            __startBlock <= __endBlock,
            "Start block must be before end block"
        );
        require(
            __startBlock > block.number,
            "Start block must be after current block"
        );

        _stakeNftAddress = __stakeNftAddress;
        _rewardTokenAddress = __rewardTokenAddress;
        _rewardPerBlock = __rewardPerBlock;
        _startBlock = __startBlock;
        _endBlock = __endBlock;
    }

    function viewUserInfo(address __account)external view returns (uint256[] memory stakedNfts,uint256 rewards,uint256 lastRewardBlock){
        UserInfo storage user = _userInfo[__account];
        rewards = user.rewards;
        lastRewardBlock = user.lastRewardBlock;
        uint256 countNfts = user.stakedNfts.length();
        if (countNfts == 0) {
            stakedNfts = new uint256[](0);
        } else {
            stakedNfts = new uint256[](countNfts);
            uint256 index;
            for (index = 0; index < countNfts; index++) {
                stakedNfts[index] = tokenOfOwnerByIndex(__account, index);
            }
        }
    }

    function tokenOfOwnerByIndex(address __account, uint256 __index)public view returns (uint256) {
        UserInfo storage user = _userInfo[__account];
        return user.stakedNfts.at(__index);
    }

    function userStakedNFTCount(address __account)public view returns (uint256) {
        UserInfo storage user = _userInfo[__account];
        return user.stakedNfts.length();
    }

    function updateMaxNftsPerUser(uint256 __maxLimit) external onlyOwner {
        require(__maxLimit > 0, "Invalid limit value");
        _maxNftsPerUser = __maxLimit;
    }

    function updateRewardTokenAddress(address __rewardTokenAddress)external onlyOwner {
        require(_startBlock > block.number, "Staking started already");
        IERC20(__rewardTokenAddress).balanceOf(address(this));
        emit RewardTokenUpdated(_rewardTokenAddress, __rewardTokenAddress);
        _rewardTokenAddress = __rewardTokenAddress;
    }

    function updateRewardPerBlock(uint256 __rewardPerBlock) external onlyOwner {
        require(__rewardPerBlock > 0, "Invalid reward per block");
        emit RewardPerBlockUpdated(_rewardPerBlock, __rewardPerBlock);
        _rewardPerBlock = __rewardPerBlock;
    }

    function updateStartBlock(uint256 __startBlock) external onlyOwner {
        require(
            __startBlock <= _endBlock,
            "Start block must be before end block"
        );
        require(__startBlock > block.number, "Start block must be after current block");
        require(_startBlock > block.number, "Staking started already");
        _startBlock = __startBlock;
    }

    function updateEndBlock(uint256 __endBlock) external onlyOwner {
        require(
            __endBlock >= _startBlock,
            "End block must be after start block"
        );
        require(
            __endBlock > block.number,
            "End block must be after current block"
        );
        _endBlock = __endBlock;
    }

    function isStaked(address __account, uint256 __tokenId) public view returns (bool){
        UserInfo storage user = _userInfo[__account];
        return user.stakedNfts.contains(__tokenId);
    }

    function pendingRewards(address __account) public view returns (uint256) {
        UserInfo storage user = _userInfo[__account];

        uint256 fromBlock = user.lastRewardBlock < _startBlock ? _startBlock : user.lastRewardBlock;
        uint256 toBlock = block.number < _endBlock ? block.number : _endBlock;
        if (toBlock < fromBlock) {
            return user.rewards;
        }

        uint256 amount = (toBlock - fromBlock) * userStakedNFTCount(__account) * _rewardPerBlock;

        return user.rewards + amount;
    }

    function stake(uint256[] memory tokenIdList) external nonReentrant whenNotPaused{
        require(
            IERC721(_stakeNftAddress).isApprovedForAll(
                _msgSender(),
                address(this)
            ),
            "Not approve nft to staker address"
        );
        require(
            userStakedNFTCount(_msgSender()) + tokenIdList.length <=
                _maxNftsPerUser,
            "Exceeds the max limit per user"
        );

        UserInfo storage user = _userInfo[_msgSender()];
        uint256 pendingAmount = pendingRewards(_msgSender());
        if (pendingAmount > 0) {
            uint256 amountSent = safeRewardTransfer(
                _msgSender(),
                pendingAmount
            );
            user.rewards = pendingAmount - amountSent;
            emit Harvested(_msgSender(), amountSent);
        }

        for (uint256 i = 0; i < tokenIdList.length; i++) {
            IERC721(_stakeNftAddress).safeTransferFrom(
                _msgSender(),
                address(this),
                tokenIdList[i]
            );

            user.stakedNfts.add(tokenIdList[i]);

            emit Staked(_msgSender(), tokenIdList[i]);
        }
        user.lastRewardBlock = block.number;
    }

    function withdraw(uint256[] memory tokenIdList) external nonReentrant {
        UserInfo storage user = _userInfo[_msgSender()];
        uint256 pendingAmount = pendingRewards(_msgSender());
        if (pendingAmount > 0) {
            uint256 amountSent = safeRewardTransfer(_msgSender(), pendingAmount);

            user.rewards = pendingAmount - amountSent;
            emit Harvested(_msgSender(), amountSent);
        }

        for (uint256 i = 0; i < tokenIdList.length; i++) {
            require(tokenIdList[i] > 0, "Invaild token id");

            require(
                isStaked(_msgSender(), tokenIdList[i]),
                "Not staked this nft"
            );

            IERC721(_stakeNftAddress).safeTransferFrom(
                address(this),
                _msgSender(),
                tokenIdList[i]
            );

            user.stakedNfts.remove(tokenIdList[i]);

            emit Withdrawn(_msgSender(), tokenIdList[i]);
        }
        user.lastRewardBlock = block.number;
    }

    function safeRewardTransfer(address __to, uint256 __amount) internal returns(uint256){
        uint256 balance = IERC20(_rewardTokenAddress).balanceOf(address(this));
        if (balance >= __amount) {
            IERC20(_rewardTokenAddress).transfer(__to, __amount);
            return __amount;
        }

        if (balance > 0) {
            IERC20(_rewardTokenAddress).transfer(__to, balance);
        }
        emit InsufficientRewardToken(__to, __amount, balance);
        return balance;
    }

    function onERC721Received(address,address,uint256,bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}