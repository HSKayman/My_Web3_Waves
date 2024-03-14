const ethers = require("ethers");
const { Client, GatewayIntentBits } = require('discord.js');
const { token } = require('./config.json');

// Create a new client instance
const client = new Client({ intents: [GatewayIntentBits.Guilds] });

// When the client is ready, run this code (only once)
client.once('ready', () => {
	console.log('Ready!');
});

// Login to Discord with your client's token
client.login(token);
const provider = new ethers.providers.JsonRpcProvider(
  "https://bsc-dataseed1.binance.org/"
);
const contractAbi = require("./Abi.json");
require("dotenv").config()

console.log(process.env.A);
console.log(process.env.B);
console.log(process.env.DISCORD_TOKEN);
const contractAddress = "0x38f3a7Ee701A9da93ac41f80991d629fE9d5e270";
//const signer = new ethers.Wallet(process.env.PRIV_KEY2, provider);
const contract = new ethers.Contract(contractAddress,contractAbi);
async function checkBalance(account) {
    const balance = await contract.balanceOf(account);
    return balance;
}

async function s() {

    while(true){


    
  } 
}
