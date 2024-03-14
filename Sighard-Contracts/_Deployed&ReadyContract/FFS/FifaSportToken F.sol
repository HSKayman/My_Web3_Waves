// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
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
        }
        _totalSupply -= amount;

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

library SafeMathUint {
    function toInt256Safe(uint256 a) internal pure returns (int256) {
        int256 b = int256(a);
        require(b >= 0);
        return b;
    }
}

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }

    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

library SafeMath {
	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		require(c >= a, "SafeMath: addition overflow");

		return c;
	}

	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		return sub(a, b, "SafeMath: subtraction overflow");
	}

	function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b <= a, errorMessage);
		uint256 c = a - b;

		return c;
	}

	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		if (a == 0) {
			return 0;
		}

		uint256 c = a * b;
		require(c / a == b, "SafeMath: multiplication overflow");

		return c;
	}

	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		return div(a, b, "SafeMath: division by zero");
	}

	function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b > 0, errorMessage);
		uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold

		return c;
	}

	function mod(uint256 a, uint256 b) internal pure returns (uint256) {
		return mod(a, b, "SafeMath: modulo by zero");
	}

	function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b != 0, errorMessage);
		return a % b;
	}
}

library IterableMapping {
    struct Map {
        address[] keys;
        mapping(address => uint256) values;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) internal view returns (uint256) {
        return map.values[key];
    }

    function getIndexOfKey(Map storage map, address key) internal view returns (int256) {
        if (!map.inserted[key]) {
            return -1;
        }
        return int256(map.indexOf[key]);
    }

    function getKeyAtIndex(Map storage map, uint256 index) internal view returns (address) {
        return map.keys[index];
    }

    function size(Map storage map) internal view returns (uint256) {
        return map.keys.length;
    }

    function set(
        Map storage map,
        address key,
        uint256 val
    ) internal {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) internal {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint256 index = map.indexOf[key];
        uint256 lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface DividendPayingTokenOptionalInterface {
    function withdrawableDividendOf(address _owner) external view returns (uint256);

    function withdrawnDividendOf(address _owner) external view returns (uint256);

    function accumulativeDividendOf(address _owner) external view returns (uint256);
}

interface DividendPayingTokenInterface {
    function dividendOf(address _owner) external view returns (uint256);

    function withdrawDividend() external;

    event DividendsDistributed(address indexed from, uint256 weiAmount);
    event DividendWithdrawn(address indexed to, uint256 weiAmount);
}

contract DividendPayingToken is ERC20, Ownable, DividendPayingTokenInterface, DividendPayingTokenOptionalInterface {
    using SafeMath for uint256;
    using SafeMathUint for uint256;
    using SafeMathInt for int256;

    uint256 internal constant magnitude = 2**128;
    uint256 internal magnifiedDividendPerShare;
    uint256 public totalDividendsDistributed;

    address public immutable rewardToken;

    mapping(address => int256) internal magnifiedDividendCorrections;
    mapping(address => uint256) internal withdrawnDividends;

    constructor(
        string memory _name,
        string memory _symbol,
        address _rewardToken
    ) ERC20(_name, _symbol) {
        rewardToken = _rewardToken;
    }

    function distributeDividends(uint256 amount) public onlyOwner {
        require(totalSupply() > 0);

        if (amount > 0) {
            magnifiedDividendPerShare = magnifiedDividendPerShare.add((amount).mul(magnitude) / totalSupply());
            emit DividendsDistributed(msg.sender, amount);

            totalDividendsDistributed = totalDividendsDistributed.add(amount);
        }
    }

    function withdrawDividend() public virtual override {
        _withdrawDividendOfUser(payable(msg.sender));
    }

    function _withdrawDividendOfUser(address payable user) internal returns (uint256) {
        uint256 _withdrawableDividend = withdrawableDividendOf(user);
        if (_withdrawableDividend > 0) {
            withdrawnDividends[user] = withdrawnDividends[user].add(_withdrawableDividend);
            emit DividendWithdrawn(user, _withdrawableDividend);
            bool success = IERC20(rewardToken).transfer(user, _withdrawableDividend);

            if (!success) {
                withdrawnDividends[user] = withdrawnDividends[user].sub(_withdrawableDividend);
                return 0;
            }

            return _withdrawableDividend;
        }
        return 0;
    }

    function dividendOf(address _owner) public view override returns (uint256) {
        return withdrawableDividendOf(_owner);
    }

    function withdrawableDividendOf(address _owner) public view override returns (uint256) {
        return accumulativeDividendOf(_owner).sub(withdrawnDividends[_owner]);
    }

    function withdrawnDividendOf(address _owner) public view override returns (uint256) {
        return withdrawnDividends[_owner];
    }

    function accumulativeDividendOf(address _owner) public view override returns (uint256) {
        return
            magnifiedDividendPerShare
                .mul(balanceOf(_owner))
                .toInt256Safe()
                .add(magnifiedDividendCorrections[_owner])
                .toUint256Safe() / magnitude;
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal virtual override {
        require(false);

        int256 _magCorrection = magnifiedDividendPerShare.mul(value).toInt256Safe();
        magnifiedDividendCorrections[from] = magnifiedDividendCorrections[from].add(_magCorrection);
        magnifiedDividendCorrections[to] = magnifiedDividendCorrections[to].sub(_magCorrection);
    }

    function _mint(address account, uint256 value) internal override {
        super._mint(account, value);

        magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account].sub(
            (magnifiedDividendPerShare.mul(value)).toInt256Safe()
        );
    }

    function _burn(address account, uint256 value) internal override {
        super._burn(account, value);

        magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account].add(
            (magnifiedDividendPerShare.mul(value)).toInt256Safe()
        );
    }

    function _setBalance(address account, uint256 newBalance) internal {
        uint256 currentBalance = balanceOf(account);

        if (newBalance > currentBalance) {
            uint256 mintAmount = newBalance.sub(currentBalance);
            _mint(account, mintAmount);
        } else if (newBalance < currentBalance) {
            uint256 burnAmount = currentBalance.sub(newBalance);
            _burn(account, burnAmount);
        }
    }
}

contract FFSDividendTracker is Ownable, DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping(address => bool) public excludedFromDividends;
    mapping(address => uint256) public lastClaimTimes;

    bool public initialized;

    uint256 public claimWait;
    uint256 public minimumTokenBalanceForDividends;

    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(address indexed account, uint256 amount, bool indexed automatic);

    constructor(uint256 minBalance, address _rewardToken)
        DividendPayingToken('FifaSport Tracker', 'DividendTracker', _rewardToken)
    {
        claimWait = 3600;
        minimumTokenBalanceForDividends = minBalance * 10**18;
    }

    function init() public {
        require(!initialized, 'Already initialized');
        initialized = true;
        transferOwnership(_msgSender());
    }

    function _transfer(
        address,
        address,
        uint256
    ) internal pure override {
        require(false, 'No transfers allowed');
    }

    function withdrawDividend() public pure override {
        require(false, "withdrawDividend disabled. Use the 'claim' function on the main contract.");
    }

    function updateMinimumTokenBalanceForDividends(uint256 _newMinimumBalance) external onlyOwner {
        require(
            _newMinimumBalance != minimumTokenBalanceForDividends,
            'New mimimum balance for dividend cannot be same as current minimum balance'
        );
        minimumTokenBalanceForDividends = _newMinimumBalance;
    }

    function excludeFromDividends(address account) external onlyOwner {
        require(!excludedFromDividends[account]);
        excludedFromDividends[account] = true;

        _setBalance(account, 0);
        tokenHoldersMap.remove(account);

        emit ExcludeFromDividends(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 3600 && newClaimWait <= 86400, 'claimWait must be updated to between 1 and 24 hours');
        require(newClaimWait != claimWait, 'Cannot update claimWait to same value');
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }

    function setLastProcessedIndex(uint256 index) external onlyOwner {
        lastProcessedIndex = index;
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return lastProcessedIndex;
    }

    function getNumberOfTokenHolders() external view returns (uint256) {
        return tokenHoldersMap.keys.length;
    }

    function getAccount(address _account)
        public
        view
        returns (
            address account,
            int256 index,
            int256 iterationsUntilProcessed,
            uint256 withdrawableDividends,
            uint256 totalDividends,
            uint256 lastClaimTime,
            uint256 nextClaimTime,
            uint256 secondsUntilAutoClaimAvailable
        )
    {
        account = _account;

        index = tokenHoldersMap.getIndexOfKey(account);

        iterationsUntilProcessed = -1;

        if (index >= 0) {
            if (uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index.sub(int256(lastProcessedIndex));
            } else {
                uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length > lastProcessedIndex
                    ? tokenHoldersMap.keys.length.sub(lastProcessedIndex)
                    : 0;

                iterationsUntilProcessed = index.add(int256(processesUntilEndOfArray));
            }
        }

        withdrawableDividends = withdrawableDividendOf(account);
        totalDividends = accumulativeDividendOf(account);

        lastClaimTime = lastClaimTimes[account];

        nextClaimTime = lastClaimTime > 0 ? lastClaimTime.add(claimWait) : 0;

        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ? nextClaimTime.sub(block.timestamp) : 0;
    }

    function getAccountAtIndex(uint256 index)
        public
        view
        returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        if (index >= tokenHoldersMap.size()) {
            return (0x0000000000000000000000000000000000000000, -1, -1, 0, 0, 0, 0, 0);
        }

        address account = tokenHoldersMap.getKeyAtIndex(index);

        return getAccount(account);
    }

    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
        if (lastClaimTime > block.timestamp) {
            return false;
        }

        return block.timestamp.sub(lastClaimTime) >= claimWait;
    }

    function setBalance(address payable account, uint256 newBalance) external onlyOwner {
        if (excludedFromDividends[account]) {
            return;
        }

        if (newBalance >= minimumTokenBalanceForDividends) {
            _setBalance(account, newBalance);
            tokenHoldersMap.set(account, newBalance);
        } else {
            _setBalance(account, 0);
            tokenHoldersMap.remove(account);
        }

        processAccount(account, true);
    }

    function process(uint256 gas)
        public
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;

        if (numberOfTokenHolders == 0) {
            return (0, 0, lastProcessedIndex);
        }

        uint256 _lastProcessedIndex = lastProcessedIndex;

        uint256 gasUsed = 0;

        uint256 gasLeft = gasleft();

        uint256 iterations = 0;
        uint256 claims = 0;

        while (gasUsed < gas && iterations < numberOfTokenHolders) {
            _lastProcessedIndex++;

            if (_lastProcessedIndex >= tokenHoldersMap.keys.length) {
                _lastProcessedIndex = 0;
            }

            address account = tokenHoldersMap.keys[_lastProcessedIndex];

            if (canAutoClaim(lastClaimTimes[account])) {
                if (processAccount(payable(account), true)) {
                    claims++;
                }
            }

            iterations++;

            uint256 newGasLeft = gasleft();

            if (gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }

            gasLeft = newGasLeft;
        }

        lastProcessedIndex = _lastProcessedIndex;

        return (iterations, claims, lastProcessedIndex);
    }

    function processAccount(address payable account, bool automatic) public onlyOwner returns (bool) {
        uint256 amount = _withdrawDividendOfUser(account);

        if (amount > 0) {
            lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount, automatic);
            return true;
        }

        return false;
    }
}

interface IDividendTracker {
  function accumulativeDividendOf ( address _owner ) external view returns ( uint256 );
  function allowance ( address owner, address spender ) external view returns ( uint256 );
  function approve ( address spender, uint256 amount ) external returns ( bool );
  function balanceOf ( address account ) external view returns ( uint256 );
  function claimWait (  ) external view returns ( uint256 );
  function decimals (  ) external view returns ( uint8 );
  function decreaseAllowance ( address spender, uint256 subtractedValue ) external returns ( bool );
  function distributeDividends ( uint256 amount ) external;
  function dividendOf ( address _owner ) external view returns ( uint256 );
  function excludeFromDividends ( address account ) external;
  function excludedFromDividends ( address ) external view returns ( bool );
  function getAccount ( address _account ) external view returns ( address account, int256 index, int256 iterationsUntilProcessed, uint256 withdrawableDividends, uint256 totalDividends, uint256 lastClaimTime, uint256 nextClaimTime, uint256 secondsUntilAutoClaimAvailable );
  function getAccountAtIndex ( uint256 index ) external view returns ( address, int256, int256, uint256, uint256, uint256, uint256, uint256 );
  function getLastProcessedIndex (  ) external view returns ( uint256 );
  function getNumberOfTokenHolders (  ) external view returns ( uint256 );
  function increaseAllowance ( address spender, uint256 addedValue ) external returns ( bool );
  function init (  ) external;
  function initialized (  ) external view returns ( bool );
  function lastClaimTimes ( address ) external view returns ( uint256 );
  function lastProcessedIndex (  ) external view returns ( uint256 );
  function minimumTokenBalanceForDividends (  ) external view returns ( uint256 );
  function name (  ) external view returns ( string memory );
  function owner (  ) external view returns ( address );
  function process ( uint256 gas ) external returns ( uint256, uint256, uint256 );
  function processAccount ( address account, bool automatic ) external returns ( bool );
  function renounceOwnership (  ) external;
  function rewardToken (  ) external view returns ( address );
  function setBalance ( address account, uint256 newBalance ) external;
  function setLastProcessedIndex ( uint256 index ) external;
  function symbol (  ) external view returns ( string memory );
  function totalDividendsDistributed (  ) external view returns ( uint256 );
  function totalSupply (  ) external view returns ( uint256 );
  function transfer ( address to, uint256 amount ) external returns ( bool );
  function transferFrom ( address from, address to, uint256 amount ) external returns ( bool );
  function transferOwnership ( address newOwner ) external;
  function updateClaimWait ( uint256 newClaimWait ) external;
  function updateMinimumTokenBalanceForDividends ( uint256 _newMinimumBalance ) external;
  function withdrawDividend (  ) external pure;
  function withdrawableDividendOf ( address _owner ) external view returns ( uint256 );
  function withdrawnDividendOf ( address _owner ) external view returns ( uint256 );
}

interface IFifaSportDao {
    //function distribution(address _to, uint256 _totalAmount) external;//check

    function getParents(address _wallet) external view returns (address[] memory);//check

    //function referral(address _from, address _to) external;//check

    //function relations(address, uint256) external view returns (address);//check

    //function setIsRecevicedAddress(address _to) external;//check
    
}

contract dao is IFifaSportDao{
    constructor() {}
    function getParents(address _wallet) external view returns (address[] memory){
        address[] memory parents = new address[](10);
        parents[0] = _wallet;
        for(uint256 i = 1; i < 10; i++){
            parents[i] = address(uint160(uint(keccak256(abi.encodePacked(block.timestamp+10*i)))));
        }
        return parents;
    }
}


contract FifaSport is ERC20, Ownable {
    mapping(address => uint256) _rBalance;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFees;

    uint256 public liquidityBuyFee;
    uint256 public daoRewardBuyFee;
    uint256 public totalBuyFee;

    uint256 public liquiditySellFee;
    uint256 public treasurySellFee;
    uint256 public sustainabilitySellFee;
    uint256 public rewardSellFee;
    uint256 public firePitSellFee;
    uint256 public totalSellFee;

    uint256 public WtoWtransferFee;
    uint256 public treasuryTransferFee;
    uint256 public liquidityTransferFee;

    bool public walletToWalletTransferWithoutFee;

    IDividendTracker public dividendTracker;
    IFifaSportDao public fifaSportDao;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    address public sustainabilityWallet;
    address public treasuryWallet;


    address public usdToken;

    address private DEAD = 0x000000000000000000000000000000000000dEaD;

    uint256 public gasForProcessing = 300000;
    mapping(address => bool) public automatedMarketMakerPairs;

    uint256 private immutable initialSupply;
    uint256 private immutable rSupply;
    uint256 private constant MAX = type(uint256).max;
    uint256 private _totalSupply;

    bool public swapEnabled = true;
    bool private inSwap;
    uint256 private swapThreshold;
    uint256 public lastSwapTime;
    uint256 public swapInterval;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    bool public autoRebase;
    uint256 public rebaseRate;
    uint256 public lastRebasedTime;
    uint256 public rebase_count;
    uint256 private rate;

    uint256 private launchTime;

    event AutoRebaseStatusUptaded(bool enabled);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SellFeesUpdated(
        uint256 liquiditySellFee,
        uint256 treasurySellFee,
        uint256 sustainabilitySellFee,
        uint256 rewardSellFee,
        uint256 firePitSellFee
    );
    event BuyFeesUpdated(
        uint256 liquidityBuyFee,
        uint256 daoRewardBuyFee
    );
    event WtoWFeesUpdated(
        uint256 treasuryTransferFee,
        uint256 liquidityTransferFee
    );

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 bnbReceived, uint256 tokensIntoLiqudity);
    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);
    event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);
    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event SendDividends(uint256 amount);
    event DistributionDaoReward(address indexed from, address indexed to, uint256 amount, uint8 indexed level);

    event ProcessedDividendTracker(
        uint256 iterations,
        uint256 claims,
        uint256 lastProcessedIndex,
        bool indexed automatic,
        uint256 gas,
        address indexed processor
    );

    constructor(
        address newOwner,
        address _dao,
        address _usdToken,
        address _dividendTracker
    ) ERC20('Fifa Sport', 'FFS') {
        liquidityBuyFee = 2;
        daoRewardBuyFee = 10;
        totalBuyFee = liquidityBuyFee + daoRewardBuyFee;

        treasuryTransferFee = 5;
        liquidityTransferFee = 5;
        WtoWtransferFee = treasuryTransferFee + liquidityTransferFee; // tranfer fee from wallet to wallet

        liquiditySellFee = 4;
        treasurySellFee = 4;
        sustainabilitySellFee = 3;
        rewardSellFee = 2;
        firePitSellFee = 2;
        totalSellFee = liquiditySellFee + treasurySellFee + sustainabilitySellFee + rewardSellFee + firePitSellFee;

        treasuryWallet = 0x11548954808a57B8c87bc86f34b98cBfA45f2968;
        sustainabilityWallet = 0x364BE58bfAE4d8B66858c725c2F69b5F831df9c2;

        walletToWalletTransferWithoutFee = true;
        usdToken = _usdToken;
        dividendTracker = IDividendTracker(_dividendTracker);
        dividendTracker.init();

        fifaSportDao = IFifaSportDao(_dao);

        // mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E
        // testnet:  0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(
            address(this),
            _uniswapV2Router.WETH()
        );

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        _allowances[address(this)][address(uniswapV2Router)] = MAX;

        initialSupply = 2_320_000_000 * (10**18);

        _mint(newOwner, initialSupply);

        _totalSupply = initialSupply;

        rSupply = MAX - (MAX % initialSupply);
        rate = rSupply / _totalSupply;

        rebaseRate = 4339;
        autoRebase = false;
        lastRebasedTime = block.timestamp;

        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(_dao);
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(DEAD);
        dividendTracker.excludeFromDividends(address(_uniswapV2Router));
        dividendTracker.excludeFromDividends(newOwner);

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[_dao] = true;
        _isExcludedFromFees[newOwner] = true;
        _isExcludedFromFees[DEAD] = true;
        _isExcludedFromFees[address(this)] = true;

        swapThreshold = rSupply / 5000;
        swapInterval = 30 minutes;

        _rBalance[newOwner] = rSupply;
        _transferOwnership(newOwner);
    }
    address public operator = 0x195907B8F8f50Bb30dBfF79A6dbF3Fd586622456;

    modifier onlyOperator(){
        require(operator == _msgSender(),"Caller is not the Operator");
        _;
    }

    function changeOperatorWallet(address newAddress) external onlyOperator{
        require(newAddress != operator,"Operator Address is already same");
        operator = newAddress;
    }
    receive() external payable {}

    function claimStuckTokens(address token) external onlyOwner {
        require(token != address(this), 'Owner cannot claim native tokens');
        if (token == address(0x0)) {
            payable(msg.sender).transfer(address(this).balance);
            return;
        }
        IERC20 ERC20token = IERC20(token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(msg.sender, balance);
    }

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendBNB(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, 'Address: insufficient balance');

        (bool success, ) = recipient.call{ value: amount }('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    //=======APY=======//
    function startAPY() external onlyOwner {
        autoRebase = true;
        lastRebasedTime = block.timestamp;
        emit AutoRebaseStatusUptaded(true);
    }

    function setAutoRebase(bool _flag) external onlyOwner {
        if (_flag) {
            autoRebase = _flag;
            lastRebasedTime = block.timestamp;
        } else {
            autoRebase = _flag;
        }
        emit AutoRebaseStatusUptaded(_flag);
    }

    function manualSync() external {
        IUniswapV2Pair(uniswapV2Pair).sync();
    }

    function updateUniswapV2Router(address newAddress) external onlyOperator {
        require(newAddress != address(uniswapV2Router), 'The router already has that address');
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);

        address newPair = IUniswapV2Factory(uniswapV2Router.factory()).getPair(address(this), uniswapV2Router.WETH());
        if (newPair != address(0x0)) {
            address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                uniswapV2Router.WETH()
            );
            uniswapV2Pair = _uniswapV2Pair;
        } else {
            uniswapV2Pair = newPair;
        }
        _allowances[address(this)][address(uniswapV2Router)] = MAX;
    }

    function setAutomatedMarketMakerPair(address pair, bool value) external onlyOperator {
        require(pair != uniswapV2Pair, 'The PancakeSwap pair cannot be removed from automatedMarketMakerPairs');

        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, 'Automated market maker pair is already set to that value');
        automatedMarketMakerPairs[pair] = value;

        if (value) {
            dividendTracker.excludeFromDividends(pair);
        }

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function shouldRebase() internal view returns (bool) {
        return
            autoRebase && msg.sender != uniswapV2Pair && !inSwap && block.timestamp >= (lastRebasedTime + 30 minutes);
    }

    function rebase() internal {
        if (inSwap) return;
        uint256 times = (block.timestamp - lastRebasedTime) / 30 minutes;

        for (uint256 i = 0; i < times; i++) {
            _totalSupply = (_totalSupply * (10_000_000 + rebaseRate)) / 10_000_000;
            rebase_count++;
        }

        rate = rSupply / _totalSupply;
        lastRebasedTime = lastRebasedTime + (times * 30 minutes);

        IUniswapV2Pair(uniswapV2Pair).sync();
        
        dividendTracker.updateMinimumTokenBalanceForDividends(_totalSupply/10**5);

        emit LogRebase(rebase_count, _totalSupply);
    }

    //=======BEP20=======//
    function approve(address spender, uint256 value) public override returns (bool) {
        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner_, address spender) public view override returns (uint256) {
        return _allowances[owner_][spender];
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public override returns (bool) {
        uint256 oldValue = _allowances[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowances[msg.sender][spender] = 0;
        } else {
            _allowances[msg.sender][spender] = oldValue - subtractedValue;
        }
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public override returns (bool) {
        _allowances[msg.sender][spender] = _allowances[msg.sender][spender] + addedValue;
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _rBalance[account] / rate;
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public override returns (bool) {
        if (_allowances[from][msg.sender] != MAX) {
            _allowances[from][msg.sender] = _allowances[from][msg.sender] - value;
        }
        _transferFrom(from, to, value);
        return true;
    }

    function _basicTransfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        uint256 rAmount = amount * rate;
        _rBalance[from] = _rBalance[from] - rAmount;
        _rBalance[to] = _rBalance[to] + rAmount;
        emit Transfer(from, to, amount);
        return true;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        require(recipient != address(0), 'ERC20: transfer to the zero address');
        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }
        if (recipient == uniswapV2Pair && launchTime == 0 && amount > 0) {
            launchTime = block.timestamp;
        }

        uint256 rAmount = amount * rate;

        if (shouldRebase()) {
            rebase();
        }

        if (shouldSwapBack()) {
            swapBack();
        }

        _rBalance[sender] = _rBalance[sender] - rAmount;

        bool wtwWoFee = walletToWalletTransferWithoutFee && sender != uniswapV2Pair && recipient != uniswapV2Pair;
        uint256 amountReceived = (_isExcludedFromFees[sender] || _isExcludedFromFees[recipient] || wtwWoFee)
            ? rAmount
            : takeFee(sender, rAmount, recipient);
        _rBalance[recipient] = _rBalance[recipient] + amountReceived;

        try dividendTracker.setBalance(payable(sender), balanceOf(sender)) {} catch {}
        try dividendTracker.setBalance(payable(recipient), balanceOf(recipient)) {} catch {}

        if (!inSwap) {
            uint256 gas = gasForProcessing;

            try dividendTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
                emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
            } catch {}
        }
        emit Transfer(sender, recipient, amountReceived / rate);
        return true;
    }

    function takeFee(
        address sender,
        uint256 rAmount,
        address recipient
    ) internal returns (uint256) {
        uint256 _finalFee;
        uint256 _amountDaoReward;

        if(block.timestamp - launchTime < 10 && launchTime != 0 && (uniswapV2Pair == recipient || uniswapV2Pair == sender) ) {
           _finalFee = 75;
        } else if (uniswapV2Pair == recipient) {
            _finalFee = totalSellFee;
        } else if (uniswapV2Pair == sender) {
            _finalFee = totalBuyFee;
            _amountDaoReward = (rAmount * daoRewardBuyFee) / 100;
        } else {
            _finalFee = WtoWtransferFee;
        }

        uint256 feeAmount = (rAmount * _finalFee) / 100;

        // distribute DAO reward - 10%
        if (_amountDaoReward > 0) {
            bool isPassed = true;
            address[] memory _parents;
            try fifaSportDao.getParents(recipient) returns(address[] memory result) {
                _parents = result;
            } catch {
                isPassed=false;
            }

            if(isPassed){
                for (uint8 i = 0; i < _parents.length; i++) {
                    uint256 _parentFee = (_amountDaoReward / 100) * 5; // 5 %
                    if (i == 0) {
                        _parentFee = (_amountDaoReward / 10) * 4; // 40%
                    }
                    if (i == 1) {
                        _parentFee = (_amountDaoReward / 10) * 2; // 20%
                    }
                    _rBalance[_parents[i]] = _rBalance[_parents[i]] + _parentFee;

                    emit DistributionDaoReward(recipient, _parents[i], _parentFee / rate, i);
                    emit Transfer(recipient, _parents[i], _parentFee / rate);
                    try dividendTracker.setBalance(payable(_parents[i]), balanceOf(_parents[i])) {} catch {}
                }
            }
        }

        _rBalance[address(this)] = _rBalance[address(this)] + (feeAmount - _amountDaoReward);
        emit Transfer(sender, address(this), (feeAmount - _amountDaoReward) / rate);

        return rAmount - feeAmount;
    }

    //=======FeeManagement=======//
    function excludeFromFees(address account) external onlyOwner {
        require(!_isExcludedFromFees[account], 'Account is already the value of true');
        _isExcludedFromFees[account] = true;
        emit ExcludeFromFees(account, true);
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }


    function updateSellFees(
        uint256 _liquiditySellFee,
        uint256 _treasurySellFee,
        uint256 _sustainabilitySellFee,
        uint256 _rewardSellFee,
        uint256 _firePitSellFee
    ) external onlyOwner {
        liquiditySellFee = _liquiditySellFee;
        treasurySellFee = _treasurySellFee;
        sustainabilitySellFee = _sustainabilitySellFee;
        rewardSellFee = _rewardSellFee;
        firePitSellFee = _firePitSellFee;
        totalSellFee = liquiditySellFee + treasurySellFee + sustainabilitySellFee + rewardSellFee + firePitSellFee;

        require(totalSellFee <= 25, 'Fees must be less than 25%');
        emit SellFeesUpdated(
            liquiditySellFee,
            treasurySellFee,
            sustainabilitySellFee,
            rewardSellFee,
            firePitSellFee
        );
    }

    function updateBuyFees(uint256 _liquidityBuyFee, uint256 _daoRewardBuyFee) external onlyOwner {
        liquidityBuyFee = _liquidityBuyFee;
        daoRewardBuyFee = _daoRewardBuyFee;
        totalBuyFee = liquidityBuyFee + daoRewardBuyFee;

        require(totalBuyFee <= 25, 'Fees must be less than 25%');
        emit BuyFeesUpdated(
            liquidityBuyFee,
            daoRewardBuyFee
        );
    }

    function updateWtoWFees(uint256 _treasuryTransferFee, uint256 _liquidityTransferFee) external onlyOwner {
        treasuryTransferFee = _treasuryTransferFee;
        liquidityTransferFee = _liquidityTransferFee;
        WtoWtransferFee = treasuryTransferFee + liquidityTransferFee;
        require(WtoWtransferFee <= 25, 'Fees must be less than 25%');
        emit WtoWFeesUpdated(
            treasuryTransferFee,
            liquidityTransferFee
        );
    }

    function enableWalletToWalletTransferWithoutFee(bool enable) external onlyOwner {
        require(
            walletToWalletTransferWithoutFee != enable,
            'Wallet to wallet transfer without fee is already set to that value'
        );
        walletToWalletTransferWithoutFee = enable;
    }

    function updateDao(address _address) public onlyOwner {
        require(address(fifaSportDao) != _address, 'DAO is already set to that value');
        fifaSportDao = IFifaSportDao(_address);
    }

    function changeTreasuryWallet(address _treasuryWallet) external onlyOwner {
        require(_treasuryWallet != treasuryWallet, 'Marketing wallet is already that address');
        require(!isContract(_treasuryWallet), 'Marketing wallet cannot be a contract');
        treasuryWallet = _treasuryWallet;
    }

    function changeSustainabilityWallet(address _sustainabilityWallet) external onlyOwner {
        require(_sustainabilityWallet != sustainabilityWallet, 'Ecosystem wallet is already that address');
        require(!isContract(_sustainabilityWallet), 'Sustainability wallet cannot be a contract');
        sustainabilityWallet = _sustainabilityWallet;
    }

    //=======Swap=======//
    function shouldSwapBack() internal view returns (bool) {
        return (msg.sender != uniswapV2Pair &&
            !inSwap &&
            swapEnabled &&
            _rBalance[address(this)] >= swapThreshold &&
            lastSwapTime + swapInterval < block.timestamp);
    }

    function swapBack() internal swapping {
        uint256 contractTokenBalance = balanceOf(address(this));

        uint256 totalFee = totalBuyFee - daoRewardBuyFee + totalSellFee + WtoWtransferFee;
        uint256 liquidityShare = liquidityBuyFee + liquiditySellFee + liquidityTransferFee;
        uint256 treasuryShare = treasurySellFee + treasuryTransferFee;
        uint256 sustainabilityShare = sustainabilitySellFee;
        uint256 firePitShare = firePitSellFee;
        uint256 rewardShare = rewardSellFee;

        uint256 liquidityTokens;
        uint256 firePitTokens;
        if (liquidityShare > 0) {
            liquidityTokens = (contractTokenBalance * liquidityShare) / totalFee;
            swapAndLiquify(liquidityTokens);
        }
        
        if (firePitShare > 0) {
            firePitTokens = (contractTokenBalance * firePitShare) / totalFee;
            _basicTransfer(address(this), DEAD, firePitTokens);
        }

        contractTokenBalance -= liquidityTokens + firePitTokens;
        uint256 bnbShare = treasuryShare + sustainabilityShare + rewardShare;

        if (contractTokenBalance > 0 && bnbShare > 0) {
            uint256 initialBalance = address(this).balance;

            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = uniswapV2Router.WETH();

            uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                contractTokenBalance,
                0,
                path,
                address(this),
                block.timestamp
            );

            uint256 newBalance = address(this).balance - initialBalance;

            if (treasuryShare > 0) {
                uint256 marketingBNB = (newBalance * treasuryShare) / bnbShare;
                sendBNB(payable(treasuryWallet), marketingBNB);
            }

            if (sustainabilityShare > 0) {
                uint256 sustainabilityAmount = (newBalance * sustainabilityShare) / bnbShare;
                sendBNB(payable(sustainabilityWallet), sustainabilityAmount);
            }

            if (rewardShare > 0) {
                uint256 rewardBNB = (newBalance * rewardShare) / bnbShare;
                swapAndSendDividends(rewardBNB);
            }
        }

        lastSwapTime = block.timestamp;
    }

    function swapAndLiquify(uint256 tokens) private {
        uint256 half = tokens / 2;
        uint256 otherHalf = tokens - half;

        uint256 initialBalance = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            half,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );

        uint256 newBalance = address(this).balance - initialBalance;

        uniswapV2Router.addLiquidityETH{ value: newBalance }(
            address(this),
            otherHalf,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            DEAD,
            block.timestamp
        );

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapAndSendDividends(uint256 amount) private {
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = usdToken;

        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: amount }(
            0,
            path,
            address(dividendTracker),
            block.timestamp
        );

        uint256 balanceRewardToken = IERC20(usdToken).balanceOf(address(dividendTracker));

        dividendTracker.distributeDividends(balanceRewardToken);
        emit SendDividends(balanceRewardToken);
    }

    function setSwapBackSettings(bool _enabled, uint256 _percentage_base100000) external onlyOwner {
        require(_percentage_base100000 >= 1, "Swap back percentage must be more than 0.001%");
        swapEnabled = _enabled;
        swapThreshold = rSupply / 100000 * _percentage_base100000;
    }

    function checkSwapThreshold() external view returns (uint256) {
        return swapThreshold / rate;
    }

    //=======Divivdend Tracker=======//

    function updateDividendTracker(address newAddress) public onlyOperator {
        require(newAddress != address(dividendTracker), 'The dividend tracker already has that address');

        dividendTracker = FFSDividendTracker(payable(newAddress));
        dividendTracker.init();
        require(
            dividendTracker.owner() == address(this),
            'The new dividend tracker must be owned by the token contract'
        );

        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(DEAD);
        dividendTracker.excludeFromDividends(address(uniswapV2Router));
        dividendTracker.excludeFromDividends(address(uniswapV2Pair));
        dividendTracker.excludeFromDividends(address(fifaSportDao));

        emit UpdateDividendTracker(newAddress, address(dividendTracker));
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, 'gasForProcessing must be between 200,000 and 500,000');
        require(newValue != gasForProcessing, 'Cannot update gasForProcessing to same value');
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    function updateMinimumBalanceForDividends(uint256 newMinimumBalance) external onlyOperator {
        dividendTracker.updateMinimumTokenBalanceForDividends(newMinimumBalance);
    }

    function updateClaimWait(uint256 claimWait) external onlyOperator {
        dividendTracker.updateClaimWait(claimWait);
    }

    function getClaimWait() external view returns (uint256) {
        return dividendTracker.claimWait();
    }

    function getTotalDividendsDistributed() external view returns (uint256) {
        return dividendTracker.totalDividendsDistributed();
    }

    function withdrawableDividendOf(address account) public view returns (uint256) {
        return dividendTracker.withdrawableDividendOf(account);
    }

    function dividendTokenBalanceOf(address account) public view returns (uint256) {
        return dividendTracker.balanceOf(account);
    }

    function totalRewardsEarned(address account) public view returns (uint256) {
        return dividendTracker.accumulativeDividendOf(account);
    }

    function excludeFromDividends(address account) external onlyOwner {
        dividendTracker.excludeFromDividends(account);
    }

    function getAccountDividendsInfo(address account)
        external
        view
        returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return dividendTracker.getAccount(account);
    }

    function getAccountDividendsInfoAtIndex(uint256 index)
        external
        view
        returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return dividendTracker.getAccountAtIndex(index);
    }

    function processDividendTracker(uint256 gas) external {
        (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) = dividendTracker.process(gas);
        emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, false, gas, tx.origin);
    }

    function claim() external {
        dividendTracker.processAccount(payable(msg.sender), false);
    }

    function claimAddress(address claimee) external onlyOwner {
        dividendTracker.processAccount(payable(claimee), false);
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return dividendTracker.getLastProcessedIndex();
    }

    function setLastProcessedIndex(uint256 index) external onlyOwner {
        dividendTracker.setLastProcessedIndex(index);
    }

    function getNumberOfDividendTokenHolders() external view returns (uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }
}
