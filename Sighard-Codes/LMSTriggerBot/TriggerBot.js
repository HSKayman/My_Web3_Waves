
const ethers = require("ethers");
const contractAbi = require("./Abi.json");
var request = require('request');



const provider = new ethers.providers.JsonRpcProvider(
  "https://bsc-dataseed1.binance.org/"
);
require("dotenv").config()
const contractAddress = "0x2ebaFc0ac04ad25998df1b4891cf700bDb25f71F";
const signer = new ethers.Wallet(process.env.PRIV_KEY, provider);
const contract = new ethers.Contract(contractAddress, contractAbi, signer);
let url = "https://api.telegram.org/bot" + "" + "/sendMessage"+"?chat_id=-708721695&&text=";

async function pick() {
  console.log("LMSTriggerBot is Running Now");
  let text= "LMSTriggerBot is Running Now"
  request.post(url+text);


  while (true) {
    await new Promise((resolve) => setTimeout(resolve, (604800000 - ((Date.now()) % 604800000))));
    let balance=0;
    text="LMS bot still running. Current balance:"
    try{
      balance = await provider.getBalance(signer.address);
      
    }catch{
      text="LMS bot is not running. Current balance:"
    }
    request.post(url+text+balance);
    
    await new Promise((resolve) => setTimeout(resolve, (604800000 - ((Date.now() - 158400000) % 604800000))));
    text="LMS rewards will be distributed in 1 hour";
    request.post(url+text);
    await new Promise((resolve) => setTimeout(resolve, (604800000 - ((Date.now() - 162000000) % 604800000))));

    text="LMSTriggerBot is Picking a Token that will be rewarded";
    request.post(url+text);

    let canClose = false;
    while (!canClose) {
      await new Promise((resolve) => setTimeout(resolve, 10000));
      canClose = await contract.canClose();
      console.log("CanClose now: " + canClose);
    }

    console.log("Contract Can Close");

    while (canClose) {
      text="Everything is OK";
      try {
        let tx = await contract.closeAndDistribute();
        await tx.wait();
        text+="\nTransaction Hash: "+"https://bscscan.com/tx/"+tx.hash;
      } catch {

        text="We Have a Problem in Contract";

      }

      request.post(url+text);
      await new Promise((resolve) => setTimeout(resolve, 10000));
      canClose = await contract.canClose();
      console.log("Can close: " + canClose);
    }
  }
}

pick()