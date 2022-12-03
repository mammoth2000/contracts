require(`dotenv`).config({
  path: `.env`
});
const hre = require("hardhat");
require("@nomiclabs/hardhat-etherscan");

async function main() {
  [owner] = await ethers.getSigners();
  console.log(`Owner: ${owner.address}`);

  // Arguments for deployment

  const BUSD = "0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7";
  const exchangeRouter = "0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3"
  const campaignPeriod = 300;

  // deployment of contract 0

  const contractName0 = 'NetworkStack';
  await hre.run("compile");
  const smartContract0 = await hre.ethers.getContractFactory(contractName0);
  const contract0 = await smartContract0.deploy();
  await contract0.deployed();
  console.log(`contract 0 deployed, verifying....`);

  // verification of contract 0

  try {
      await hre.run("verify:verify", {
          address: contract0.address,
          constructorArguments: [],
      });
  } catch (e) {
      console.log("NetworkStack didnt verify ");
  }

  // deployment of contract 1

  const contractName1 = 'Mammoth';
  const smartContract1 = await hre.ethers.getContractFactory(contractName1);
  const contract1 = await smartContract1.deploy(exchangeRouter, campaignPeriod);
  await contract1.deployed();
  console.log(`contract 1 deployed, verifying....`);

  // verification of contract 1

  try {
      await hre.run("verify:verify", {
          address: contract1.address,
          constructorArguments: [exchangeRouter, campaignPeriod],
      });
  } catch (e) {
      console.log("Mammoth didnt verify ");
  }

  // deployment of contract 2

  const mammoth = contract1.address;
  const contractName2 = 'IvoryDollar';
  const smartContract2 = await hre.ethers.getContractFactory(contractName2);
  const contract2 = await smartContract2.deploy();
  await contract2.deployed();
  console.log(`contract 2 deployed, verifying....`);

  // verification of contract 2

  try {
      await hre.run("verify:verify", {
          address: contract2.address,
          constructorArguments: [],
      });
  } catch (e) {
      console.log("IvoryDollar didnt verify ");
  }

  // deployment of contract 3

  const contractName3 = 'IvoryReserve';
  const smartContract3 = await hre.ethers.getContractFactory(contractName3);
  const contract3 = await smartContract3.deploy(exchangeRouter, BUSD);
  await contract3.deployed();
  console.log(`contract 3 deployed, verifying....`);

  // verification of contract 3

  try {
      await hre.run("verify:verify", {
          address: contract3.address,
          constructorArguments: [exchangeRouter, BUSD],
      });
  } catch (e) {
      console.log("IvoryReserve didnt verify ");
  }
  // deployment of contract 4

  const contractName4 = 'Graveyard';
  const smartContract4 = await hre.ethers.getContractFactory(contractName4);
  const mammothToken = mammoth;
  const contract4 = await smartContract4.deploy(mammothToken);
  await contract4.deployed();
  console.log(`contract 4 deployed, verifying....`);

  // verification of contract 4

  try {
      await hre.run("verify:verify", {
          address: contract4.address,
          constructorArguments: [mammothToken],
      });
  } catch (e) {
      console.log("Graveyard didnt verify ");
  }

  // deployment of contract 5

  const contractName5 = 'LiquidityDrive';
  const smartContract5 = await hre.ethers.getContractFactory(contractName5);
  const contract5 = await smartContract5.deploy(mammothToken);
  await contract5.deployed();
  console.log(`contract 5 deployed, verifying....`);

  // verification of contract 5

  try {
      await hre.run("verify:verify", {
          address: contract5.address,
          constructorArguments: [mammothToken],
      });
  } catch (e) {
      console.log("LiquidityDrive didnt verify ");
  }

  console.log(`${contractName0} deployed to: ${contract0.address}`);
  console.log(`${contractName1} deployed to: ${contract1.address}`);
  console.log(`${contractName2} deployed to: ${contract2.address}`);
  console.log(`${contractName3} deployed to: ${contract3.address}`);
  console.log(`${contractName4} deployed to: ${contract4.address}`);
  console.log(`${contractName5} deployed to: ${contract5.address}`);

  // calling initialize

  const mammothCaller = await smartContract1.attach(
      contract1.address
  );

  await mammothCaller.initialize(contract4.address, contract5.address);

  // calling initialize

  const stackCaller = await smartContract0.attach(
      contract0.address
  );

  await stackCaller.initialize(contract2.address, exchangeRouter, 0, 0, mammoth, contract4.address);

  // transfer ownership of Liquidity Drive

  const LiquidityDriveCaller = await smartContract5.attach(
    contract5.address
  );
  await LiquidityDriveCaller.transferOwnership(mammoth);



  // transfer ownership of Graveyard
  const GraveyardCaller = await smartContract4.attach(
      contract4.address
  );
  await GraveyardCaller.transferOwnership(mammoth);
  
  }

main()

  .then(() => process.exit(0))
  .catch((error) => {
      console.error(error);
      process.exit(1);
  });