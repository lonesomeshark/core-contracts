import { expect } from "chai";
import { ethers } from "hardhat";
import { MyV2FlashLoan, MyV2FlashLoan__factory } from "../../../typechain";
import { ERC20__factory } from "../../../typechain/factories/ERC20__factory";

let contract: MyV2FlashLoan;
describe("AAVE  FLASH LOAN", () => {
  before("Should create contract without failing", async () => {
    // const { } = ethers.getNetwork();
    const [owner] = await ethers.getSigners();
    // should be a real provider address in kovan network
    // https://docs.aave.com/developers/deployed-contracts/deployed-contracts
    const providerAddress = "0x88757f2f99175387ab4c6a4b3067c77a695b0349";
    contract = await new MyV2FlashLoan__factory(owner).deploy(providerAddress);
  });

  it("needs to fail", async () => {
    expect(2).to.equal(1);
  });
});
