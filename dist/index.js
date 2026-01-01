import { JsonRpcProvider } from "ethers";
import { ethers } from "ethers";
import dotenv from 'dotenv';
import { Wallet } from "ethers";
import fs from "node:fs";
import { ContractFactory } from "ethers";
dotenv.config();
async function main() {
    const provider = new JsonRpcProvider(process.env.RPC_URL);
    const wallet = new Wallet(process.env.PRIVATE_KEY, provider);
    const abiPath = "./contracts_SimpleStorage_sol_SimpleStorage.abi";
    const binPath = "./contracts_SimpleStorage_sol_SimpleStorage.bin";
    const abi = fs.readFileSync(abiPath, "utf8");
    const bin = fs.readFileSync(binPath, "utf8");
    const contractFactory = new ContractFactory(abi, bin, wallet);
    const contract = await contractFactory.deploy({});
    await contract.deploymentTransaction()?.wait(1);
    const address = await contract.getAddress();
    console.log(`Address is: ${address}`);
    const currentFavNumber = await contract.retrieve();
    const transactionResponse = await contract.store("7");
    const transactionReceipt = await transactionResponse.wait(1);
    const updatedFavNumber = await contract.retrieve();
    console.log(`Current fav number is: ${currentFavNumber.toString()}`);
    console.log(`Current fav number is: ${updatedFavNumber.toString()}`);
}
main()
    .then(() => {
})
    .catch((error) => {
    console.error(error);
});
//# sourceMappingURL=index.js.map