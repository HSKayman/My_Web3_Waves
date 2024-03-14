const { ethers } = require("hardhat");

async function main() {
    const COOKIE = await ethers.getContractFactory(
        "LMSTracker",
      );
      console.log("Deploying COOKIE...");
    
      const cOOKIE = await upgrades.deployProxy(COOKIE);
      await cOOKIE.deployed();
      console.log(cOOKIE.address);
      cOOKIE.address
    }

main()
.then(() => process.exit(0))
.catch((error) => {
    console.error(error);
    process.exit(1);
});
