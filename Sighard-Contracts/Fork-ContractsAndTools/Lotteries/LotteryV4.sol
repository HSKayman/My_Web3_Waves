// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

library Address {

      function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, 'Address: low-level call failed');
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

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

library SafeBEP20 {
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeBEP20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) - value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, 'SafeBEP20: low-level call failed');
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), 'SafeBEP20: BEP20 operation did not succeed');
        }
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

contract Context {
    constructor() {}

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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

contract GoldPayLottery is Ownable, ReentrancyGuard, VRFConsumerBaseV2 {
    using SafeBEP20 for IBEP20;
    using Address for address;

    //*****Configuration*****\\
    VRFCoordinatorV2Interface COORDINATOR;
    address vrfCoordinator = address(0x6A2AAd07396B36Fe02a22b33cf443582f682c82f);
    bytes32 keyHash = 0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314;
    
    uint64 s_subscriptionId = 1654;
    uint32 numWords =  1;
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    uint256[] public s_randomWords;
    uint256 public s_requestId;

    IBEP20 RewardToken;
    IUniswapV2Router02 public uniswapV2Router;

    bool    private swapping;
    uint256 public swapTokensAtAmount;
    uint256 public accumulatedFees;
    bool    public swapEnabled = true;

    uint8 public totalFee;
    uint8 public refereeFee;
    uint8 public burnFee;
    uint8 public marketingFee;

    address public marketingWallet;
    address private DEAD = 0x000000000000000000000000000000000000dEaD;
    address public goldPayToken;
    uint256 private startEpoch;
    uint256 private currentLotteryNumber;

    uint256[] private multiplier;
    uint256 private interval;
    uint8 private digitInterval;
    uint256 public ticketPrice;
    uint256 public swapTokenAmount;
    
    mapping(uint8 => address) public refereeAddress;
    uint256 public perEpoch; 
    mapping(address => uint256) public balances;
    uint256 public totalRewards;
    struct Lottery{
        address lotteryWinner;
        address[] _otherWinners;   
        uint256 soldTicket;
        uint256[] soldTickets;
        bool isEnded;
        mapping(uint256 => address) ticketOwner;
        mapping(address => uint256[]) holderTicket;
        mapping(uint8 => mapping(uint256 => address[])) pairedDigitTicketOwner; 
    } 
    //CanPickLotteryGetter
    mapping(uint256 => Lottery) public n_lottery;
    uint256 public countRandomNumber;

    event LotteryWinner(uint256 day, address winner);
    event LotteryBigWinner(uint256 day, address winner);
    event BuyTicket(address _buyer, uint256 _amount);
    event NewTicketOwner(address _oldOwner, uint256 _ticketId);
    event IntervalMultiplierChanged(uint256 _interval,uint256[] _multiplier);
    event TicketPriceChanged(uint256 _ticketPrice);
    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);
    event PerEpochChanged(uint256 _perEpoch);
    event MarketingWalletChanged(address _marketingWallet);
    event SwapEnabledChanged(bool _swapEnabled, uint256 _swapTokensAtAmount);
    event GoldPayTokenChanged(address _goldPayToken);
    event RewardTokenChanged(address _rewardToken);


    constructor() VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        startEpoch = block.timestamp;
        uniswapV2Router =IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        RewardToken = IBEP20(0x1DC9C98574565b48b1e3a5481FB2ca9fDE6BB54C);
        
        perEpoch = 50; //For test
        //share degil de totalFee
        refereeFee = 10;
        burnFee = 10;
        marketingFee = 10;
        totalFee  = refereeFee + burnFee + marketingFee;
        

        marketingWallet = 0xA8328A8bF82859e869Cd07eF87d8518e9901Be32;
        goldPayToken = 0xA8328A8bF82859e869Cd07eF87d8518e9901Be32;

        multiplier  =[4900,5100]; //4000
        interval    = 10000;
        digitInterval = 2;
        ticketPrice  = 3e18;
        operator = msg.sender;
        swapTokenAmount = 100 ether;
        transferOwnership(0xA8328A8bF82859e869Cd07eF87d8518e9901Be32);

    }
    address public operator;
    modifier onlyOperator(){
        require(operator == _msgSender(),"Caller is not the Operator");
        _;
    }

    function setReferee(uint8 _code,address _address) external onlyOwner{
        require(refereeAddress[_code] != _address,"Referee already set");
        refereeAddress[_code] = _address;
    }

    function setOperator(address _operator) public onlyOperator{
        operator = _operator;
    }

    function setSwapTokenAmount(uint256 _swapTokenAmount) public onlyOwner{
        require((_swapTokenAmount != swapTokenAmount),"Swap token amount already set");
        swapTokenAmount = _swapTokenAmount;
    }

    function pickWinner() external onlyOperator {
        require(getNextDrawTime()==0, "Lottery hasn't been ended.");
        _pickWinner();
    }

    function _pickWinner() internal {
        Lottery storage currentLottery = n_lottery[currentLotteryNumber];
        if(currentLottery.soldTicket == 0) {
            currentLottery.isEnded = true;
            emit LotteryWinner(currentLotteryNumber, address(0));
            currentLotteryNumber += 1;
            return;
        }
      
        uint256 randomNumber = s_randomWords[0];
        uint256 winnerTicket = randomNumber % interval;
        if(currentLottery.ticketOwner[winnerTicket]!= address(0)){
            currentLottery.lotteryWinner = currentLottery.ticketOwner[winnerTicket];
            balances[currentLottery.lotteryWinner]+=(totalRewards * multiplier[0])/10_000;
            //RewardToken.transfer(currentLottery.lotteryWinner, (currentLottery.totalRewards * multiplier[0])/10_000);
            emit LotteryBigWinner(currentLotteryNumber, currentLottery.lotteryWinner);
        }


        for(uint8 j=digitInterval; j>0; --j){
            winnerTicket/=10;
            uint256 length = currentLottery.pairedDigitTicketOwner[j][winnerTicket].length;
            
            if(length!=0){
                uint256 reward = (totalRewards * multiplier[j])/(10_000 * length);
                for(uint256 i=0; i< length; ++i){
                    currentLottery._otherWinners.push(currentLottery.pairedDigitTicketOwner[j][winnerTicket][i]);
                    balances[currentLottery.pairedDigitTicketOwner[j][winnerTicket][i]]+=reward;
                    //RewardToken.transfer(currentLottery.pairedDigitTicketOwner[j][winnerTicket][i],reward);
                    emit LotteryWinner(currentLotteryNumber, currentLottery.pairedDigitTicketOwner[j][winnerTicket][i]);
                }
            }
        }
            currentLottery.isEnded=true;
            currentLotteryNumber+=1;
        }
        
    function swap() internal{

        bool canSwap = accumulatedFees >= swapTokenAmount;

        if( canSwap && !swapping && swapEnabled) {
            swapping = true;
            address[] memory path = new address[](3);
                path[0] = address(RewardToken);
                path[1] = uniswapV2Router.WETH();
                path[2] = address(goldPayToken);

            uniswapV2Router.swapExactTokensForTokens(
                    accumulatedFees,
                    0,
                    path,
                    DEAD,
                    block.timestamp);
            accumulatedFees = 0;
            swapping = false;
        }
    }

    function buyTicket(uint256[] memory tickets, uint8 _code) public nonReentrant{
        //uint256 _currentLotteryNumber = (block.timestamp - startEpoch) / perEpoch;

        Lottery storage currentLottery= n_lottery[currentLotteryNumber];
        uint256 _ticketPrice = tickets.length * ticketPrice;

        RewardToken.safeTransferFrom(address(msg.sender), address(this), _ticketPrice);
        currentLottery.soldTicket += tickets.length;
        if(totalFee > 0){
            uint256 fee = (_ticketPrice * totalFee) / 100; 
            _ticketPrice -= fee;
            if(refereeAddress[_code]!=address(0) && refereeFee > 0){
                uint256 refFee = (fee * refereeFee) / totalFee;
                //balances[refereep[_code]]+=refFee;
                RewardToken.transfer(refereeAddress[_code],refFee);
                fee-=refFee;
            }

            if(burnFee>0){
                uint256 burnTokens = (fee * burnFee) / totalFee;
                accumulatedFees+=burnTokens;
                fee-=burnTokens;
            }
            RewardToken.transfer(marketingWallet, fee);
            swap();
        }
        totalRewards += _ticketPrice;
        uint256 ticket;
        for (uint256 i = 0; i < tickets.length; ++i) {
            ticket = tickets[i];
            require(currentLottery.ticketOwner[ticket] == address(0) && ticket < interval ,"Ticket is already owned or out of range");
            currentLottery.ticketOwner[ticket] = address(msg.sender);
            currentLottery.holderTicket[address(msg.sender)].push(ticket);
            currentLottery.soldTickets.push(ticket);
            for(uint8 j=digitInterval; j>0; --j){
                ticket/=10;
                currentLottery.pairedDigitTicketOwner[j][ticket].push(address(msg.sender));
                
            }
            emit NewTicketOwner(msg.sender,ticket);
        }
        emit BuyTicket(msg.sender, tickets.length);
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
        if(countRandomNumber==currentLotteryNumber){
            countRandomNumber+=1;
        }else{
            require(false,"Random number already requested");
        }
        (bool success, ) = (requestRandomWords(),"random number failed");
        return success;
    }

    function fulfillRandomWords(uint256, /* requestId */uint256[] memory randomWords) internal override {
        s_randomWords = randomWords;
    }

    receive() external payable {}

    function claimStuckTokens(address token) external onlyOwner {
        if (token == address(0x0)) {
            payable(msg.sender).transfer(address(this).balance);
            return;
        }
        if(token == address(RewardToken)){
            accumulatedFees=0;
        }
        IBEP20 BEP20token = IBEP20(token);
        uint256 balance = BEP20token.balanceOf(address(this));
        BEP20token.transfer(msg.sender, balance);
    }

    function changeMarketingWallet(address _marketingWallet) external onlyOwner {
        require(_marketingWallet != marketingWallet, "Marketing wallet is already that address");
        require(_marketingWallet != address(0), "Marketing wallet is the zero address");
        marketingWallet = _marketingWallet;
        emit MarketingWalletChanged(marketingWallet);
    }

    function changeGoldPlayToken(address _goldPayToken) external onlyOwner {
        require(_goldPayToken != address(goldPayToken), "GoldPay token is already that address");
        require(_goldPayToken != address(0), "GoldPay token is the zero address");
        goldPayToken = address(_goldPayToken);
        emit GoldPayTokenChanged(_goldPayToken);
    }

    function changeTicketPrice(uint256 _ticketPrice) external onlyOwner {
        require(_ticketPrice > 0, "Ticket price must be greater than 0");
        ticketPrice = _ticketPrice;
        emit TicketPriceChanged(ticketPrice);
    }

    function changedSwapSetting(bool _swapEnabled,uint256 _swapTokensAtAmount) external onlyOwner {
       require(swapTokensAtAmount == 0 || _swapEnabled,"swapTokensAtAmount must be 0 if swapEnabled is false");
        swapEnabled = _swapEnabled;
        swapTokensAtAmount = _swapTokensAtAmount;
        emit SwapEnabledChanged(swapEnabled,swapTokensAtAmount);
    }

    function setFees(uint8 _burnFee, uint8 _refereeFee, uint8 _marketingFee) external onlyOwner {
        burnFee = _burnFee;
        refereeFee = _refereeFee;
        marketingFee = _marketingFee;
        totalFee = _burnFee + _refereeFee + _marketingFee;
    }

    function changeIntervalMultiplier(uint256 _interval,uint256[] memory _multiplier) external onlyOwner {
        require(_interval > 0, "Interval must be greater than 0");
        uint256 count=0;
        interval = _interval;
        while(_interval > 1){
            _interval/=10;
            count++;
        }
        digitInterval = uint8(count)-1;
        
        require(_multiplier.length == digitInterval+1, "Multiplier length must be equal to digit interval");

        uint256 sum=0;
        for(uint8 i=0; i<_multiplier.length; ++i){
            sum+=_multiplier[i];
        }
        require(sum==10000, "Sum of multiplier must be 10000");
        multiplier = _multiplier;
        emit IntervalMultiplierChanged(interval,multiplier);
    }

    function changeRewardToken(address _rewardToken) external onlyOwner {
        require(IBEP20(_rewardToken) != RewardToken, "Reward token is already that address");
        RewardToken = IBEP20(_rewardToken);
        emit RewardTokenChanged(address(RewardToken));
    }

    function updateUniswapV2Router(address newAddress) external onlyOwner {
        require(newAddress != address(uniswapV2Router), "The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
    }

    function getTicketOwner(uint256 day, uint256 _ticket) public view returns (address){
        return n_lottery[day].ticketOwner[_ticket];
    }

    function isValidTicket(uint256 day, uint256 _ticket) public view returns (bool){
        return n_lottery[day].ticketOwner[_ticket]==address(0);
    }

    function getTickets(uint256 day, address _owner) public view returns ( uint256[] memory){
        return n_lottery[day].holderTicket[_owner];
    }

    function getsoldTicket(uint256 day) public view returns ( uint256[] memory){
        return n_lottery[day].soldTickets;
    }

    function getNextDrawTime() public view returns (uint256){
        if(startEpoch + (currentLotteryNumber * perEpoch) > block.timestamp)
           return (startEpoch + (currentLotteryNumber * perEpoch) - block.timestamp);
        return 0;
    }
    
    function withdrawableAmount(address _user) public view returns (uint256){
        return balances[_user];
    }

    function claim(address _user) external onlyOwner{
        require(balances[_user]>0, "No balance to claim");
        RewardToken.transfer(_user, balances[_user]);
    }

    function claim() external{
        require(balances[msg.sender]>0, "No balance to claim");
        uint256 amount = balances[msg.sender];
        balances[msg.sender]=0;
        RewardToken.transfer(msg.sender, amount);

    }

    //For Testing
    function s_randomWordsSetter(uint256 _s_randomWords) external {
        s_randomWords[0]=_s_randomWords;
    }
}