const hre = require("hardhat");

async function main() {
  [owner] = await ethers.getSigners();
  console.log(`Owner: ${owner.address}`);
 const contractName = 'LiquidityDrive';
 await hre.run("compile");
 const smartContract = await hre.ethers.getContractFactory(contractName);
 const mammothToken = "0x47999C36fc6f4057E65220f03bA78582F2a6e981";
 const contract = await smartContract.deploy(mammothToken);
 await contract.deployed();
 console.log(`${contractName} deployed to: ${contract.address}`); 

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
