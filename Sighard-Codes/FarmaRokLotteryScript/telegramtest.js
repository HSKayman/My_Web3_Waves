//var BigNumber = require(bignumber.js);
require("dotenv").config()
var ethers = require("ethers");
const contractAbi = require("./Abi.json");
const provider = new ethers.providers.JsonRpcProvider(
  "https://bsc-dataseed1.binance.org/"
);
const contractAddress = "0x38f3a7Ee701A9da93ac41f80991d629fE9d5e270";
const signer = new ethers.Wallet(process.env.PRIV_KEY2, provider);
const contract = new ethers.Contract(contractAddress, contractAbi, signer);



async function pickWinner() {
    let randomNumber2 = await contract.s_randomWords(0);
    console.log(randomNumber2);

} 

pickWinner()

