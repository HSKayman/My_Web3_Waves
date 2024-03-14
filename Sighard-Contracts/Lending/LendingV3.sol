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

contract LendingContract is Ownable{

    enum LoanStatus {
        OFFER,
        REQUEST,
        FUNDED,
        ACTIVE,
        REPAID,
        ENDED
    }

    struct LoanData {
        uint256 loanAmount;
        address loanCurrency;
        uint128 duration;
        uint256 createdOn;
        uint256 startedOn;
        uint256 repayment;
        address borrower;
        address lender;
        bool isLoanActive;
        uint256 collateral;
        LoanStatus status;
        uint256 requestingUser;
    }

    mapping(uint256 => LoanData) public loans;  
    uint256 public loanCount = 0;

    IERC20 public BUSD;
    IUniswapV2Pair public busdPair;   
    IUniswapV2Router02 public uniswapV2Router;  

    event LoanRequested(uint256 loanId, address borrower, uint256 amount, uint128 duration);
    event LoanFunded(uint256 loanId, address lender, uint256 amount,  uint128 duration);
    event LoanOffered(uint256 loanId, address lender, uint256 amount,  uint128 duration);
    event LoanStarted(uint256 loanId, address borrower, address lender, uint256 amount,  uint128 duration);
    event LoanRepaid(uint256 loanId, address borrower, uint256 amount,  uint128 duration);
    event LoanEnded(uint256 loanId, address borrower, uint256 amount, uint128 duration);
    constructor() {
        BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        busdPair = IUniswapV2Pair(0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16);
        uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    }
//---------------------LENDER PROCESS---------------------//
    function offerLoan(uint256 _loanAmount, address _loanCurrency, uint128 _duration, uint256 _repayment) external {
        require(_loanAmount > 0, "Loan amount should be greater than 0");
        require(isContract(_loanCurrency), "Loan currency should be a contract");
        require(_repayment > _loanAmount, "Repayment amount should be greater than loan amount");
        loans[loanCount] = LoanData(_loanAmount, _loanCurrency, _duration * 1 days, block.timestamp, 0, _repayment, address(0), msg.sender, false, 0, LoanStatus.OFFER,0);
        loanCount++;   
        emit LoanOffered(loanCount, msg.sender, _loanAmount, _duration);
    }

    function acceptRequestedLoan(uint256 _loanId) external {
        LoanData storage loan = loans[_loanId];
        require(loan.status == LoanStatus.REQUEST, "Loan should be in request state");
        require(loan.borrower != address(0), "Loan should have a borrower");
        require(loan.borrower != msg.sender, "Borrower cannot accept his own loan");

        uint256 initialBalance = IERC20(loan.loanCurrency).balanceOf(address(this));
        IERC20(loan.loanCurrency).transferFrom(msg.sender, address(this), loan.loanAmount);
        uint256 finalBalance = IERC20(loan.loanCurrency).balanceOf(address(this)) - initialBalance;
        require(finalBalance == loan.loanAmount, "Loan amount should be transferred to contract");

        loan.lender = msg.sender;
        loan.status = LoanStatus.FUNDED;
        loan.isLoanActive = true;

        emit LoanFunded(_loanId, msg.sender, loan.loanAmount, loan.duration);
    }

    function fundedLoan(uint256 _loanId) external {
        LoanData storage loan = loans[_loanId];
        require(loan.status == LoanStatus.OFFER, "Loan should be in funded state");
        require(loan.lender == msg.sender, "Only lender can fund the loan");

        uint256 initialBalance = IERC20(loan.loanCurrency).balanceOf(address(this));
        IERC20(loan.loanCurrency).transferFrom(msg.sender, address(this), loan.loanAmount);
        uint256 finalBalance = IERC20(loan.loanCurrency).balanceOf(address(this)) - initialBalance;
        require(finalBalance == loan.loanAmount, "Loan amount should be transferred to contract");

        loan.status = LoanStatus.FUNDED;
        loan.isLoanActive = true;
        emit LoanFunded(_loanId, msg.sender, loan.loanAmount, loan.duration);
    }

    function withdraw(uint256 _loanId) external {
        LoanData storage loan = loans[_loanId];
        require(loan.status == LoanStatus.FUNDED || loan.status == LoanStatus.REPAID, "Loan should be in funded or repaid state");
        require(loan.lender == msg.sender, "Only lender can withdraw the loan");
        if(loan.status == LoanStatus.FUNDED){
            IERC20(loan.loanCurrency).transfer(msg.sender, loan.loanAmount);
        }else{
            IERC20(loan.loanCurrency).transfer(msg.sender, loan.repayment);
        }
        // take fee
        loan.status = LoanStatus.ENDED;
        loan.isLoanActive = false;
        emit LoanEnded(_loanId, loan.borrower, loan.loanAmount, loan.duration);
    }

//---------------------BORROWER PROCESS---------------------//
    function requestLoan(uint256 _loanAmount, address _loanCurrency, uint128 _duration, uint256 _repayment) external {
        require(_loanAmount > 0, "Loan amount should be greater than 0");
        require(_repayment > _loanAmount, "Repayment amount should be greater than loan amount");
        require(isContract(_loanCurrency), "Loan currency should be a contract");
        loans[loanCount] = LoanData(_loanAmount, _loanCurrency, _duration * 1 days, block.timestamp, 0, _repayment, msg.sender,address(0) , false, 0, LoanStatus.REQUEST,0);
        loanCount++;   
        emit LoanRequested(loanCount, msg.sender, _loanAmount, _duration);
    }

    function acceptOfferedLoan(uint256 _loanId) payable external {
        LoanData storage loan = loans[_loanId];
        require(loan.status == LoanStatus.FUNDED, "Loan should be in offer state");
        require(loan.lender != address(0), "Loan should have a lender");
        require(loan.lender != msg.sender, "Lender cannot accept his own loan");
        loan.collateral= computeCollateral(_loanId);
        require(msg.value > loan.collateral, "Collateral amount should be transferred to contract");
        
        
        uint256 initialBalance = IERC20(loan.loanCurrency).balanceOf(msg.sender);
        IERC20(loan.loanCurrency).transfer(msg.sender, loan.loanAmount);
        uint256 finalBalance = IERC20(loan.loanCurrency).balanceOf(msg.sender) - initialBalance;
        require(finalBalance == loan.loanAmount, "Loan amount should be transferred to borrower");

        loan.borrower = msg.sender;
        loan.status = LoanStatus.ACTIVE;
        loan.startedOn = block.timestamp;
        loan.isLoanActive = true;

        emit LoanStarted(_loanId, loan.lender, msg.sender, loan.loanAmount, loan.duration);
    }

    function completeAcceptedRequestLoan(uint256 _loanId) payable external {
        LoanData storage loan = loans[_loanId];
        require(loan.status == LoanStatus.FUNDED, "Loan should be in funded state");
        require(loan.borrower != address(0), "Loan should have a borrower");
        require(loan.borrower == msg.sender, "Only borrower can complete the loan");
        loan.collateral= computeCollateral(_loanId);
        require(msg.value > loan.collateral, "Collateral amount should be transferred to contract");

        uint256 initialBalance = IERC20(loan.loanCurrency).balanceOf(msg.sender);
        IERC20(loan.loanCurrency).transfer(msg.sender, loan.loanAmount);
        uint256 finalBalance = IERC20(loan.loanCurrency).balanceOf(msg.sender) - initialBalance;
        require(finalBalance == loan.loanAmount, "Loan amount should be transferred to borrower");

        loan.status = LoanStatus.ACTIVE;
        loan.startedOn = block.timestamp;

        emit LoanStarted(_loanId, loan.lender, msg.sender, loan.loanAmount, loan.duration);
    }

    function repayment(uint256 _loanId) external {
        LoanData storage loan = loans[_loanId];
        require(loan.status == LoanStatus.ACTIVE, "Loan should be in active state");
        require(loan.borrower == msg.sender, "Only borrower can repay the loan");
        require(loan.startedOn + loan.duration >= block.timestamp, "Loan duration is not over yet");

        uint256 initialBalance = IERC20(loan.loanCurrency).balanceOf(address(this));
        IERC20(loan.loanCurrency).transferFrom(msg.sender, address(this), loan.repayment);
        uint256 finalBalance = IERC20(loan.loanCurrency).balanceOf(address(this)) - initialBalance;
        require(finalBalance == loan.repayment, "Repayment amount should be transferred to contract");
        
        loan.status = LoanStatus.REPAID;
        emit LoanRepaid(_loanId, msg.sender, loan.repayment, loan.duration);
    }

//---------------------BORROWER AND LENDER PROCESS---------------------//
    function addRequestingUser(uint256 _loanId) external {
        LoanData storage loan = loans[_loanId];
        require(loan.status == LoanStatus.OFFER || loan.status == LoanStatus.REQUEST, "Loan should be in primary state");
        require(loan.lender != msg.sender && loan.borrower != msg.sender, "Lender cannot add requesting user to his own loan");
        loan.requestingUser += 1;
    }



//---------------------INTERNAL PROCESS---------------------//
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function computeCollateral(uint256 _loanId) public view returns (uint256) {
        return (loans[_loanId].repayment * BNBAmountForBusd()*2) / (10**18);
    }

    function BNBAmountForBusd() public view returns(uint256){
        uint256 bnbInBusdPair;
        uint256 busdInBusdPair;
        
        if(address(busdPair.token0()) == address(BUSD))
            (busdInBusdPair, bnbInBusdPair,  ) = busdPair.getReserves();
        else
            (bnbInBusdPair, busdInBusdPair, ) = busdPair.getReserves();
            
        uint256 aDollarWorthOfBNB = (bnbInBusdPair * (10**18)) / busdInBusdPair;

        return aDollarWorthOfBNB;
    }

    function isLiqudiated(uint256 _loanId) public view returns (bool) {
        LoanData memory loan = loans[_loanId];
        
        return (BNBAmountForBusd() * loan.repayment * 4) / (3* 10**18) <= loan.collateral;
    }

    function liqudiated(uint256 _loanId) external {
        LoanData storage loan = loans[_loanId];
        require(loan.status == LoanStatus.ACTIVE, "Loan should be in active state");
        require(isLiqudiated(_loanId), "Loan is not liqudiated yet");

        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(BUSD);

        uint256 initialBalance = IERC20(BUSD).balanceOf(address(this));
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: loan.collateral}(
            0,
            path,
            address(this),
            block.timestamp);
        uint256 finalBalance = IERC20(BUSD).balanceOf(address(this)) - initialBalance;

        loan.status = LoanStatus.REPAID;
        emit LoanRepaid(_loanId, loan.borrower, finalBalance, loan.duration);
    }

//---------------------OWNER---------------------//
    function claimStuckTokens(address token) external onlyOwner {
        if (token == address(0x0)) {
            payable(msg.sender).transfer(address(this).balance);
            return;
        }
        
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(msg.sender, balance);
    }


//---------------------VIEW PROCESS---------------------//
    function getRequested() public view returns (LoanData[] memory, uint256[] memory) {
        uint256 count=0;
        for (uint256 i = 0; i < loanCount; i++) {
            if (loans[i].status == LoanStatus.REQUEST) {
                count++;
            }
        }
        LoanData[] memory result = new LoanData[](count);
        uint256[] memory resultIds = new uint256[](count);
        uint256 j=0;
            for (uint256 i = 0; i < loanCount; i++) {
            if (loans[i].status == LoanStatus.REQUEST) {
                result[j] = loans[i];
                resultIds[j] = i;
                j+=1;
            }
        }
        return (result, resultIds);
    }

    function getOffered() public view returns (LoanData[] memory, uint256[] memory) {
        uint256 count=0;
        for (uint256 i = 0; i < loanCount; i++) {
            if (loans[i].status == LoanStatus.OFFER) {
                count++;
            }
        }
        LoanData[] memory result = new LoanData[](count);
        uint256[] memory resultIds = new uint256[](count);
        uint256 j=0;
            for (uint256 i = 0; i < loanCount; i++) {
            if (loans[i].status == LoanStatus.OFFER) {
                result[j] = loans[i];
                resultIds[j] = i;
                j+=1;
            }
        }
        return (result, resultIds);
    }

    function getFunded() public view returns (LoanData[] memory, uint256[] memory) {
        uint256 count=0;
        for (uint256 i = 0; i < loanCount; i++) {
            if (loans[i].status == LoanStatus.FUNDED) {
                count++;
            }
        }
        LoanData[] memory result = new LoanData[](count);
        uint256[] memory resultIds = new uint256[](count);
        uint256 j=0;
            for (uint256 i = 0; i < loanCount; i++) {
            if (loans[i].status == LoanStatus.FUNDED) {
                result[j] = loans[i];
                resultIds[j] = i;
                j+=1;
            }
        }
        return (result, resultIds);
    }

    function getActiveted() public view returns (LoanData[] memory, uint256[] memory) {
        uint256 count=0;
        for (uint256 i = 0; i < loanCount; i++) {
            if (loans[i].status == LoanStatus.ACTIVE) {
                count++;
            }
        }
        LoanData[] memory result = new LoanData[](count);
        uint256[] memory resultIds = new uint256[](count);
        uint256 j=0;
            for (uint256 i = 0; i < loanCount; i++) {
            if (loans[i].status == LoanStatus.ACTIVE) {
                result[j] = loans[i];
                resultIds[j] = i;
                j+=1;
            }
        }
        return (result, resultIds);
    }

    function getRepaid() public view returns (LoanData[] memory, uint256[] memory) {
        uint256 count=0;
        for (uint256 i = 0; i < loanCount; i++) {
            if (loans[i].status == LoanStatus.REPAID) {
                count++;
            }
        }
        LoanData[] memory result = new LoanData[](count);
        uint256[] memory resultIds = new uint256[](count);
        uint256 j=0;
            for (uint256 i = 0; i < loanCount; i++) {
            if (loans[i].status == LoanStatus.REPAID) {
                result[j] = loans[i];
                resultIds[j] = i;
                j+=1;
            }
        }
        return (result, resultIds);
    }

    function getEnded() public view returns (LoanData[] memory, uint256[] memory) {
        uint256 count=0;
        for (uint256 i = 0; i < loanCount; i++) {
            if (loans[i].status == LoanStatus.REPAID) {
                count++;
            }
        }
        LoanData[] memory result = new LoanData[](count);
        uint256[] memory resultIds = new uint256[](count);
        uint256 j=0;
            for (uint256 i = 0; i < loanCount; i++) {
            if (loans[i].status == LoanStatus.REPAID) {
                result[j] = loans[i];
                resultIds[j] = i;
                j+=1;
            }
        }
        return (result, resultIds);
    }

    function getMyRequest(address _user) public view returns (LoanData[] memory, uint256[] memory) {
        uint256 count=0;
        for (uint256 i = 0; i < loanCount; i++) {
            if (loans[i].status == LoanStatus.REQUEST && loans[i].borrower == _user) {
                count++;
            }
        }
        LoanData[] memory result = new LoanData[](count);
        uint256[] memory resultIds = new uint256[](count);
        uint256 j=0;
            for (uint256 i = 0; i < loanCount; i++) {
            if (loans[i].status == LoanStatus.REQUEST && loans[i].borrower == _user) {
                result[j] = loans[i];
                resultIds[j] = i;
                j+=1;
            }
        }
        return (result, resultIds);
    }

    function getMyOffer(address _user) public view returns (LoanData[] memory, uint256[] memory) {
        uint256 count=0;
        for (uint256 i = 0; i < loanCount; i++) {
            if (loans[i].status == LoanStatus.OFFER && loans[i].lender == _user) {
                count++;
            }
        }
        LoanData[] memory result = new LoanData[](count);
        uint256[] memory resultIds = new uint256[](count);
        uint256 j=0;
            for (uint256 i = 0; i < loanCount; i++) {
            if (loans[i].status == LoanStatus.OFFER && loans[i].lender == _user) {
                result[j] = loans[i];
                resultIds[j] = i;
                j+=1;
            }
        }
        return (result, resultIds);
    }

    function getMyActive(address _user) public view returns (LoanData[] memory, uint256[] memory) {
        uint256 count=0;
        for (uint256 i = 0; i < loanCount; i++) {
            if (loans[i].status == LoanStatus.ACTIVE && loans[i].borrower == _user) {
                count++;
            }
        }
        LoanData[] memory result = new LoanData[](count);
        uint256[] memory resultIds = new uint256[](count);
        uint256 j=0;
            for (uint256 i = 0; i < loanCount; i++) {
            if (loans[i].status == LoanStatus.ACTIVE && loans[i].borrower == _user) {
                result[j] = loans[i];
                resultIds[j] = i;
                j+=1;
            }
        }
        return (result, resultIds);
    }

    function getMyRepaid(address _user) public view returns (LoanData[] memory, uint256[] memory) {
        uint256 count=0;
        for (uint256 i = 0; i < loanCount; i++) {
            if (loans[i].status == LoanStatus.REPAID && loans[i].borrower == _user) {
                count++;
            }
        }
        LoanData[] memory result = new LoanData[](count);
        uint256[] memory resultIds = new uint256[](count);
        uint256 j=0;
            for (uint256 i = 0; i < loanCount; i++) {
            if (loans[i].status == LoanStatus.REPAID && loans[i].borrower == _user) {
                result[j] = loans[i];
                resultIds[j] = i;
                j+=1;
            }
        }
        return (result, resultIds);
    }
}