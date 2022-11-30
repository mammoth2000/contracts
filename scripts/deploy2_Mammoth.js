const hre = require("hardhat");

async function main() {
  [owner] = await ethers.getSigners();
  console.log(`Owner: ${owner.address}`);
 const contractName = 'Mammoth';

 // args

 const exchangeRouter = "0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3"
 const campaignPeriod = 300;


 await hre.run("compile");
 const smartContract = await hre.ethers.getContractFactory(contractName);
 const contract = await smartContract.deploy(exchangeRouter, campaignPeriod);
 await contract.deployed();
 console.log(`${contractName} deployed to: ${contract.address}`); 

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
