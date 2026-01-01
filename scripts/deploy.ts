import hre, { network } from "hardhat";
import { verifyContract, VerifyContractArgs } from "@nomicfoundation/hardhat-verify/verify";
import dotenv from 'dotenv';
dotenv.config()

async function main() {
  const { viem, ethers, networkConfig } = await network.connect();


  const simpleStorageFactory = await ethers.getContractFactory("SimpleStorage");
  const contract = await simpleStorageFactory.deploy();
  await contract.waitForDeployment()
  const address = await contract.getAddress();

  console.log(`Deployed contract to: ${address}`)
  console.log(`Network Config: `, networkConfig)

  if (networkConfig.chainType === 'l1' && process.env.ETHERSCAN_API_KEY) {
    await contract.deploymentTransaction()?.wait(6)

    await verify(address)
  }

  const currentFavNumber = await (contract as any).retrieve();
  const transactionResponse = await (contract as any).store("7");
  const transactionReceipt = await transactionResponse.wait(1);
  const updatedFavNumber = await (contract as any).retrieve();

  console.log(`Current fav number is: ${currentFavNumber.toString()}`);
  console.log(`Current fav number is: ${updatedFavNumber.toString()}`);

}

async function verify(contractAddress: string, args?: any[]) {
  console.log("Verifying contract....")
  try {
    await verifyContract({
      address: contractAddress,
      constructorArgs: args,
      provider: "etherscan"
    }, hre)
  } catch (error: any) {
    if (error?.message?.toLowerCase().includes("already verified")) {
      console.log("Already deployed...")
    } else {
      console.error(error)
    }

  }
}

main()
  .then(() => {
    console.log("Deployed successfully")
  })
  .catch((error) => {
    console.error(error);
    process.exit(1)
  });
