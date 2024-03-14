//var BigNumber = require(bignumber.js);
require("dotenv").config()
var ethers = require("ethers");
const contractAbi = require("./Abi.json");
const provider = new ethers.providers.JsonRpcProvider(
  "https://data-seed-prebsc-1-s1.binance.org:8545/"
);
const contractAddress = "0x47384757152F3E28c162e4204AFb6BBe8Ea0Ce8b";
const signer = new ethers.Wallet(process.env.PRIV_KEY1, provider);
const contract = new ethers.Contract(contractAddress, contractAbi, signer);
let wallets = require("./Wallet.json")


async function pickWinner() {
 console.log('aasdasd')
  let balance = await contract.mint(wallets.WalletAddress,(10000000000000000).toString())
  console.log(balance)
  await balance.wait()
  console.log("minted 100 BUSD to", wallets.WalletAddress);
} 

pickWinner()

