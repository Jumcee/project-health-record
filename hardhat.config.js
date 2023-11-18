module.exports = {
    solidity: {
      version: "0.8.0", // Specify your Solidity version
      settings: {
        optimizer: {
          enabled: true,
          runs: 200,
        },
      },
    },
    networks: {
      // Configure your networks here
      // For example:
      // hardhat: {},
      // ropsten: {
      //   url: "https://ropsten.infura.io/v3/YOUR_INFURA_API_KEY",
      //   accounts: [`0x${YOUR_PRIVATE_KEY}`],
      // },
    },
  };