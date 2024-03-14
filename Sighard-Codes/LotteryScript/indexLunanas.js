
const ethers = require("ethers");
const contractAbi = require("./Abi.json");
var request = require('request');
const provider = new ethers.providers.JsonRpcProvider(
  "https://bsc-dataseed1.binance.org/"
);
require("dotenv").config()
const contractAddress = "0x38f3a7Ee701A9da93ac41f80991d629fE9d5e270";
const signer = new ethers.Wallet(process.env.PRIV_KEY2, provider);
const contract = new ethers.Contract(contractAddress, contractAbi, signer);


async function pickWinner() {

  while(true){
    await new Promise((resolve) => setTimeout(resolve, ((60*60*24*1000) - (Date.now()-(60*60*14*1000)) % (60*60*24*1000))));
    let randomNumber
    try{
      randomNumber = await contract2.s_randomWords(0);
    }catch{
      randomNumber = 0; 
    }
  
    let counter = 10;
    while(counter !=0){
      await new Promise((resolve) => setTimeout(resolve, 5000));
      counter = await contract.getNextDrawTime();
    }

    console.log("LunanasLottery Before random number:", randomNumber);
    const Tx1 = await contract.random()
    await Tx1.wait()
    console.log("LunanasLottery random Transaction:", Tx1);

    let randomNumber2=randomNumber;
    while(randomNumber==randomNumber2){
      await new Promise((resolve) => setTimeout(resolve, 5000));
      randomNumber2 = await contract.s_randomWords(0);
    }

    const amount = await contract.totalRewards();
    const Tx2 = await contract.pickWinner();
    await Tx2.wait();
    console.log("LunanasLottery pick winner:", Tx2);


    let round = await contract.currentLotteryNumber();
    console.log("LunanasLottery round:", round);

    let bigWinner = await contract.getWinner(round-1);
    let winnerTicket = await contract.getWinnerTickets(round-1);
    let message = round + ". LunanasLottery \nwinner: " + bigWinner + "\nwith ticket: " + '0000'.substr( String(winnerTicket).length ) + winnerTicket + "\namount: $" + (amount*0.65)/1e18 + "\nMatched Three Price Pot: $"+ (amount*0.3)/1e18;
    console.log(message);
    const llink ="https://api.telegram.org//sendMessage?chat_id=@LunanasLottery&&text="+message;
    await request.post(llink);
    console.log(llink);
    
  }
} 

await pickWinner()