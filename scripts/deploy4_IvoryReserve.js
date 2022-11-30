const hre = require("hardhat");

async function main() {
  [owner] = await ethers.getSigners();
  console.log(`Owner: ${owner.address}`);
 const contractName = 'IvoryReserve';
 await hre.run("compile");

 // args

 const router = "0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3"
 const BUSD = "0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7";

 const smartContract = await hre.ethers.getContractFactory(contractName);
 const contract = await smartContract.deploy(router, BUSD);
 await contract.deployed();
 console.log(`${contractName} deployed to: ${contract.address}`); 

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
