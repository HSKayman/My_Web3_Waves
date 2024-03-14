const { ethers } = require("hardhat");

async function main() {

 const Lib = await ethers.getContractFactory("IterableMapping");
const lib = await Lib.deploy();
await lib.deployed();

  console.log("Deploying DividendTracker...");
  const dividendTracker = await DividendTracker.deploy();
  console.log("DividendTracker deployed at", dividendTracker.address);

  const COOKIE = await ethers.getContractFactory(
    "COOKIE",{
      libraries: {
           IterableMapping: lib.address,
        },
      }
  );
  console.log("Deploying COOKIE...");
  const cOOKIE = await upgrades.deployProxy(COOKIE);
  await cOOKIE.deployed();
  console.log("COOKIE deployed to:", cOOKIE.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
