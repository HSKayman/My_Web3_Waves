
const ethers = require("ethers");
const request = require("request");
const contractAbi = require("./Abi.json");

const provider = new ethers.providers.JsonRpcProvider(
  "https://bsc-dataseed1.binance.org/"
);
const contractAddress = "0x9C51cA40e895225B84BbB37cAd385819644B208F";
const signer = new ethers.Wallet(process.env.PRIV_KEY, provider);
const contract = new ethers.Contract(contractAddress, contractAbi, signer);
let url = "https://api.telegram.org/bot" + "" + "/sendMessage"+"?chat_id=-695763426&text=";
let text=""


async function pickWinner() {

  while(true){
    text="FarmaRokLotteryScript is Running Now Everthing is gonna be okey dokey!"
    request.post(url+text);
    await new Promise((resolve) => setTimeout(resolve, 1000*60*60*24*7));
    text="FarmaRokLotteryScript is picking winner"
    request.post(url+text);
    let randomNumber
    try{
      randomNumber = await contract.s_randomWords(0);
    }catch{
      randomNumber = 0; 
    }
   
    let counter = 10;
    while(counter !=0){
      await new Promise((resolve) => setTimeout(resolve, 5000));
      counter = await contract.getNextDrawTime();
    }

    console.log("FarmaRok Before random number:", randomNumber);
    const Tx1 = await contract.random()
    await Tx1.wait()
    console.log("FarmaRok random Transaction:", Tx1);

    let randomNumber2=randomNumber;
    while(randomNumber==randomNumber2){
      await new Promise((resolve) => setTimeout(resolve, 5000));
      randomNumber2 = await contract.s_randomWords(0);
    }
    text="FarmaRokLotteryScript is picking winner"
    request.post(url+text);
    text="FarmaRokLotteryScript is succesfully picked winner"
    try{
      const Tx2 = await contract.pickWinner();
      await Tx2.wait();
      console.log("FarmaRok pick winner:", Tx2);
    }
      catch{
        text="FarmaRokLotteryScript is failed to pick winner"
      }

    request.post(url+text);
    let round = await contract.currentLotteryNumber();
    console.log("FarmaRok round:", round); 
  }
} 
await pickWinner()



//is 