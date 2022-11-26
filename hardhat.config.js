require("@nomiclabs/hardhat-waffle");
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
  },
  solidity: {
    compilers: [
      { version: "0.8.17" },
      { version: "0.7.6" },
      { version: "0.6.6" }
    ]
  },
};
