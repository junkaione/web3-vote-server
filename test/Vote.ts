import { expect } from "chai";
import { ethers } from "hardhat";

describe("Vote", function () {
  const useVote = async () => {
    const Vote = await ethers.getContractFactory("Vote");
    const vote = await Vote.deploy(["刘能", "赵四", "张三"]);

    return vote;
  };

  it("Deployment", async function () {
    const [owner] = await ethers.getSigners();

    const vote = await useVote();

    expect(await vote.host()).equal(owner.address);
  });

  it("board", async function () {
    const vote = await useVote();

    expect((await vote.getBoardInfo()).length).equal(3);
  });

  it("vote", async function () {
    const [, addr1] = await ethers.getSigners();

    const vote = await useVote();
    await vote.mandate([addr1]);

    await vote.connect(addr1);
    await vote.vote(0);
    expect((await vote.getBoardInfo())[0][1]).equal(1n);
  });
});
