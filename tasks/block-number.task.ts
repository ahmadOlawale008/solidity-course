import { task } from "hardhat/config"

export default task("block-number", "Gets the block number")
    .setAction(async () => await import("./block-number.action.js"))
    .build();