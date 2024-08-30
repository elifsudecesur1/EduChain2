require("dotenv").config();
require("@nomiclabs/hardhat-waffle");

module.exports = {
  solidity: "0.8.19",
  networks: {
    educhain: {
      url: "https://rpc.open-campus-codex.gelato.digital",
      chainId: 656476,
      accounts: [process.env.PRIVATE_KEY] // .env dosyasından özel anahtar alınıyor
    },
    arbitrumSepolia: {
      url: "https://sepolia-rollup.arbitrum.io/rpc",
      chainId: 421614,
      accounts: [process.env.PRIVATE_KEY] // .env dosyasından özel anahtar alınıyor
    }
  }
};
