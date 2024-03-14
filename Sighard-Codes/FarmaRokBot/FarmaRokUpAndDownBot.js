
const ethers = require("ethers");
const contractAbi = require("./Abi.json");
var request = require('request');

const provider = new ethers.providers.JsonRpcProvider(
  "https://bsc-dataseed1.binance.org/"
);
require("dotenv").config()
const contractAddress = "0xF9421040a915E2115B2452428ecaF71020DBFEb3";
const signer = new ethers.Wallet(process.env.PRIV_KEY, provider);
const contract = new ethers.Contract(contractAddress, contractAbi, signer);
let url = "https://api.telegram.org/bot" + "5836327148:AAHwgNZLcHjCtHZt-s0yKa6yReyr69WvciM" + "/sendMessage" + "?chat_id=-695763426&text=";
let text = ""

async function pick() {
  text = "FarmaRokPredictionBot is Running Now Everthing is gonna be okey dokey!"
  request.post(url + text);
  await new Promise((resolve) => setTimeout(resolve, 900000 - (Date.now() % 900000)));
  while (true) {
    console.log("genesisStartRound");
    let tx = await contract.genesisStartRound();
    console.log("Waiting for transaction to be mined...");
    let second = Date.now();
    await tx.wait();
    text = "FarmaRokPredictionBot is starting genesis round"
    request.post(url + text);

    console.log("Transaction mined!");
    second = second + 900100 - Date.now();
    await new Promise((resolve) => setTimeout(resolve, second));

    console.log("genesisLockRound");
    tx = await contract.genesisLockRound();
    console.log("Waiting for transaction to be mined...");
    second = Date.now();
    await tx.wait();
    text = "FarmaRokPredictionBot is locking genesis round"
    request.post(url + text);

    console.log("Transaction mined!");
    second = second + 900100 - Date.now();

    while (true) {
      await new Promise((resolve) => setTimeout(resolve, second));
      console.log("executeRound");


      let currentRound = await contract.currentEpoch();
      let round = currentRound;

      while (round == currentRound) {
        text = "FarmaRokPredictionBot is executing round"
        request.post(url + text);
        text = "FarmaRokPredictionBot is succesfully executed round"
        try {
          tx = await contract.executeRound();
          console.log("Waiting for transaction to be mined...");
          second = Date.now();
          await tx.wait();
          console.log("Transaction mined!");
        } catch {
          console.log("executeRound failed");
          text = "FarmaRokPredictionBot failed to execute round"
        }
        round = await contract.currentEpoch();
        console.log("currentRound:", round);
        request.post(url + text);
        second = second + 900100 - Date.now();

      }
    }
  }
}

pick()