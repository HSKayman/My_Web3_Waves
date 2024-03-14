const { ethers } = require("hardhat");

async function main() {
    const contract = await ethers.getContractFactory(
        "LMSTracker",
      );
      console.log("Deploying LMSTracker...");
    
      const deployedC = await upgrades.deployProxy(contract);
      await deployedC.deployed();
      console.log(deployedC.address);
    }

main()
.then(() => process.exit(0))
.catch((error) => {
    console.error(error);
    process.exit(1);
});
