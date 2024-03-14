// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IERC20Permit {

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(address owner) external view returns (uint256);

    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

library Address {

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        if (returndata.length > 0) {
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface VRFCoordinatorV2Interface {

  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );

  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);

  function createSubscription() external returns (uint64 subId);


  function getSubscription(uint64 subId)
    external
    view
    returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );

  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;
  function acceptSubscriptionOwnerTransfer(uint64 subId) external;
  function addConsumer(uint64 subId, address consumer) external;
  function removeConsumer(uint64 subId, address consumer) external;
  function cancelSubscription(uint64 subId, address to) external;
  function pendingRequestExists(uint64 subId) external view returns (bool);
}

abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private immutable vrfCoordinator;
  constructor(address _vrfCoordinator) {
    vrfCoordinator = _vrfCoordinator;
  }

  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;
  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
  }
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

contract LotteryStaking is Ownable, ReentrancyGuard, VRFConsumerBaseV2 {
    using SafeERC20 for IERC20;
    using Address for address;

    IUniswapV2Router02 public uniswapV2Router;

    struct StakeInfo {
        uint256 amount;
        uint256 depositTime;
    }

    struct PoolInfo{
        uint256 interest;  
        uint256 lockPeriod;
        uint256 liveStakedAmount;
        uint256 totalContributed;
        bool isOpen;
    }

    IERC20 public stakedToken;
    PoolInfo public poolInfo;

    mapping(address => StakeInfo[]) public stakeInfo;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    constructor() VRFConsumerBaseV2(vrfCoordinator){
        address router;
        if (block.chainid == 56) {
            router = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // BSC Pancake Mainnet Router
        } else if (block.chainid == 97) {
            router =  0xD99D1c33F9fC3444f8101754aBC46c52416550D1; // BSC Pancake Testnet Router
        } else if (block.chainid == 1 || block.chainid == 5) {
            router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // ETH Uniswap Mainnet % Testnet
        } else {
            revert();
        }
        
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        stakedToken = IERC20(0xE2320dD375C634AA06c6d06725233F9837afc043);//Testnet
        poolInfo = PoolInfo(1000,300,0,0,false);//Testnet
        uniswapV2Router = IUniswapV2Router02(router);//Testnet
        rewardToken = IERC20(0xF8e3Fdf0fB3795Cb506749E2580C6B4178E78341);//Testnet
        perEpoch = 15 minutes; //For test
        operator = msg.sender;
        ticketPrice=10;
        premiumTicketPrice=20;
    }

    function startTime() public onlyOwner{
        require(startEpoch == 0,"Start time is already set");
        startEpoch = block.timestamp;
        poolInfo.isOpen=true;
    }

    function claimStuckTokens(address _token) external onlyOwner {
        if (_token == address(0x0)) {
            payable(msg.sender).transfer(address(this).balance);
            return;
        }else if(address(rewardToken) == _token){
            rewardAmount=0;
            bigRewardAmount=0;
        }
        IERC20 erc20Token = IERC20(_token);
        uint256 balance = erc20Token.balanceOf(address(this));
        erc20Token.transfer(msg.sender, balance);
    }

    function addReward() external returns(bool){
        rewardAmount = rewardToken.balanceOf(address(this));
        return true;
    }

//=======Staking Process=======//
    function poolChange(PoolInfo memory  _pool) external onlyOwner{
        poolInfo = _pool;
    }

    //=======Stake View Operations=======//
    function pendingReward(uint256 _stakeId, address _user) public view returns (uint256) {
        StakeInfo memory stake = stakeInfo[_user][_stakeId];
        PoolInfo memory pool = poolInfo;
        
        uint256 lockedTime = block.timestamp > stake.depositTime + pool.lockPeriod ? pool.lockPeriod : block.timestamp - stake.depositTime;
        uint256 reward = (((stake.amount * pool.interest)  * lockedTime) / pool.lockPeriod) / 10_000;
        return reward;
    } 

    function canWithdraw(uint256 _stakeId, address _user) public view returns (bool) {
        return (withdrawCountdown(_stakeId,_user)==0 && stakeInfo[_user][_stakeId].amount > 0);
    }

    function withdrawCountdown(uint256 _stakeId, address _user) public view returns (uint256) {
        StakeInfo storage stake = stakeInfo[_user][_stakeId];
        PoolInfo  storage pool = poolInfo;
        if ((block.timestamp < stake.depositTime + pool.lockPeriod)){
            return stake.depositTime + pool.lockPeriod -  block.timestamp;
        }else{
            return 0;
        }
    }

    function userInfo(uint256 stakeId, address _user) public view returns(uint256,uint256,uint256,uint256) {
        StakeInfo storage stake = stakeInfo[_user][stakeId];
        PoolInfo storage pool = poolInfo;
        return (stake.amount, stake.depositTime, pool.interest, pool.lockPeriod);
    }

    function getAllUserInfo(address _user) public view returns(uint256[] memory) {
        StakeInfo[] storage stake = stakeInfo[_user];
        PoolInfo storage pool = poolInfo;
        uint256 lenghtOfStake = 0;
         for(uint256 i = 0; i < stake.length; ++i)
             if(stake[i].amount>0)
                lenghtOfStake+=1;
            
        uint256[] memory information = new uint256[](lenghtOfStake*7);
        uint256 j=0;
        for(uint256 i = 0; i < stake.length; ++i){
            if(stake[i].amount>0){
                information[j*7+0]=stake[i].amount;
                information[j*7+1]=stake[i].depositTime;
                information[j*7+2]=pool.interest;
                information[j*7+3]=pool.lockPeriod;
                information[j*7+4]=i;
                information[j*7+5]=pendingReward(i,_user);
                information[j*7+6]=canWithdraw(i,_user)? 1 : 0;
                j+=1;
            }
        }
        return information;
    }

    //=======Deposit&Withdraw=======//
    function deposit()  payable public nonReentrant{
        (,uint256 ticketPriceForUser,) =getPrice(msg.sender);
        uint256 numberOftickets = msg.value / (ticketPriceForUser * 1e15);
        require (numberOftickets> 0, "You should buy at least 1 ticket");
        PoolInfo storage pool = poolInfo;
        require(pool.isOpen,'pool is closed');
        require(msg.value % (ticketPriceForUser * 1e15) == 0, 'ticket amount not match');


        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(stakedToken);

        uint initialBalance = stakedToken.balanceOf(address(this));
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 _amount = stakedToken.balanceOf(address(this)) - initialBalance;

        pool.liveStakedAmount += _amount;
        
        stakeInfo[msg.sender].push(StakeInfo({
            amount: _amount,
            depositTime: block.timestamp
        }));

        if(stakeInfo[msg.sender].length==1){
            pool.totalContributed+=1;
        }
        emit Deposit(msg.sender, _amount);

        //Stake is Complete, its turn on lottery
        Lottery storage currentLottery = n_lottery[currentLotteryNumber];

        require(!currentLottery.isEnded ,"Lottery is ended");


        currentLottery.soldTicket += numberOftickets;
        require(currentLottery.soldTicket<900_000,"Tickets are sold out");
        if(currentLottery.holderTicket[msg.sender]==0){ 
            uint256 ticket=uint256(keccak256(abi.encodePacked(msg.sender,msg.value,block.timestamp)))%900_000 + 100_000;
            while(currentLottery.ticketOwner[ticket]!=address(0)){
                ticket+=1;
            }
            currentLottery.ticketOwner[ticket]=msg.sender;
            currentLottery.holderTicket[msg.sender]=ticket;
            currentLottery.tickets.push(Ticket({
                ticketNumber:ticket,
                power:numberOftickets,
                owner:msg.sender
            }));
        }else{
            for(uint256 i=0;i<currentLottery.tickets.length;i++){
                if(currentLottery.tickets[i].owner==msg.sender){
                    currentLottery.tickets[i].power+=numberOftickets;
                    break;
                }
            }
        }   
        emit BuyTicket(msg.sender, numberOftickets);
    }

    function withdraw(uint256 _stakeId) public nonReentrant{
        require(canWithdraw(_stakeId,msg.sender),'cannot withdraw yet or already withdrawn');
        StakeInfo storage stake = stakeInfo[msg.sender][_stakeId];
        PoolInfo storage pool = poolInfo;
        
        uint256 _amount = stake.amount;
        pool.liveStakedAmount -= _amount;
        
        uint256 _pendingReward = pendingReward(_stakeId, msg.sender);

        _amount += _pendingReward;
        stake.amount=0;

        stakedToken.safeTransfer(address(msg.sender), _amount);

        emit Withdraw(msg.sender, _amount);
    }


//=======Lottery=======//

    VRFCoordinatorV2Interface COORDINATOR;
    address vrfCoordinator = address(0x6A2AAd07396B36Fe02a22b33cf443582f682c82f);//Testnet
    bytes32 keyHash = 0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314;
    
    uint64 s_subscriptionId = 1654;
    uint32 numWords =  1;
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    uint256[] public s_randomWords;
    uint256 public s_requestId;


    struct Lottery{
        address lotteryWinner;
        uint256 winnerTicket; 
        Ticket[] tickets;
        uint256 soldTicket;
        bool isEnded;
        mapping(uint256 => address) ticketOwner;
        mapping(address => uint256) holderTicket;
        uint256 winnerRewardAmount;
        uint256 drawDate;
    } 

    struct Ticket{
        uint256 ticketNumber;
        uint256 power;
        address owner;
    }

    uint256 private startEpoch;
    uint256 public currentLotteryNumber;
    uint256 public perEpoch; 
    IERC20 public rewardToken;
    uint256 public bigRewardAmount;
    uint256 public rewardAmount;
    uint256 public ticketPrice;
    uint256 public premiumTicketPrice;

    
    mapping(uint256 => Lottery) public n_lottery;
    mapping(address => mapping(uint256 => uint256)) public specialPrice;

    event BuyTicket(address _buyer, uint256 _amount);
    event NewTicketOwner(address _oldOwner, uint256 _ticketId);
    event LotteryWinner(uint256 week, address winner);

    address public operator;
    modifier onlyOperator(){
        require(operator == _msgSender(),"Caller is not the Operator");
        _;
    }

    function setSpecialPrice(address[] memory _user,uint256 _week, uint256 _price) external onlyOwner{
        require(_price>1 && _price<5000,"Price should be between 1 and 5000");

        for(uint256 i=0;i<_user.length;i++){
            specialPrice[_user[i]][_week]=_price;
        }
    }
    
    function setTicketsPrice(uint256 _ticketPrice,uint256 _premiumTicketPrice) external onlyOwner{
        premiumTicketPrice=_premiumTicketPrice;
        ticketPrice=_ticketPrice;
    }
   
    function getPrice(address _user) public view returns(bool,uint256,uint256){
        uint256 _price = 0;
        uint256 _realPrice = (currentLotteryNumber+1)%4==0? premiumTicketPrice:ticketPrice;
        bool isDiscount = false;
        if(specialPrice[_user][currentLotteryNumber]==0){
            _price=(currentLotteryNumber+1)%4==0? premiumTicketPrice:ticketPrice; 
        }else{
            _price=specialPrice[_user][currentLotteryNumber];
            isDiscount = true;
        }

        return (isDiscount,_price, _realPrice);
    }

    function lotteryTicketAirdrop(address[] memory _users, uint256[] memory numberOfTicket) external onlyOwner{
        Lottery storage currentLottery = n_lottery[currentLotteryNumber];
        require(!currentLottery.isEnded ,"Lottery is ended");
        uint256 sum=0;
        for(uint256 i=0;i<numberOfTicket.length;++i)
            sum+=numberOfTicket[i];
        
        currentLottery.soldTicket += sum;
        require(currentLottery.soldTicket<900_000,"Tickets are sold out");
        for(uint256 i=0;i<_users.length;i++){
            if(currentLottery.holderTicket[_users[i]]==0){ 
                uint256 ticket=uint256(keccak256(abi.encodePacked(_users[i],block.gaslimit,block.timestamp)))%900_000 + 100_000;
                while(currentLottery.ticketOwner[ticket]!=address(0)){
                    ticket+=1;
                }
                currentLottery.ticketOwner[ticket]=_users[i];
                currentLottery.holderTicket[_users[i]]=ticket;
                currentLottery.tickets.push(Ticket({
                    ticketNumber:ticket,
                    power:numberOfTicket[i],
                    owner:_users[i]
                }));
            }else{
                for(uint256 j=0;j<currentLottery.tickets.length;j++){
                    if(currentLottery.tickets[i].owner==_users[i]){
                        currentLottery.tickets[i].power+=numberOfTicket[i];
                        break;
                    }
                }
            }   
            emit BuyTicket(_users[i], numberOfTicket[i]);
        }

    }

    function setOperator(address _operator) public onlyOwner{
        operator = _operator;
    }

    function pickWinner() external onlyOperator{
        require(getNextDrawTime()==0 && startEpoch > 0, "Lottery hasn't been ended.");
        Lottery storage currentLottery = n_lottery[currentLotteryNumber];

        require(currentLottery.isEnded ,"Random number not generated");
        
        if(currentLottery.soldTicket == 0) {
            currentLottery.isEnded = true;
            emit LotteryWinner(currentLotteryNumber, address(0));
            currentLottery.winnerTicket = 0;
            currentLottery.drawDate = block.timestamp; 
            currentLotteryNumber += 1;
            return;
        }
      
        uint256 randomNumber = s_randomWords[0];
        uint256 winnerNTicket = randomNumber % currentLottery.soldTicket;

        uint256 winnerAmountThisRound = 0;

        for(uint256 i=0;i<currentLottery.tickets.length;++i){
            if(winnerNTicket<currentLottery.tickets[i].power){
                currentLottery.winnerTicket=currentLottery.tickets[i].ticketNumber;
                currentLottery.lotteryWinner=currentLottery.tickets[i].owner;
                break;
            }
            winnerNTicket-=currentLottery.tickets[i].power;
        }

        if(currentLottery.ticketOwner[currentLottery.winnerTicket] != address(0) && (currentLotteryNumber+1)%4==0){
            currentLottery.lotteryWinner = currentLottery.ticketOwner[currentLottery.winnerTicket];
            winnerAmountThisRound = rewardAmount + bigRewardAmount;
            rewardAmount= 0;
            bigRewardAmount = 0;

        }else if(currentLottery.ticketOwner[currentLottery.winnerTicket] != address(0)){
            currentLottery.lotteryWinner = currentLottery.ticketOwner[currentLottery.winnerTicket];
            winnerAmountThisRound = (rewardAmount * 80) / 100;
            bigRewardAmount += rewardAmount-winnerAmountThisRound;
            rewardAmount = 0;
        }
        currentLottery.winnerRewardAmount = winnerAmountThisRound;
        rewardToken.transfer(currentLottery.lotteryWinner, winnerAmountThisRound);

        
        currentLottery.drawDate = block.timestamp;        
        currentLotteryNumber+=1;
    }

    function requestRandomWords() internal returns (bool){
        s_requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        return true;
    }

    function random() external onlyOperator returns (bool) {
        require(!n_lottery[currentLotteryNumber].isEnded && getNextDrawTime()==0, "Lottery hasn't been ended.");
        (bool success, ) = (requestRandomWords(),"random number failed");
         if (success) {
            n_lottery[currentLotteryNumber].isEnded = true;
            return true;
        }
        return success;
    }

    function fulfillRandomWords(uint256, /* requestId */uint256[] memory randomWords) internal override {
        s_randomWords = randomWords;
    }

    receive() external payable {}

    function getNextDrawTime() public view returns (uint256){
        if(currentLotteryNumber ==0){
            if(startEpoch + perEpoch > block.timestamp)
                return startEpoch + perEpoch - block.timestamp;
        }else if (getDrawDate(currentLotteryNumber-1) + perEpoch > block.timestamp){
            return getDrawDate(currentLotteryNumber-1) + perEpoch - block.timestamp;
        }
        return 0;
    }

    function getNextDrawTimeStamp() public view returns (uint256){
        if(currentLotteryNumber ==0){
            return startEpoch + perEpoch;
        }else{
            return getDrawDate(currentLotteryNumber-1) + perEpoch;
        }
    }

    function getDrawDate(uint256 _round) public view returns (uint256){
        return n_lottery[_round].drawDate;
    }

    function getTicketOwner(uint256 week, uint256 _ticket) public view returns (address){
        return n_lottery[week].ticketOwner[_ticket];
    }

    function getTicket(uint256 week, address _owner) public view returns (uint256){
        return n_lottery[week].holderTicket[_owner];
    }

    function getTicketThisWeek(address _owner) public view returns (uint256, uint256, uint256){
        Lottery storage currentLottery = n_lottery[currentLotteryNumber];
        uint256 change=0;
        for(uint256 i=0; i< currentLottery.tickets.length; ++i){
            if(currentLottery.tickets[i].owner == _owner){
                change = currentLottery.tickets[i].power;
                break;
            }
        }
        return (currentLottery.holderTicket[_owner],change,currentLottery.soldTicket);
    }

    function getWinnerHistory(uint256 _round) public view returns (uint256, uint256,uint256, uint256,uint256){
        Lottery storage currentLottery = n_lottery[_round];
        uint256 change=0;
        for(uint256 i=0; i< currentLottery.tickets.length; ++i){
            if(currentLottery.tickets[i].owner == getWinner(_round)){
                change = currentLottery.tickets[i].power;
                break;
            }
        }
        return (currentLottery.holderTicket[getWinner(_round)],change,currentLottery.soldTicket,currentLottery.winnerRewardAmount,getDrawDate(_round));
    }

    function getHolderHistory(address _user, uint256 _round) public view returns (uint256,uint256, uint256,uint256, uint256, uint256){
        Lottery storage currentLottery = n_lottery[_round];
        uint256 isWinner = 0;
        if(currentLottery.holderTicket[_user] == currentLottery.winnerTicket){
            isWinner = 1;
        }

        uint256 change=0;
        for(uint256 i=0; i< currentLottery.tickets.length; ++i){
            if(currentLottery.tickets[i].owner == _user){
                change = currentLottery.tickets[i].power;
                break;
            }
        }
        return (currentLottery.holderTicket[_user],isWinner,change,currentLottery.soldTicket,getDrawDate(_round),currentLottery.winnerRewardAmount); 
    }

    function getWinnerTickets(uint256 _round) public view returns (uint256){
        return n_lottery[_round].winnerTicket;
    }

    function getWinner(uint256 _round) public view returns (address){
        return n_lottery[_round].lotteryWinner;
    }

    function getLotteryInformation() public view returns(uint256,uint256,uint256){
        
        return (rewardAmount+bigRewardAmount, getNextDrawTimeStamp(), currentLotteryNumber);
    }

    function getBNBPrice(uint256 amountIn) public view returns(uint256){
        if(address(uniswapV2Router) == address(0)) {
            return 0;
        }
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(stakedToken);

        return uniswapV2Router.getAmountsOut(amountIn, path)[1];
    }

}