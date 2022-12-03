require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config();

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  networks: {
    bscTest: {
      url: `https://bsc-testnet.public.blastapi.io`,
      gas: `auto` ,
      gasprice: `auto` ,
      accounts: [process.env.privateKey],
    },
    local: {
      url: `HTTP://127.0.0.1:7545`,
      gas: 493001600,
      accounts: [process.env.privateKey],
    },
  },
  solidity: {
    compilers: [
      { version: "0.8.17" }
    ]
  },
  etherscan: {
    apiKey: "FI4FYDT4IBJKUM6DQWJ33XGUUT74QPGQZ1"

  },
  
};
