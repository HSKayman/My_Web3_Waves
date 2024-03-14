// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

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

contract LunanasLottery is Ownable, ReentrancyGuard, VRFConsumerBaseV2 {
    using SafeBEP20 for IBEP20;
    using Address for address;

    //*****Configuration*****\\
    VRFCoordinatorV2Interface COORDINATOR;
    address vrfCoordinator = address(0xc587d9053cd1118f25F645F9E08BB98c9712A4EE);
    bytes32 keyHash = 0x17cd473250a9a479dc7f234c64332ed4bc8af9e8ded7556aa6e66d83da49f470;
    
    uint64 s_subscriptionId = 472;
    uint32 numWords =  1;
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    uint256[] public s_randomWords;
    uint256 public s_requestId;

    IBEP20 RewardToken;

    bool    private swapping;
    uint256 public swapTokensAtAmount;
    uint256 public accumulatedFees;
    bool    public swapEnabled;

    uint8 public totalFee;
    uint8 public refereeFee;
    uint8 public burnFee;
    uint8 public marketingFee;

    address public marketingWallet;
    address private DEAD = 0x000000000000000000000000000000000000dEaD;
    address public burnToken;
    uint256 private startEpoch;
    uint256 public currentLotteryNumber;

    uint256 public ticketPrice;
    uint256 public swapTokenAmount;
    uint256[2] public multiplier;
    mapping(uint8 => address) public refereeAddress;
    uint256 public perEpoch; 
    mapping(address => uint256) public balances;
    uint256 public totalRewards;
    struct Lottery{
        address lotteryWinner;
        uint256 winnerTicket;
        address[] _otherWinners;   
        uint256 soldTicket;
        uint256[] soldTickets;
        bool isEnded;
        mapping(uint256 => address) ticketOwner;
        mapping(address => uint256[]) holderTicket;
        mapping(uint256 => address[]) pairedThreeDigitTicketOwner; 
        uint256 drawDate;
    } 
    mapping(uint256 => Lottery) public n_lottery;

    event LotteryWinner(uint256 day, address winner);
    event LotteryBigWinner(uint256 day, address winner);
    event BuyTicket(address _buyer, uint256 _amount);
    event NewTicketOwner(address _oldOwner, uint256 _ticketId);
    event MultiplierChanged(uint256[2] _multiplier);
    event TicketPriceChanged(uint256 _ticketPrice);
    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);
    event MarketingWalletChanged(address _marketingWallet);
    event SwapEnabledChanged(bool _swapEnabled, uint256 _swapTokensAtAmount);
    event BurnTokenChanged(address _BURNToken);
    event RewardTokenChanged(address _rewardToken);


    constructor() VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);

        RewardToken = IBEP20(0xaB1a4d4f1D656d2450692D237fdD6C7f9146e814);
 

        swapEnabled = true;
        perEpoch = 1 days; 
        multiplier  =[6500,3000];
       
        refereeFee = 10;
        burnFee = 10;
        marketingFee = 10;
        totalFee  = refereeFee + burnFee + marketingFee;
        
        marketingWallet = 0x22010F1A28E910b4B5c742B5df9088D6e6050a19;
        burnToken = 0xaB1a4d4f1D656d2450692D237fdD6C7f9146e814;

        ticketPrice  = 3e18;
        operator = msg.sender;
        swapTokenAmount = 0;
        s_randomWords.push(0);
    }

    address public operator;
    modifier onlyOperator(){
        require(operator == _msgSender(),"Caller is not the Operator");
        _;
    }

    function startTime() public{
        require(operator == _msgSender() || owner() == _msgSender(),"Caller is not the Authorized");
        require(startEpoch == 0,"Start time is already set");
        startEpoch = block.timestamp;
    }

    function setReferee(uint8 _code,address _address) external onlyOwner{
        require(refereeAddress[_code] != _address,"Referee already set");
        refereeAddress[_code] = _address;
    }

    function setOperator(address _operator) public onlyOperator{
        require(_operator != address(0),"Invalid address");
        require(_operator != operator,"Already set");
        operator = _operator;
    }

    function setSwapTokenAmount(uint256 _swapTokenAmount) public onlyOwner{
        require(_swapTokenAmount != swapTokenAmount,"Swap token amount already set");
        swapTokenAmount = _swapTokenAmount;
    }

    function pickWinner() external onlyOperator{
        require(getNextDrawTime()==0 && startEpoch > 0, "Lottery hasn't been ended.");
        Lottery storage currentLottery = n_lottery[currentLotteryNumber];

        require(currentLottery.isEnded ,"Random number not generated");
      
        uint256 randomNumber = s_randomWords[0];
        uint256 winnerTicket = randomNumber % 10_000;

        uint256 winnerAmountThisRound;

        currentLottery.winnerTicket = winnerTicket;
        
        if(currentLottery.ticketOwner[winnerTicket]!= address(0)){
            currentLottery.lotteryWinner = currentLottery.ticketOwner[winnerTicket];
            balances[currentLottery.lotteryWinner]+=(totalRewards * multiplier[0])/10_000;
            winnerAmountThisRound += (totalRewards * multiplier[0])/10_000;
            emit LotteryBigWinner(currentLotteryNumber, currentLottery.lotteryWinner);
        }else{
            emit LotteryBigWinner(currentLotteryNumber, address(0));

        }
        winnerTicket/=10;
        uint256 length = currentLottery.pairedThreeDigitTicketOwner[winnerTicket].length;
        
        if(length>1){
            uint256 reward = (totalRewards * multiplier[1])/(10_000 * (length-1));
            for(uint256 i=0; i< length; ++i){
                if(currentLottery.lotteryWinner!=currentLottery.pairedThreeDigitTicketOwner[winnerTicket][i]){
                    currentLottery._otherWinners.push(currentLottery.pairedThreeDigitTicketOwner[winnerTicket][i]);
                    balances[currentLottery.pairedThreeDigitTicketOwner[winnerTicket][i]]+=reward;
                    winnerAmountThisRound += reward;
                    emit LotteryWinner(currentLotteryNumber, currentLottery.pairedThreeDigitTicketOwner[winnerTicket][i]);
                }
            }
        }
        
        totalRewards -= winnerAmountThisRound;
        currentLottery.drawDate = block.timestamp;
        currentLotteryNumber+=1;
    }
        
    function swap() internal{

        bool canSwap = accumulatedFees >= swapTokenAmount;

        if( canSwap && !swapping && swapEnabled) {
            swapping = true;
           IBEP20(burnToken).transfer(address(DEAD),accumulatedFees);

            accumulatedFees = 0;
            swapping = false;
            }
    }

    function buyTicket(uint256[] memory tickets, uint8 _code) public nonReentrant{
        require( startEpoch > 0, "Lottery hasn't been ended.");
        Lottery storage currentLottery= n_lottery[currentLotteryNumber];
        require(!currentLottery.isEnded ,"Lottery is ended");
        uint256 _ticketPrice = tickets.length * ticketPrice;

        require(RewardToken.balanceOf(msg.sender) > _ticketPrice, "Insufficient BUSD balance");
        RewardToken.safeTransferFrom(address(msg.sender), address(this), _ticketPrice);

        currentLottery.soldTicket += tickets.length;
        if(totalFee > 0){
            uint256 fee = (_ticketPrice * totalFee) / 100; 
            _ticketPrice -= fee;
            if(refereeAddress[_code]!=address(0) && refereeFee > 0){
                uint256 refFee = (fee * refereeFee) / totalFee;
                fee -= refFee;
                RewardToken.transfer(refereeAddress[_code],refFee);
            }

            if(burnFee>0){
                uint256 burnTokens = (fee * burnFee) / totalFee;
                accumulatedFees+=burnTokens;
                fee -= burnTokens;
            }
            RewardToken.transfer(marketingWallet, fee);
            swap();
        }
        totalRewards += _ticketPrice;
        uint256 ticket;
        for (uint256 i = 0; i < tickets.length; ++i) {
            ticket = tickets[i];
            require(currentLottery.ticketOwner[ticket] == address(0) && ticket < 10_000 ,"Ticket is already owned or out of range");
            currentLottery.ticketOwner[ticket] = address(msg.sender);
            currentLottery.holderTicket[address(msg.sender)].push(ticket);
            currentLottery.soldTickets.push(ticket);
            currentLottery.pairedThreeDigitTicketOwner[ticket/=10].push(address(msg.sender));
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
        require(!n_lottery[currentLotteryNumber].isEnded, "Lottery hasn't been ended.");
        (bool success, ) = (requestRandomWords(),"random number failed");
        n_lottery[currentLotteryNumber].isEnded = true;
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
            totalRewards=0;
        }
        if(token == address(burnToken)){
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

    function changeBurnToken(address _burnToken) external onlyOwner {
        require(_burnToken != address(burnToken), "burnToken token is already that address");
        require(_burnToken != address(0), "burnToken token is the zero address");
        burnToken = address(_burnToken);
        emit BurnTokenChanged(_burnToken);
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

    function changeIntervalMultiplier(uint256[2] memory _multiplier) external onlyOwner {
        multiplier = _multiplier;
        emit MultiplierChanged(multiplier);
    }

    function changeRewardToken(address _rewardToken) external onlyOwner {
        require(IBEP20(_rewardToken) != RewardToken, "Reward token is already that address");
        RewardToken = IBEP20(_rewardToken);
        emit RewardTokenChanged(address(RewardToken));
    }

    function getTicketOwner(uint256 day, uint256 _ticket) public view returns (address){
        return n_lottery[day].ticketOwner[_ticket];
    }

    function isValidTicket(uint256 _ticket) public view returns (bool){
        return n_lottery[currentLotteryNumber].ticketOwner[_ticket]==address(0);
    }

    function getTickets(uint256 day, address _owner) public view returns ( uint256[] memory){
        return n_lottery[day].holderTicket[_owner];
    }

    function getTicketsToday(address _owner) public view returns ( uint256[] memory){
        return n_lottery[currentLotteryNumber].holderTicket[_owner];
    }

    function getsoldTicket() public view returns ( uint256[] memory){
        return n_lottery[currentLotteryNumber].soldTickets;
    }

    function getNextDrawTime() public view returns (uint256){

        if(startEpoch + ((currentLotteryNumber + 1) * perEpoch) > block.timestamp)
           return (startEpoch + ((currentLotteryNumber + 1) * perEpoch) - block.timestamp);
        return 0 ;
    }
    
    function withdrawableAmount(address _user) public view returns (uint256){
        return balances[_user];
    }

    function claimOwner(address _user) external onlyOwner{
        require(balances[_user]>0, "No balance to claim");
        RewardToken.transfer(_user, balances[_user]);
        balances[_user] = 0;

    }
    function deposit(uint256 _amount) external onlyOwner{
        RewardToken.transferFrom(msg.sender, address(this), _amount);
        totalRewards+=_amount;
    }

    function claim() external nonReentrant {
        require(balances[msg.sender]>0, "No balance to claim");
        uint256 amount = balances[msg.sender];
        balances[msg.sender]=0;
        RewardToken.transfer(msg.sender, amount);
    }

    function getNextDraw() public view returns (uint256){
        return startEpoch + ((currentLotteryNumber + 1) * perEpoch);
    }

    function getDrawDate(uint256 _round) public view returns (uint256){
        return n_lottery[_round].drawDate;
    }

    function finishedRounds(uint256 _round) public view returns (uint256, uint256) {
        return (n_lottery[_round].winnerTicket, getDrawDate(_round));
    }

    function checkYourTickets(address _user, uint256 _round) public view returns (uint256[] memory, uint256[] memory){
        uint256[] memory tikcets = n_lottery[_round].holderTicket[_user];

        uint256 count = n_lottery[_round].holderTicket[_user].length;

        uint256[] memory isWinner = new uint256[](count);
        for(uint256 i = 0 ; i < count;++i){
            if(n_lottery[_round].holderTicket[_user][i] == n_lottery[_round].winnerTicket){
                isWinner[i] = 2;
            }else if((n_lottery[_round].holderTicket[_user][i] / 10) == (n_lottery[_round].winnerTicket / 10)){
                isWinner[i] = 1;
            }else{
                isWinner[i] = 0;
            }
        }

        return (tikcets,isWinner);
    }

    function getMatchFirstThree(uint256 _round) public view returns (uint256){
        return n_lottery[_round]._otherWinners.length;
    }

    function getWinnerTickets(uint256 _round) public view returns (uint256){
        return n_lottery[_round].winnerTicket;
    }

    function getWinner(uint256 _round) public view returns (address){
        return n_lottery[_round].lotteryWinner;
    }

}