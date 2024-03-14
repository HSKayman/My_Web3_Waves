// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
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

library Address {
    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
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

contract Pacmate is Context, IERC20, Ownable {
    using Address for address;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) private _isExcluded;
    address[] private _excluded;

    string private _name     = "Pacmate";
    string private _symbol   = "PCMT";  
    uint8  private _decimals = 18;
   
    uint256 private constant MAX = type(uint256).max;
    uint256 private _tTotal = 1_000_000_000 * (10 ** _decimals);
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    uint256 public developmentFeeOnSell = 0;
    uint256 public marketingFeeOnSell = 0;
    uint256 public stakingFeeOnSell = 0;
    uint256 public gameRewardsFeeOnSell = 0;
    uint256 public taxFeeOnSell = 0;

    uint256 public developmentFeeOnBuy = 0;
    uint256 public marketingFeeOnBuy = 0;
    uint256 public stakingFeeOnBuy = 0;
    uint256 public gameRewardsFeeOnBuy = 0;
    uint256 public taxFeeOnBuy = 0;

    uint256 private taxFee;
    uint256 private stakingFee;
    uint256 private marketingFee;
    uint256 private devTeamFee;
    uint256 private gameRewardsFee;

    uint256 public totalFeesOnSell = developmentFeeOnSell + marketingFeeOnSell + stakingFeeOnSell + gameRewardsFeeOnSell + taxFeeOnSell;
    uint256 public totalFeesOnBuy = developmentFeeOnBuy + marketingFeeOnBuy + stakingFeeOnBuy + gameRewardsFeeOnBuy + taxFeeOnBuy;

    address public marketingWallet = 0x7B2B62608D9BD8564B834b44A56cd2FF14d84cDd;
    address public devTeamWallet = 0x39664f3A39C721593871d690476ee4C94F8C1a74;
    address public gameRewardsWallet = 0x42824A7D078dE94cC1A0bd392695c80Bf7d5724b;
    address public stakingWallet = 0x5EA4d48B2F651a5A24D41Cb41De31d91EfAcee9d;
    
    address private DEAD = 0x000000000000000000000000000000000000dEaD;

    IUniswapV2Router02 public  uniswapV2Router;
    address public  uniswapV2Pair;

    bool private inSwapAndLiquify;
    bool public swapEnabled = true;
    uint256 public swapTokensAtAmount = _tTotal / 5000;
    
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event MarketingWalletChanged(address marketingWallet);
    event DevTeamWalletChanged(address devTeamWallet);
    event GameWalletChanged(address gameRewardsWallet);
    event StakingWalletChanged(address stakingWallet);
    event SwapEnabledUpdated(bool enabled);
    event SendMarketing(uint256 bnbSend);
    event SendDevTeam(uint256 bnbSend);
    event SendGameRewards(uint256 bnbSend);
    event UpdatedSellFees(uint256, uint256, uint256, uint256, uint256, uint256);
    event UpdatedBuyFees(uint256, uint256, uint256, uint256, uint256, uint256);
    constructor() 
    { 
        address newOwner = 0x8d25608Ae2BA50D95d17f2CF684fe808664Ccd25;
        transferOwnership(newOwner);
        operator = msg.sender;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

        _approve(address(this), address(uniswapV2Router), MAX);

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[marketingWallet] = true;
        _isExcludedFromFees[address(this)] = true;

        _rOwned[owner()] = _rTotal;
        emit Transfer(address(0), owner(), _tTotal);
    }

    address public operator;
    modifier onlyOperator(){
        require(operator == _msgSender(),"Caller is not the Operator");
        _;
    }

    function changeOperatorWallet(address newAddress) external onlyOperator{
        require(newAddress != operator,"Operator Address is already same");
        operator = newAddress;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalReflectionDistributed() public view returns (uint256) {
        return _tFeeTotal;
    }

    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,,,,,,,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rTotal = _rTotal - rAmount;
        _tFeeTotal = _tFeeTotal + tAmount;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount / currentRate;
    }

    function excludeFromReward(address account) public onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    receive() external payable {}

    function claimStuckTokens(address token) external onlyOwner {
        require(token != address(this), "Owner cannot claim native tokens");
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
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal - rFee;
        _tFeeTotal = _tFeeTotal + tFee;
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tMarketing, uint256 tDevTeam, uint256 tGame) = _getTValues(tAmount);
        uint256[3] memory rAmounts  = _getRValues(tAmount, tFee, tMarketing, tDevTeam, tGame,  _getRate());
        return (rAmounts[0], rAmounts[1], rAmounts[2], tTransferAmount, tFee, tMarketing, tDevTeam, tGame);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tMarketing = calculateMarketingFee(tAmount);
        uint256 tDevTeam = calculateDevTeamFee(tAmount);
        uint256 tGame = calculateGameFee(tAmount);
        uint256 tTransferAmount = tAmount - tFee - tMarketing - tDevTeam - tGame;
        return (tTransferAmount, tFee, tMarketing, tDevTeam, tGame);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tMarketing, uint256 tDevTeam, uint256 tGame, uint256 currentRate) private pure returns (uint256[3] memory) {
        uint256 rAmount = tAmount * currentRate;
        uint256 rFee = tFee * currentRate;
        uint256 rMarketing = tMarketing * currentRate;
        uint256 rDevTeam = tDevTeam * currentRate;
        uint256 rGame = tGame * currentRate;
        uint256 rTransferAmount = rAmount - rFee - rMarketing - rDevTeam - rGame;
        return [rAmount, rTransferAmount, rFee];
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply - _rOwned[_excluded[i]];
            tSupply = tSupply - _tOwned[_excluded[i]];
        }
        if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    
    function _takeStaking(address sender, uint256 tTransferAmount, uint256 rTransferAmount, uint256 tAmount) private returns (uint256, uint256) {
        if(stakingFee==0)   
            return(tTransferAmount, rTransferAmount);
        uint256 tStaking = calculateStakingFee(tAmount);
        uint256 rStaking = tStaking * _getRate();
        rTransferAmount = rTransferAmount - rStaking;
        tTransferAmount = tTransferAmount - tStaking;
        _rOwned[stakingWallet] = _rOwned[stakingWallet] + rStaking;
        if(_isExcluded[stakingWallet])
            _tOwned[stakingWallet] = _tOwned[stakingWallet] + tStaking;
        emit Transfer(sender, stakingWallet, tStaking);
        return(tTransferAmount, rTransferAmount);
    }

    function _takeMarketing(uint256 tMarketing) private {
        if (tMarketing > 0) {
            uint256 currentRate =  _getRate();
            uint256 rMarketing = tMarketing * currentRate;
            _rOwned[address(this)] = _rOwned[address(this)] + rMarketing;
            if(_isExcluded[address(this)])
                _tOwned[address(this)] = _tOwned[address(this)] + tMarketing;
        }
    }

    function _takeDevTeam(uint256 tDevTeam) private {
        if (tDevTeam > 0) {
            uint256 currentRate =  _getRate();
            uint256 rDevTeam = tDevTeam * currentRate;
            _rOwned[address(this)] = _rOwned[address(this)] + rDevTeam;
            if(_isExcluded[address(this)])
                _tOwned[address(this)] = _tOwned[address(this)] + tDevTeam;
        }
    }

    function _takeGameReward(uint256 tGame) private {
        if (tGame > 0) {
            uint256 currentRate =  _getRate();
            uint256 rGame = tGame * currentRate;
            _rOwned[address(this)] = _rOwned[address(this)] + rGame;
            if(_isExcluded[address(this)])
                _tOwned[address(this)] = _tOwned[address(this)] + tGame;
        }
    }
    
    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount * taxFee / 100;
    }

    function calculateStakingFee(uint256 _amount) private view returns (uint256) {
        return _amount * stakingFee / 100;
    }
    
    function calculateMarketingFee(uint256 _amount) private view returns (uint256) {
        return _amount * marketingFee / 100;
    }

    function calculateDevTeamFee(uint256 _amount) private view returns (uint256) {
        return _amount * devTeamFee  / 100;
    }

    function calculateGameFee(uint256 _amount) private view returns (uint256) {
        return _amount * gameRewardsFee / 100;
    }
    
    function setBuyFee() private{
        if(taxFee == taxFeeOnBuy && stakingFee == stakingFeeOnBuy && marketingFee == marketingFeeOnBuy && devTeamFee == developmentFeeOnBuy && gameRewardsFee == gameRewardsFeeOnBuy)
            return;
        taxFee = taxFeeOnBuy;
        stakingFee = stakingFeeOnBuy;
        marketingFee = marketingFeeOnBuy;
        devTeamFee = developmentFeeOnBuy;
        gameRewardsFee = gameRewardsFeeOnBuy;
    }

    function setSellFee() private{
        if(taxFee == taxFeeOnSell && stakingFee == stakingFeeOnSell && marketingFee == marketingFeeOnSell && devTeamFee == developmentFeeOnSell && gameRewardsFee == gameRewardsFeeOnSell)
            return;

        taxFee = taxFeeOnSell;
        stakingFee = stakingFeeOnSell;
        marketingFee = marketingFeeOnSell;
        devTeamFee = developmentFeeOnSell;
        gameRewardsFee = gameRewardsFeeOnSell;
    }


    function removeAllFee() private {
        if(taxFee == 0 && stakingFee == 0 && marketingFee == 0 && devTeamFee == 0 && gameRewardsFee ==0) return;
        taxFee = 0;
        marketingFee = 0;
        stakingFee = 0;
        devTeamFee = 0;
        gameRewardsFee = 0;
    }
    
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 contractTokenBalance = balanceOf(address(this));        
        bool overMinTokenBalance = contractTokenBalance >= swapTokensAtAmount;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            to == uniswapV2Pair &&
            swapEnabled
        ) {
            inSwapAndLiquify = true;
            

            uint256 devTeamShare = developmentFeeOnBuy + developmentFeeOnSell;
            uint256 gameShare = gameRewardsFeeOnBuy + gameRewardsFeeOnSell;
            uint256 marketingShare = marketingFeeOnBuy + marketingFeeOnSell;
            uint256 taxForSwap = marketingShare + gameShare + devTeamShare;
            if(taxForSwap > 0) {
                uint256 initialBalance = address(this).balance;

                address[] memory path = new address[](2);
                path[0] = address(this);
                path[1] = uniswapV2Router.WETH();

                uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                    contractTokenBalance,
                    0, // accept any amount of ETH
                    path,
                    address(this),
                    block.timestamp);

                uint256 newBalance = address(this).balance - initialBalance;

                if(devTeamShare > 0) {
                    uint256 devTeamBNB = newBalance * devTeamShare / taxForSwap;
                    sendBNB(payable(devTeamWallet), devTeamBNB);
                    emit SendDevTeam(devTeamBNB);
                    
                }
                
                if(marketingShare > 0) {
                    uint256 marketingBNB = newBalance * marketingShare / taxForSwap;
                    sendBNB(payable(marketingWallet), marketingBNB);
                    emit SendMarketing(marketingBNB);
                } 

                if(gameShare > 0) {
                    uint256 gameBNB = newBalance * gameShare / taxForSwap;
                    sendBNB(payable(gameRewardsWallet), gameBNB);
                    emit SendGameRewards(gameBNB);
                }
            }
            inSwapAndLiquify = false;
        }
        
        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from,to,amount);
    }

    //=======Swap=======//
    function setSwapTokensAtAmount(uint256 newAmount) external onlyOwner() {
        require(newAmount > totalSupply() / 100000, "SwapTokensAtAmount must be greater than 0.001% of total supply");
        swapTokensAtAmount = newAmount;
    }
    
    function setSwapEnabled(bool _enabled) external onlyOwner {
        swapEnabled = _enabled;
        emit SwapEnabledUpdated(_enabled);
    }

 //=======TaxAndTransfer=======//
    function _tokenTransfer(address sender, address recipient, uint256 amount) private {
        
        if (_isExcludedFromFees[sender] || 
            _isExcludedFromFees[recipient] || 
            (sender != uniswapV2Pair && recipient != uniswapV2Pair)
        ) {
            removeAllFee();
        }else if(sender != uniswapV2Pair){
            setBuyFee();
        }else{
            setSellFee();
        }
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tMarketing, uint256 tDevTeam, uint256 tGame) = _getValues(tAmount);
        (tTransferAmount, rTransferAmount) = _takeStaking(sender, tTransferAmount, rTransferAmount, tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeMarketing(tMarketing);
        _takeDevTeam(tDevTeam);
        _takeGameReward(tGame);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tMarketing, uint256 tDevTeam, uint256 tGame) = _getValues(tAmount);
        (tTransferAmount, rTransferAmount) = _takeStaking(sender, tTransferAmount, rTransferAmount, tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeMarketing(tMarketing);
        _takeDevTeam(tDevTeam);
        _takeGameReward(tGame);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tMarketing, uint256 tDevTeam, uint256 tGame) = _getValues(tAmount);
        (tTransferAmount, rTransferAmount) = _takeStaking(sender, tTransferAmount, rTransferAmount, tAmount);
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount; 
        _takeMarketing(tMarketing);
        _takeDevTeam(tDevTeam);
        _takeGameReward(tGame);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tMarketing, uint256 tDevTeam, uint256 tGame) = _getValues(tAmount);
        (tTransferAmount, rTransferAmount) = _takeStaking(sender, tTransferAmount, rTransferAmount, tAmount);
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeMarketing(tMarketing);
        _takeDevTeam(tDevTeam);
        _takeGameReward(tGame);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    //=======FeeManagement=======//
    function excludeFromFees(address account) external onlyOwner {
        require(!_isExcludedFromFees[account], "Account is already the value of true");
        _isExcludedFromFees[account] = true;

        emit ExcludeFromFees(account, true);
    }

    function includeFromFees(address account) external onlyOperator {
        require(!_isExcludedFromFees[account], "Account is already the value of false");
        _isExcludedFromFees[account] = false;

        emit ExcludeFromFees(account, false);
    }
    
    function changeMarketingWallet(address _marketingWallet) external onlyOwner {
        require(_marketingWallet != marketingWallet, "Marketing wallet is already that address");
        require(!isContract(_marketingWallet), "Marketing wallet cannot be a contract");
        marketingWallet = _marketingWallet;
        emit MarketingWalletChanged(marketingWallet);
    }

    function changeDevTeamWallet(address _devTeamWallet) external onlyOwner {
        require(_devTeamWallet != devTeamWallet, "Developer Team wallet is already that address");
        require(!isContract(_devTeamWallet), "Developer Team wallet cannot be a contract");
        devTeamWallet = _devTeamWallet;
        emit DevTeamWalletChanged(devTeamWallet);
    }

    function changeGameRewardsWallet(address _gameWallet) external onlyOwner {
        require(_gameWallet != gameRewardsWallet, "Game wallet is already that address");
        require(!isContract(_gameWallet), "Game wallet cannot be a contract");
        gameRewardsWallet = _gameWallet;
        emit GameWalletChanged(gameRewardsWallet);
    }

    function changeStakingWallet(address _stakingWallet) external onlyOwner {
        require(_stakingWallet != stakingWallet, "Staking wallet is already that address");
        require(_stakingWallet != address(0), "Staking wallet cannot be the zero address");
        stakingWallet = _stakingWallet;
        emit StakingWalletChanged(stakingWallet);
    }

    function setSellTaxFeePercent(uint256 _deveoplmentFeePercent,
                                uint256 _marketingFeePercent,
                                uint256 _gameFeePercent,
                                uint256 _stakingFeePercent,
                                uint256 _taxFeePercent) external onlyOwner {
        developmentFeeOnSell = _deveoplmentFeePercent;
        marketingFeeOnSell = _marketingFeePercent;
        gameRewardsFeeOnSell = _gameFeePercent;
        stakingFeeOnSell = _stakingFeePercent;
        taxFeeOnSell = _taxFeePercent;
        totalFeesOnSell = developmentFeeOnSell + marketingFeeOnSell + gameRewardsFeeOnSell + stakingFeeOnSell + taxFeeOnSell;
        require(totalFeesOnSell <= 25, "Total fees on sell must be less than 25%");
        emit UpdatedSellFees(developmentFeeOnSell, marketingFeeOnSell, gameRewardsFeeOnSell, stakingFeeOnSell, taxFeeOnSell, totalFeesOnSell);               
    }

    function setBuyTaxFeePercent(uint256 _deveoplmentFeePercent,
                                uint256 _marketingFeePercent,
                                uint256 _gameFeePercent,
                                uint256 _stakingFeePercent,
                                uint256 _taxFeePercent) external onlyOwner {
        developmentFeeOnBuy = _deveoplmentFeePercent;
        marketingFeeOnBuy = _marketingFeePercent;
        gameRewardsFeeOnBuy = _gameFeePercent;
        stakingFeeOnBuy = _stakingFeePercent;
        taxFeeOnBuy = _taxFeePercent;
        totalFeesOnBuy = developmentFeeOnBuy + marketingFeeOnBuy + gameRewardsFeeOnBuy + stakingFeeOnBuy + taxFeeOnBuy;
        require(totalFeesOnBuy <= 25, "Total fees on buy must be less than 25%");
        emit UpdatedBuyFees(developmentFeeOnBuy, marketingFeeOnBuy, gameRewardsFeeOnBuy, stakingFeeOnBuy, taxFeeOnBuy, totalFeesOnBuy);
    }
}