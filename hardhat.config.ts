import dotenv from 'dotenv';

// Plugins
// import "@nomicfoundation/hardhat-toolbox"; 
import hardhatEthers from "@nomicfoundation/hardhat-ethers";
import hardhatVerify from "@nomicfoundation/hardhat-verify";
import hardhatToolboxMochaEthersPlugin from "@nomicfoundation/hardhat-toolbox-mocha-ethers";
import hardhatToolboxViemPlugin from "@nomicfoundation/hardhat-toolbox-viem";
import { configVariable, defineConfig } from "hardhat/config";

// Tasks
import blockNumberTask from './tasks/block-number.task.js';
dotenv.config()

export default defineConfig({
  plugins: [hardhatToolboxViemPlugin, hardhatVerify, hardhatEthers],
  tasks: [blockNumberTask],
  solidity: {
    profiles: {
      default: {
        version: "0.8.28",
      },
      production: {
        version: "0.8.28",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    },
  },
  networks: {
    hardhatMainnet: {
      type: "edr-simulated",
      chainType: "l1",
    },
    hardhatOp: {
      type: "edr-simulated",
      chainType: "op",
    },
    localhost:{
      url: "http://127.0.0.1:8545",
      chainId: 31337,
      type: "http"
    },
    sepolia: {
      type: "http",
      chainType: "l1",
      url: process.env.RPC_URL!,
      accounts: [process.env.PRIVATE_KEY!],
    },
  },
  verify:{
    etherscan:{
      apiKey: process.env.ETHERSCAN_API_KEY
    }
  }
});
