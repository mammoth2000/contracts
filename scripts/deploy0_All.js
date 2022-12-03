const hre = require("hardhat");

async function main() {
  [owner] = await ethers.getSigners();
  console.log(`Owner: ${owner.address}`);
 const contractName0 = 'NetworkStack';

 await hre.run("compile");
 const smartContract0 = await hre.ethers.getContractFactory(contractName0);
 const contract0 = await smartContract0.deploy();
 await contract0.deployed();
 console.log(`${contractName0} deployed to: ${contract0.address}`); 

 const contractName1 = 'Mammoth';


 const BUSD = "0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7";
 const exchangeRouter = "0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3"
 const campaignPeriod = 300;


 const smartContract1 = await hre.ethers.getContractFactory(contractName1);
 const contract1 = await smartContract1.deploy(exchangeRouter, campaignPeriod);
 await contract1.deployed();
 console.log(`${contractName1} deployed to: ${contract1.address}`); 


 

 const mammoth = contract1.address;


 const contractName2 = 'IvoryDollar';

 const smartContract2 = await hre.ethers.getContractFactory(contractName2);
 const contract2 = await smartContract2.deploy();
 await contract2.deployed();
 console.log(`${contractName2} deployed to: ${contract2.address}`); 

 const contractName3 = 'IvoryReserve';


 const smartContract3 = await hre.ethers.getContractFactory(contractName3);
 const contract3 = await smartContract3.deploy(exchangeRouter, BUSD);
 await contract3.deployed();
 console.log(`${contractName3} deployed to: ${contract3.address}`); 


 const contractName4 = 'Graveyard';

 const smartContract4 = await hre.ethers.getContractFactory(contractName4);
 const mammothToken = mammoth;
 const contract4 = await smartContract4.deploy(mammothToken);
 await contract4.deployed();
 console.log(`${contractName4} deployed to: ${contract4.address}`); 



 const contractName5 = 'LiquidityDrive';

 const smartContract5 = await hre.ethers.getContractFactory(contractName5);

 const contract5 = await smartContract5.deploy(mammothToken);
 await contract5.deployed();
 console.log(`${contractName5} deployed to: ${contract5.address}`); 

 const mammothCaller = await smartContract1.attach(
  contract1.address
);

 await mammothCaller.initialize(contract4.address,contract5.address);


const stackCaller = await smartContract0.attach(
  contract0.address
);

 await stackCaller.initialize(contract2.address,exchangeRouter,0,0,mammoth,contract4.address);

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
