import { expect } from "chai";
import { ethers } from "hardhat";
import { MyV2FlashLoan, MyV2FlashLoan__factory } from "../../../typechain";
import { ERC20__factory } from "../../../typechain/factories/ERC20__factory";

let contract: MyV2FlashLoan;
describe("AAVE  FLASH LOAN", () => {
  before("Should create contract without failing", async () => {
    const [owner] = await ethers.getSigners();
    // should be a real provider address in kovan network

    const providerAddress = await (
      await new ERC20__factory(owner).deploy("fab", "fab")
    ).address;
    contract = await new MyV2FlashLoan__factory(owner).deploy(providerAddress);
  });

  it("needs to fail", async () => {
    expect(2).to.equal(1);
  });
});
