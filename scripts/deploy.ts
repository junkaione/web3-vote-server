import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const Vote = await ethers.getContractFactory("Vote");
  const vote = await Vote.deploy(["刘能", "赵四", "张三"]);

  console.log("Vote address:", await vote.getAddress());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
