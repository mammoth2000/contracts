require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config();

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  networks: {
    aurora: {
      url: `https://mainnet.aurora.dev`,
      gas: `auto` ,
      gasprice: `auto` ,
      accounts: [process.env.privateKey],
    },
    fantom: {
      url: `https://rpcapi.fantom.network`,
      accounts: [process.env.privateKey],
    },
    bscTest: {
      url: `https://bsc-testnet.public.blastapi.io`,
      gas: `auto` ,
      gasprice: `auto` ,
      accounts: [process.env.privateKey],
    },
  },
  solidity: {
    compilers: [
      { version: "0.8.17" },
      { version: "0.7.6" },
      { version: "0.6.6" }
    ]
  },
  etherscan: {
    apiKey: "FI4FYDT4IBJKUM6DQWJ33XGUUT74QPGQZ1"

  },
  
};
