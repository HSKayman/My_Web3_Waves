const { ethers } = require("hardhat");

async function main() {

  const Lib = await ethers.getContractFactory("IterableMappingUpgradeable");
  const lib = await Lib.deploy();
  await lib.deployed();

  console.log("IterableMappingUpgradeable deployed to:", lib.address);
  //////////////////
  const DividendTracker = await ethers.getContractFactory("DividendTracker",{
    libraries: {
      IterableMappingUpgradeable: lib.address,
    }
  });

  console.log("Deploying DividendTracker...");
  const dividendTracker = await upgrades.deployProxy(DividendTracker,{
    unsafeAllowLinkedLibraries: true
  });
  await dividendTracker.deployed();
  console.log("DividendTracker deployed at", dividendTracker.address);
/////////////////////////
  const COOKIE = await ethers.getContractFactory(
    "TOKI",
  );
  console.log("Deploying COOKIE...");

  const cOOKIE = await upgrades.deployProxy(COOKIE);
  await cOOKIE.deployed();
    ////////////////////////
  console.log("COOKIE deployed to:", cOOKIE.address);
  const tx = await dividendTracker.transferOwnership(cOOKIE.address);
  await tx.wait();
  /////////////////////////
  console.log("DividendTracker ownership transferred to COOKIE");
  await cOOKIE.updateDividendTracker(dividendTracker.address);
  console.log("DividendTracker address updated in COOKIE");
  /////////////////////////
  //tx = await cOOKIE.transferOwnership("0x0c935E43Adc96C9A9B7B814D9A070164e1150a72");
  //await tx.wait();
  //console.log("COOKIE ownership transferred to Timelock");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
