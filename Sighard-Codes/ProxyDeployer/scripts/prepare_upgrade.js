async function main() {
  const proxyAddress = "0x6d342877fC199c629f49A5C6C521C297b15BC92d";

  const COOKIE = await ethers.getContractFactory(
    "COOKIE"
  );
  console.log("Preparing upgrade CookieTokenV2...");
  const newCookie = await upgrades.upgradeProxy(
    proxyAddress,
    COOKIE
  );
  console.log("COOKIE at:", newCookie);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
