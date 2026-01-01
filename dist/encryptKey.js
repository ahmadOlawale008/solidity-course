import { Wallet } from "ethers";
import { JsonRpcProvider } from "ethers";
import fs from 'node:fs';
import dotenv from 'dotenv';
dotenv.config();
async function main() {
    const provider = new JsonRpcProvider(process.env.RPC_URL);
    const wallet = new Wallet(process.env.PRIVATE_KEY, provider);
    const encryptedJSONKey = await wallet.encrypt(process.env.PRIVATE_KEY_PASSWORD, () => { });
    console.log(encryptedJSONKey);
    fs.writeFileSync("./encryptedKey.json", encryptedJSONKey);
}
main().then(() => {
    console.log("Encrypted key successfully");
}).catch(e => {
    console.log(e.message || "An error occured while encrypting contract key");
});
//# sourceMappingURL=encryptKey.js.map