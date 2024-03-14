
const ethers = require("ethers");
const contractAbi = require("./Abi.json");

const provider = new ethers.providers.JsonRpcProvider(
  "https://bsc-dataseed1.binance.org/"
);
const contractAddress = "0x0C2487Da705fEeE8F7151D4e70D6AA8080b75289";
const signer = new ethers.Wallet(process.env.PRIV_KEY1, provider);
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

    console.log("dripmaxiLottery Before random number:", randomNumber);
    const Tx1 = await contract.random()
    await Tx1.wait()
    console.log("dripmaxiLottery random Transaction:", Tx1);

    let randomNumber2=randomNumber;
    while(randomNumber==randomNumber2){
      await new Promise((resolve) => setTimeout(resolve, 5000));
      randomNumber2 = await contract.s_randomWords(0);
    }

    const winnerTicket = parseInt(randomNumber2,16) % 10000;
    const amount = await contract.totalRewards();
    
    console.log("dripmaxiLottery random number:", winnerTicket);
    const Tx2 = await contract.pickWinner();
    await Tx2.wait();
    console.log("dripmaxiLottery pick winner:", Tx2);


    let round = await contract.currentLotteryNumber();
    console.log("dripmaxiLottery round:", round);

    let bigWinner = await contract.getWinner(round-1);
    let message = round + ". dripmaxiLottery \nwinner: " + bigWinner + "\nwith ticket: " + '0000'.substr( String(winnerTicket).length ) + winnerTicket + "\namount: $" + (amount*0.65)/1e18 + "\nMatched Three Price Pot: $"+ (amount*0.3)/1e18;
    console.log(message);
    const llink ="https://api.telegram.org/bot5639210889:AAEaEbcRLCq5jI8nXf_UvFBkzTaYBBwepyM/sendMessage?chat_id=@dripmaxiLottery&&text="+message;
    await request.post(llink);
    console.log(llink);
    
  }
} 
await pickWinner()