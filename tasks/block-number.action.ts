import hre from "hardhat"
import { HardhatRuntimeEnvironment } from "hardhat/types/hre";
import { TaskArguments } from "hardhat/types/tasks";

export default async function blockNumberAction(
    _taskArgs: TaskArguments,
    hre: HardhatRuntimeEnvironment
): Promise<void> {
    const { ethers } = await hre.network.connect();
    const blockNumber = await ethers.provider.getBlockNumber();
    console.log(`Current Block Number is: ${blockNumber}`);
}
