require("@nomiclabs/hardhat-waffle");
const fs = require('fs');
const privateKey = fs.readFileSync(".secret").toString();
const projectID = "51dff463ea2746fca93fcb3bd9ef0ff3";


/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  networks: {
    hardhat: {
      chainId: 6969,
    },
    mainnet: {
      url: `https://mainnet.infura.io/v3/${projectID}`,
      accounts: [privateKey],
    },
    ropsten: {
      url: `https://ropsten.infura.io/v3/${projectID}`,
      accounts: [privateKey],
    },
  },
  solidity: "0.8.9",
};
