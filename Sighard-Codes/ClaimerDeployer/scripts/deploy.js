const { ethers } = require("hardhat");
const Web3 = require('web3')
const web3 = new Web3("https://bsc-dataseed.binance.org/");


async function main() {
  //let count=0;
  //const loto = await ethers.getContractAt("DripMaxiLottery","0xC185CcFE8E0f352d3867913E33BBC6c4d8D9f807");

  const token = await ethers.getContractFactory("Token");
  const tokenContract = await token.deploy("Token", "TKN",["0xA8328A8bF82859e869Cd07eF87d8518e9901Be32"]);
  await tokenContract.deployed();
  console.log("Token deployed to:", tokenContract.address);


  const claim = await ethers.getContractFactory("ClaimContract");
  const claimContract = await claim.deploy(tokenContract.address);//"0x27654E8e58aaE2e96A1839eCE740B12b476304f7");
  await claimContract.deployed();
  console.log("ClaimContract deployed to:", claimContract.address);

  //const tx=await tokenContract.mint(claimContract.address,10000)
  //tx.wait()
  //console.log("minted 10000 tokens to claim contract")
  let array=[]
  let array1=[]
  for(let i=0 ; i<10000 ; i++){
    let newAccount  = web3.eth.accounts.create(web3.utils.randomHex(32));
    let wallet = web3.eth.accounts.wallet.add(newAccount);

    let keystore = wallet.encrypt(web3.utils.randomHex(32));
    let privateKey = keystore.crypto.mac;
    let newAddress = web3.eth.accounts.privateKeyToAccount(privateKey).address;
    //console.log('Your new wallet for deploy is '+ privateKey);
    //const txset = await claimContract.setBalances(newAddress,1);
    //await txset.wait();
    console.log('Public key ' + newAddress);
    array.push(newAddress)
    array1.push(1)
  }
  console.log(array)
  let func={
		"inputs": [
			{
				"internalType": "address[]",
				"name": "addresses",
				"type": "address[]"
			},
			{
				"internalType": "uint256[]",
				"name": "amounts",
				"type": "uint256[]"
			}
		],
		"name": "setBalances",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	}

  var methodSignature = web3.eth.abi.encodeFunctionSignature(func);
  var encodedParameter = web3.eth.abi.encodeParameter("address[]", array).substring(2);
  var encodedParameter2 = web3.eth.abi.encodeParameter("uint256[]", array1).substring(2);

  var data = methodSignature //method signature
      + encodedParameter+encodedParameter2; //hex of input string without '0x' prefix

  let gas = await provider.estimateGas({
                                         from: owner.address,
                                         to: addr2.address,
                                         data: data,
                                         value: 0,
                                         function(estimatedGas, err) {
                                             console.log("estimatedGas: " + estimatedGas);
                                             console.log("Err:" + err);
                                         }
                                       });
  console.log("Gas: " + gas);

  // var fs=require('fs');
  // var data=fs.readFileSync('../NormalDeployer/balance.txt', 'utf8');
  // var words=JSON.parse(data);
  // //console.log(words);
  
  // var result = Object.keys(words).map((key) => [String(key), Number(words[key])]);
  // let address = [];
  // let amount = [];
  // let x=1000;
  // for(let i=0 ; i<result.length ; i++){
    
  //   address.push(result[i][0])
  //   amount.push(ethers.utils.parseUnits(String(result[i][1].toFixed(10)),"ether"))
  //   if(i%x==0 && i!=0){
  //     const tx = await claimContract.setBalances(address,amount);
  //     await tx.wait();
  //     address = [];
  //     amount = [];
  //     console.log(i);
  //   }
  // }
  // if(address.length>0){
  //   const tx = await claimContract.setBalances(address,amount);
  //   await tx.wait();
  //   address = [];
  //   amount = [];
  //   console.log();
  // }


  //const tx = await loto.startTime();
  //await tx.wait();
  //console.log("DripMaxiLottery start time:", tx);

  // const busd = await ethers.getContractAt("Token", "0x73A59d7b4D7d7316F0D933FA9739d9aAaAdEf98B");
  // const tx0 = await busd.mint("0xA8328A8bF82859e869Cd07eF87d8518e9901Be32", ethers.utils.parseEther("1000000000000000000000000000000000000"));
  // await tx0.wait()

  // console.log("minted 10000000000000000000000000000 BUSD to", "0xA8328A8bF82859e869Cd07eF87d8518e9901Be32");
  // const txf= await busd.approve(loto.address, ethers.utils.parseEther("1000000000000000000000000000000000000"));
  // await txf.wait();

  // while(count<2000){
    
  //   const ghghhg = await loto.accumulatedFees()
  //   console.log("accu:",parseInt(ghghhg,16)/1e18);

  //   for(let i=50;i<100;i++){
  //     let array =[]
  //     for(let j=0;j<50;j++){
  //       array.push(i*50+j);
  //     }
  //     const tx2 = await loto.buyTicket(array,0);
  //     await tx2.wait();
  //     console.log("DripMaxiLottery buy ticket:");
  //   }
  
  //   let randomNumber
  //   try{
  //     randomNumber = await loto.s_randomWords(0);
  //   }catch{
  //     randomNumber = 0; 
  //   }
  //   await new Promise((resolve) => setTimeout(resolve, 10*60*1000));
  //   console.log("DripMaxiLottery random number:", randomNumber);
  //   const tx3 = await loto.random()
  //   await tx3.wait()
  //   console.log("DripMaxiLottery random:", tx3);

  //   let randomNumber2=randomNumber;
  //   while(parseInt(randomNumber,16)===parseInt(randomNumber2,16)){
  //     console.log("DripMaxiLottery random number2:",parseInt(randomNumber,16), parseInt(randomNumber2,16));
  //     await new Promise((resolve) => setTimeout(resolve, 5000));
  //     randomNumber2 = await loto.s_randomWords(0);
  //   }
  //   console.log("DripMaxiLottery random number3:",randomNumber, randomNumber2);
  //   const x =await loto.pickWinner();
  //   await x.wait();
  //   console.log("DripMaxiLottery pick winner:", x);
  //   //const numbebebeb = await loto.countRandomNumber();
  //   //const asdas =await loto.getWinnerTickets(numbebebeb-1)
  //   await new Promise((resolve) => setTimeout(resolve, 15000));
  //   //console.log("DripMaxiLottery pick winner:", asdas);
  //   ++count;

  //}
}
  



main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
