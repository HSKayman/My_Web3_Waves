const { alchemyApiKey, privateKey } = require("./secrets.json");

require("@nomiclabs/hardhat-ethers");
require("@openzeppelin/hardhat-upgrades");

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    rinkeby: {
      url: `https://eth-rinkeby.alchemyapi.io/v2/${alchemyApiKey}`,
      accounts: [privateKey],
    },
    avaxTest:{
      url: `https://api.avax-test.network/ext/bc/C/rpc`,
      accounts: [privateKey],
    },
    testnetBSC: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
      accounts: [privateKey],
    },
    bscMainnet: {
      url: "https://bsc-dataseed3.binance.org/",
      accounts: [privateKey],
    },
  },
  etherscan: {
    apiKey: {
      rinkeby: "S5KFZ11NJTCIQ815S8R9W4V6VAMK8Z7FGS",
      bscTestnet: "UEZ8IJ7ZDCI1BNFVSNDB9XGMHAN5EC1VQG",
      bsc: "UEZ8IJ7ZDCI1BNFVSNDB9XGMHAN5EC1VQG",
    },
  },
};
