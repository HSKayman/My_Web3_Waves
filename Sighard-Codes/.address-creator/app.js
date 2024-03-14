const Web3 = require('web3')
const readline = require('readline')

const WalletInfo = require('./WalletInfo')
const web3 = new Web3("https://bsc-dataseed.binance.org/");
const rl = readline.createInterface(process.stdin, process.stdout);


 rl.question('Hey ContractChecker Dev Team! What is the name of project ?', async (response) => {
    

     let newAccount  = web3.eth.accounts.create(web3.utils.randomHex(32));
	let wallet = web3.eth.accounts.wallet.add(newAccount);

	let keystore = wallet.encrypt(web3.utils.randomHex(32));
	let privateKey = keystore.crypto.mac;
	let newAddress = web3.eth.accounts.privateKeyToAccount(privateKey).address;
    console.log('Your new wallet for deploy is '+ privateKey);

    console.log('Public key ' + newAddress);
    try {
    console.log('Wallet information saved in the database !')
    }catch(err){
        console.log('Error with the sync of database... Please regenerate a wallet because the current is not stored');
    }
    process.exit();
 })

