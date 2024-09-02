require("@nomicfoundation/hardhat-ethers");
require("dotenv").config();

const { API_URL, PRIVATE_KEY } = process.env;

module.exports = {
  solidity: "0.8.26",
  networks: {
    sepolia: {
      url: API_URL, 
      accounts: [`0x${PRIVATE_KEY}`],
      chainId: 11155111,
    },
  },
};
