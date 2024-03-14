// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

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

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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

abstract contract ReentrancyGuard {

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

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}

interface IERC20Metadata is IERC20 {
	function name() external view returns (string memory);
	function symbol() external view returns (string memory);
	function decimals() external view returns (uint8);
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

interface IPoolConfiguration {

  function getOptimalUtilizationRate() external view returns (uint256);
  function getBaseBorrowRate() external view returns (uint256);
  function getLiquidationBonusPercent() external view returns (uint256);
  function getCollateralPercent() external view returns (uint256);
  function calculateInterestRate(uint256 _totalBorrows, uint256 _totalLiquidity)external view returns (uint256 borrowInterestRate);
  function getUtilizationRate(uint256 _totalBorrows, uint256 _totalLiquidity) external view returns (uint256 utilizationRate);
}

interface IPriceOracle {
  function getAssetPrice(address _asset) external view returns (uint256);
}

interface ILendingPool {
  function isAccountHealthy(address _account) external view returns (bool);
}

contract TokenDeployer {
  function createNewToken(string memory _name, string memory _symbol, ERC20 _underlyingAsset) public returns (TokenTracker) {
    TokenTracker token = new TokenTracker(_name, _symbol, ILendingPool(msg.sender), _underlyingAsset);
    token.transferOwnership(msg.sender);
    return token;
  }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
	using SafeMath for uint256;

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
		_transfer(sender, recipient, amount);
		_approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
		return true;
	}

	function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
		_approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
		return true;
	}

	function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
		_approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
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
		_balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
		_balances[recipient] = _balances[recipient].add(amount);
		emit Transfer(sender, recipient, amount);
	}

	function _mint(address account, uint256 amount) internal virtual {
		require(account != address(0), "ERC20: mint to the zero address");
		_beforeTokenTransfer(address(0), account, amount);
		_totalSupply = _totalSupply.add(amount);
		_balances[account] = _balances[account].add(amount);
		emit Transfer(address(0), account, amount);
	}

	function _burn(address account, uint256 amount) internal virtual {
		require(account != address(0), "ERC20: burn from the zero address");
		_beforeTokenTransfer(account, address(0), amount);
		_balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
		_totalSupply = _totalSupply.sub(amount);
		emit Transfer(account, address(0), amount);
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
}

contract TokenTracker is ERC20, Ownable, ReentrancyGuard {

    ILendingPool private lendingPool;
    ERC20 public underlyingAsset;

    constructor(string memory _name, string memory _symbol, ILendingPool _lendingPoolAddress, ERC20 _underlyingAsset) ERC20(_name, _symbol) {
        lendingPool = _lendingPoolAddress;
        underlyingAsset = _underlyingAsset;
    }

    function mint(address _account, uint256 _amount) external onlyOwner {
        _mint(_account, _amount);
    }

    function burn(address _account, uint256 _amount) external onlyOwner {
        _burn(_account, _amount);
    }

    function _transfer(address _from, address _to, uint256 _amount) internal override {
        super._transfer(_from, _to, _amount);
        require(lendingPool.isAccountHealthy(_from), "Transfer tokens is not allowed");
    }
}


contract LendingPool is Ownable, ReentrancyGuard{

    struct UserPoolData {
        bool disableUseAsCollateral;
        uint256 borrowShares;     
    }

    struct Pool {
        bool status;
        TokenTracker tokenTracker;
        IPoolConfiguration poolConfig;
        uint256 totalBorrows;
        uint256 totalBorrowShares;
        uint256 poolReserves;
        uint256 lastUpdateTimestamp;
    }

    IPriceOracle priceOracle;
    TokenDeployer public tokenDeployer;
    ERC20[] public tokenList;
    mapping(address => Pool) public pools;
    mapping(address => mapping(address => UserPoolData)) public userPoolData;

    uint256 public constant CLOSE_FACTOR = 0.5 * 1e18;
    uint256 public constant EQUILIBRIUM = 0.5 * 1e18;
    uint256 public constant MAX_UTILIZATION_RATE = 1 * 1e18;
    uint256 public reservePercent = 0.05 * 1e18;

    constructor(TokenDeployer _tokenDeployer) {
        tokenDeployer = _tokenDeployer;
    }

    event Deposit(
        address indexed pool,
        address indexed user,
        uint256 depositShares,
        uint256 depositAmount
    );
    event Borrow(
        address indexed pool,
        address indexed user,
        uint256 borrowShares,
        uint256 borrowAmount
    );
    event Withdraw(
        address indexed pool,
        address indexed user,
        uint256 withdrawShares,
        uint256 withdrawAmount
    );
    event Liquidate(
        address indexed user,
        address pool,
        address collateral,
        uint256 liquidateAmount,
        uint256 liquidateShares,
        uint256 collateralAmount,
        uint256 collateralShares,
        address liquidator
    );
    event PoolInitialized(
        address indexed pool,
        address indexed alTokenAddress,
        address indexed poolConfigAddress
    );
    event PoolConfigUpdated(address indexed pool, address poolConfigAddress);
    event PoolPriceOracleUpdated(address indexed priceOracleAddress);
    event Repay(address indexed pool, address indexed user, uint256 repayShares, uint256 repayAmount);
    event ReserveWithdrawn(address indexed pool, uint256 amount, address withdrawer);
    event ReservePercentUpdated(uint256 previousReservePercent, uint256 newReservePercent);
    event PoolInterestUpdated(
        address indexed pool,
        uint256 cumulativeBorrowInterest,
        uint256 totalBorrows
    );

    modifier updatePoolWithInterestsAndTimestamp(ERC20 _token) {
        Pool storage pool = pools[address(_token)];
        uint256 borrowInterestRate = pool.poolConfig.calculateInterestRate(
        pool.totalBorrows,
        getTotalLiquidity(_token)
        );
        uint256 cumulativeBorrowInterest = calculateLinearInterest(
        borrowInterestRate,
        pool.lastUpdateTimestamp,
        block.timestamp
        );

        uint256 previousTotalBorrows = pool.totalBorrows;
        pool.totalBorrows = (cumulativeBorrowInterest * pool.totalBorrows) / 1e18;
        pool.poolReserves = pool.poolReserves + ((pool.totalBorrows - previousTotalBorrows) * reservePercent) / 1e18;
        pool.lastUpdateTimestamp = block.timestamp;
        emit PoolInterestUpdated(address(_token), cumulativeBorrowInterest, pool.totalBorrows);
        _;
    }
    
    function getTotalLiquidity(ERC20 _token) public view returns (uint256) {
        Pool storage pool = pools[address(_token)];
        return pool.totalBorrows + _token.balanceOf(address(this)) - pool.poolReserves;
    }

//---------- Pool Process ----------\\
    function initPool(ERC20 _token, IPoolConfiguration _poolConfig) external onlyOwner {
        for (uint256 i = 0; i < tokenList.length; i++) {
        require(tokenList[i] != _token, "this pool already exists on lending pool");
        }
        string memory TokenSymbol = string(abi.encodePacked("TT", _token.symbol()));
        string memory TokenName = string(abi.encodePacked("TT", _token.symbol()));
        TokenTracker token = tokenDeployer.createNewToken(TokenName, TokenSymbol, _token);
        Pool memory pool = Pool(
        false,
        token,
        _poolConfig,
        0,
        0,
        0,
        block.timestamp);
        pools[address(_token)] = pool;
        tokenList.push(_token);
        emit PoolInitialized(address(_token), address(token), address(_poolConfig));
    }

    function setPoolConfig(ERC20 _token, IPoolConfiguration _poolConfig) external onlyOwner {
        Pool storage pool = pools[address(_token)];
        require(
            address(pool.tokenTracker) != address(0),
            "pool isn't initialized, can't set the pool config"
        );
        pool.poolConfig = _poolConfig;
        emit PoolConfigUpdated(address(_token), address(_poolConfig));
    }

    function setPoolStatus(ERC20 _token, bool _status) external onlyOwner {
        Pool storage pool = pools[address(_token)];
        pool.status = _status;
    }

    function setPriceOracle(IPriceOracle _oracle) external onlyOwner {
        priceOracle = _oracle;
        emit PoolPriceOracleUpdated(address(_oracle));
    }

//---------- Some Getters ----------\\
    function calculateLinearInterest(uint256 _rate, uint256 _fromTimestamp, uint256 _toTimestamp) internal pure returns (uint256) {
        return
        (((_rate * _toTimestamp) / 1e18 - _fromTimestamp) * 1e18) / 365 days + 1e18;
    }
    
    function getUserPoolData(address _user, ERC20 _token) public view returns (
        uint256 compoundedLiquidityBalance,
        uint256 compoundedBorrowBalance,
        bool userUsePoolAsCollateral
        )
    {
        compoundedLiquidityBalance = getUserCompoundedLiquidityBalance(_user, _token);
        compoundedBorrowBalance = getUserCompoundedBorrowBalance(_user, _token);
        userUsePoolAsCollateral = !userPoolData[_user][address(_token)].disableUseAsCollateral;
    }

    function getUserCompoundedBorrowBalance(address _user, ERC20 _token) public view returns (uint256){
        uint256 userBorrowShares = userPoolData[_user][address(_token)].borrowShares;
        return calculateRoundUpBorrowAmount(_token, userBorrowShares);
    }

    function getUserCompoundedLiquidityBalance(address _user, ERC20 _token) public  view returns (uint256){
        Pool storage pool = pools[address(_token)];
        uint256 userLiquidityShares = pool.tokenTracker.balanceOf(_user);
        return calculateRoundDownLiquidityAmount(_token, userLiquidityShares);
    }

//---------- Deposit ----------\\
    function deposit(ERC20 _token, uint256 _amount) external nonReentrant updatePoolWithInterestsAndTimestamp(_token){
        Pool storage pool = pools[address(_token)];
        require(pool.status, "can't deposit to this pool");
        require(_amount > 0, "deposit amount should more than 0");

        uint256 shareAmount = calculateRoundDownLiquidityShareAmount(_token, _amount);

        pool.tokenTracker.mint(msg.sender, shareAmount);//Think
        _token.transferFrom(msg.sender, address(this), _amount);

        emit Deposit(address(_token), msg.sender, shareAmount, _amount);
    }

//---------- Borrow ----------\\
    function borrow(ERC20 _token, uint256 _amount) external nonReentrant updatePoolWithInterestsAndTimestamp(_token) {
        Pool storage pool = pools[address(_token)];
        UserPoolData storage userData = userPoolData[msg.sender][address(_token)];
        require(pool.status, "can't borrow this pool");
        require(_amount > 0, "borrow amount should more than 0");
        require(_amount <= _token.balanceOf(address(this)),"amount is more than available liquidity on pool");

        uint256 borrowShare = calculateRoundUpBorrowShareAmount(_token, _amount);

        pool.totalBorrows = pool.totalBorrows + _amount;
        pool.totalBorrowShares = pool.totalBorrowShares + borrowShare;

        userData.borrowShares = userData.borrowShares + borrowShare;
        _token.transfer(msg.sender, _amount);

        require(isAccountHealthy(msg.sender), "account is not healthy. can't borrow");
        emit Borrow(address(_token), msg.sender, borrowShare, _amount);
    }

//---------- Calculate Borrow Up Down and Amount ----------\\
    function calculateRoundUpBorrowShareAmount(ERC20 _token, uint256 _amount) internal view returns (uint256){
        Pool storage pool = pools[address(_token)];

        if (pool.totalBorrows == 0 || pool.totalBorrowShares == 0) {
            return _amount;
        }else if((_amount * pool.totalBorrowShares) % pool.totalBorrows!= 0){
            return 1 + (_amount * pool.totalBorrowShares) / pool.totalBorrows;
        }else{
            return (_amount * pool.totalBorrowShares) / pool.totalBorrows;
        }
    }

    function calculateRoundDownBorrowShareAmount(ERC20 _token, uint256 _amount) internal view returns (uint256){
        Pool storage pool = pools[address(_token)];
        if (pool.totalBorrowShares == 0) {
            return 0;
        }else{
            return (_amount * pool.totalBorrowShares)/ pool.totalBorrows;
        }
    }

    function calculateRoundUpBorrowAmount(ERC20 _token, uint256 _shareAmount) internal view returns (uint256){
        Pool storage pool = pools[address(_token)];
        if (pool.totalBorrows == 0 || pool.totalBorrowShares == 0) {
            return _shareAmount;
        }else if((_shareAmount * pool.totalBorrows) % pool.totalBorrowShares != 0){
            return 1 + (_shareAmount * pool.totalBorrows) / pool.totalBorrowShares;
        }else{
            return (_shareAmount * pool.totalBorrows) / pool.totalBorrowShares;
        }
    }

//---------- Calculate Liqudity Up Down and Amount ----------\\
    function calculateRoundUpLiquidityShareAmount(ERC20 _token, uint256 _amount) internal view returns (uint256){
        Pool storage pool = pools[address(_token)];
        uint256 poolTotalLiquidityShares = pool.tokenTracker.totalSupply();//Think
        uint256 poolTotalLiquidity = getTotalLiquidity(_token);
        
        if (poolTotalLiquidity == 0 || poolTotalLiquidityShares == 0) {
            return _amount;
        }else if((_amount * poolTotalLiquidityShares) % poolTotalLiquidity != 0){
            return 1 + (_amount * poolTotalLiquidityShares) / poolTotalLiquidity;
        }else{
            return (_amount * poolTotalLiquidityShares) / poolTotalLiquidity;
        }
    }

    function calculateRoundDownLiquidityShareAmount(ERC20 _token, uint256 _amount) internal view returns (uint256){
        Pool storage pool = pools[address(_token)];
        uint256 totalLiquidity = getTotalLiquidity(_token);
        uint256 totalLiquidityShares = pool.tokenTracker.totalSupply();

        if (totalLiquidity == 0 && totalLiquidityShares == 0) {
            return _amount;
        }
            return (_amount * totalLiquidityShares) / totalLiquidity;
    }

    function calculateRoundDownLiquidityAmount(ERC20 _token, uint256 _shareAmount) internal view returns (uint256){
        Pool storage pool = pools[address(_token)];
        uint256 poolTotalLiquidityShares = pool.tokenTracker.totalSupply();
        if (poolTotalLiquidityShares == 0) {
            return 0;
        }else{
            return (_shareAmount* getTotalLiquidity(_token)) / (poolTotalLiquidityShares);
        }
    }
//---------- FundaMentalTools ----------\\
    function isAccountHealthy(address _user) public view returns (bool) {
        (, uint256 totalCollateralBalanceBase, uint256 totalBorrowBalanceBase) = getUserAccount(_user);

        return totalBorrowBalanceBase <= totalCollateralBalanceBase;
    }

    function totalBorrowInUSD(ERC20 _token) public view returns (uint256) {
        require(address(priceOracle) != address(0), "price oracle isn't initialized");
        uint256 tokenPricePerUnit = priceOracle.getAssetPrice(address(_token));
        require(tokenPricePerUnit > 0, "token price isn't correct");
        return tokenPricePerUnit * (pools[address(_token)].totalBorrows);
    }
    
    function setUserUseAsCollateral(ERC20 _token, bool _useAsCollateral) external {
        UserPoolData storage userData = userPoolData[msg.sender][address(_token)];
        userData.disableUseAsCollateral = !_useAsCollateral;
        
        if (!_useAsCollateral) {
            require(isAccountHealthy(msg.sender), "can't set use as collateral, account isn't healthy.");
        }
    }

    function getUserAccount(address _user) public view
        returns (
        uint256 totalLiquidityBalanceBase,
        uint256 totalCollateralBalanceBase,
        uint256 totalBorrowBalanceBase
        )
    {
        for (uint256 i = 0; i < tokenList.length; i++) {
            ERC20 _token = tokenList[i];
            Pool storage pool = pools[address(_token)];

            // get user pool data
            (
                uint256 compoundedLiquidityBalance,
                uint256 compoundedBorrowBalance,
                bool userUsePoolAsCollateral
            ) = getUserPoolData(_user, _token);

            if (compoundedLiquidityBalance != 0 || compoundedBorrowBalance != 0) {
                uint256 collateralPercent = pool.poolConfig.getCollateralPercent();
                uint256 poolPricePerUnit = priceOracle.getAssetPrice(address(_token));
                require(poolPricePerUnit > 0, "token price isn't correct");

                uint256 liquidityBalanceBase = poolPricePerUnit * compoundedLiquidityBalance / 1e18;
                totalLiquidityBalanceBase = totalLiquidityBalanceBase + liquidityBalanceBase;
                // this pool can use as collateral when collateralPercent more than 0.
                if (collateralPercent > 0 && userUsePoolAsCollateral) {
                    totalCollateralBalanceBase = totalCollateralBalanceBase + (liquidityBalanceBase * collateralPercent) /1e18;
                }
                    totalBorrowBalanceBase = totalBorrowBalanceBase + (poolPricePerUnit * compoundedBorrowBalance) / 1e18;
            }
        }
    }

//---------- Withdraw ----------\\
    function withdraw(ERC20 _token, uint256 _share) external nonReentrant updatePoolWithInterestsAndTimestamp(_token) {
        Pool storage pool = pools[address(_token)];
        uint256 alBalance = pool.tokenTracker.balanceOf(msg.sender);
        require(
        pool.status,
        "can't withdraw this pool"
        );
        uint256 withdrawShares = _share;
        if (withdrawShares > alBalance) {
            withdrawShares = alBalance;
        }

        uint256 withdrawAmount = calculateRoundDownLiquidityAmount(_token, withdrawShares);

        
        pool.tokenTracker.burn(msg.sender, withdrawShares);

        _token.transfer(msg.sender, withdrawAmount);

        require(isAccountHealthy(msg.sender), "account is not healthy. can't withdraw");
        emit Withdraw(address(_token), msg.sender, withdrawShares, withdrawAmount);
    }

//---------- Repay Process ----------\\
    function repayByAmount(ERC20 _token, uint256 _amount) external nonReentrant updatePoolWithInterestsAndTimestamp(_token) {
        uint256 repayShare = calculateRoundDownBorrowShareAmount(_token, _amount);
        repayInternal(_token, repayShare);
    }

    function repayByShare(ERC20 _token, uint256 _share) external nonReentrant updatePoolWithInterestsAndTimestamp(_token) {
        repayInternal(_token, _share);
    }

    function repayInternal(ERC20 _token, uint256 _share) internal {
        Pool storage pool = pools[address(_token)];
        UserPoolData storage userData = userPoolData[msg.sender][address(_token)];
        require(
        pool.status,
        "can't repay to this pool"
        );
        uint256 paybackShares = _share;
        if (paybackShares > userData.borrowShares) {
        paybackShares = userData.borrowShares;
        }

        uint256 paybackAmount = calculateRoundUpBorrowAmount(_token, paybackShares);

        pool.totalBorrows = pool.totalBorrows - paybackAmount;
        pool.totalBorrowShares = pool.totalBorrowShares - paybackShares;
        userData.borrowShares = userData.borrowShares - paybackShares;

        _token.transferFrom(msg.sender, address(this), paybackAmount);

        emit Repay(address(_token), msg.sender, paybackShares, paybackAmount);
    }

//---------- Borrow Amount Liquidate ----------\\
    function liquidate(address _user,ERC20 _token,uint256 _liquidateShares,ERC20 _collateral) external {
        Pool storage pool = pools[address(_token)];
        Pool storage collateralPool = pools[address(_collateral)];
        UserPoolData storage userCollateralData = userPoolData[_user][address(_collateral)];
        UserPoolData storage userTokenData = userPoolData[_user][address(_token)];
        require(
        pool.status,
        "can't liquidate this pool"
        );

        require(!isAccountHealthy(_user), "user's account is healthy. can't liquidate this account");

        require(
        !userCollateralData.disableUseAsCollateral,
        "user didn't enable the requested collateral"
        );

        require(
        collateralPool.poolConfig.getCollateralPercent() > 0,
        "this pool isn't used as collateral"
        );

        require(userTokenData.borrowShares > 0, "user didn't borrow this token");

        uint256 maxPurchaseShares = (userTokenData.borrowShares *CLOSE_FACTOR) / 1e18;
        uint256 liquidateShares = _liquidateShares;
        if (liquidateShares > maxPurchaseShares) {
            liquidateShares = maxPurchaseShares;
        }
        uint256 liquidateAmount = calculateRoundUpBorrowAmount(_token, liquidateShares);

        uint256 collateralAmount = calculateCollateralAmount(_token, liquidateAmount, _collateral);
        uint256 collateralShares = calculateRoundUpLiquidityShareAmount(_collateral, collateralAmount);

        _token.transferFrom(msg.sender, address(this), liquidateAmount);

        require(
        collateralPool.tokenTracker.balanceOf(_user) > collateralShares,
        "user collateral isn't enough"
        );
        collateralPool.tokenTracker.burn(_user, collateralShares);

        collateralPool.tokenTracker.mint(msg.sender, collateralShares);

        pool.totalBorrows = pool.totalBorrows - liquidateAmount;
        pool.totalBorrowShares = pool.totalBorrowShares - liquidateShares;
        userTokenData.borrowShares = userTokenData.borrowShares - liquidateShares;

        emit Liquidate(
        _user,
        address(_token),
        address(_collateral),
        liquidateAmount,
        liquidateShares,
        collateralAmount,
        collateralShares,
        msg.sender
        );
    }

//---------- Calculate Collateral ----------\\
    function calculateCollateralAmount(ERC20 _token, uint256 _liquidateAmount, ERC20 _collateral) internal view returns (uint256) {
        require(address(priceOracle) != address(0), "price oracle isn't initialized");
        uint256 tokenPricePerUnit = priceOracle.getAssetPrice(address(_token));
        require(tokenPricePerUnit > 0, "liquidated token price isn't correct");

        uint256 collateralPricePerUnit = priceOracle.getAssetPrice(address(_collateral));
        require(collateralPricePerUnit > 0, "collateral price isn't correct");

        uint256 liquidationBonus = pools[address(_token)].poolConfig.getLiquidationBonusPercent();
        return ((tokenPricePerUnit * _liquidateAmount * liquidationBonus) /collateralPricePerUnit * 1e18);
    }

//---------- Owner Settings ----------\\
    function setReservePercent(uint256 _reservePercent) external onlyOwner {
        uint256 previousReservePercent = reservePercent;
        reservePercent = _reservePercent;
        emit ReservePercentUpdated(previousReservePercent, reservePercent);
    }

    function withdrawReserve(ERC20 _token, uint256 _amount) external nonReentrant updatePoolWithInterestsAndTimestamp(_token) onlyOwner{
        Pool storage pool = pools[address(_token)];
        uint256 poolBalance = _token.balanceOf(address(this));
        require(_amount <= poolBalance, "pool balance insufficient");
        require(_amount <= pool.poolReserves, "amount is more than pool reserves");

        _token.transfer(msg.sender, _amount);
        pool.poolReserves = pool.poolReserves - _amount;
        emit ReserveWithdrawn(address(_token), _amount, msg.sender);
    }
} 