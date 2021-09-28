import { expect } from "chai";
import { ethers } from "hardhat";
import {
  MyV2FlashLoanInit,
  MyV2FlashLoanInit__factory,
} from "../../../typechain";
import { tokens } from "../../utils/addresses";
import { ERC20__factory } from "../../../typechain/factories/ERC20__factory";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ERC20 } from "../../../typechain/ERC20";
import { getBalance } from "../../utils/numbers";

// https://github.com/fifikobayashi
// contracts come mostly from her
// testing from @dujar

const daiAddress = tokens.dai.kovan;

let contract: MyV2FlashLoanInit, owner: SignerWithAddress, dai: ERC20;

describe("AAVE  FLASH LOAN INIT --- kovan", () => {
  before("Should create contract without failing", async () => {
    [owner] = await ethers.getSigners();
    // should be a real provider address in kovan network
    // https://docs.aave.com/developers/deployed-contracts/deployed-contracts
    const providerAddress = ethers.utils.getAddress(
      "0x88757f2f99175387ab4c6a4b3067c77a695b0349"
    );
    contract = await new MyV2FlashLoanInit__factory(owner).deploy(
      providerAddress
    );
    dai = await new ERC20__factory(owner).attach(daiAddress);
  });

  it("OWNER HAS DAI", async () => {
    const ownerTokenBalance = (await getBalance({
      signer: owner,
      contract: dai,
    })) as number;
    const decimals = Number(await dai.decimals());
    console.log({ ownerTokenBalance, decimals });
    expect(ownerTokenBalance).to.be.gt(0);
  });
  it("OWNER transfers DAI to CONTRACT", async () => {
    const tx = await dai.transfer(contract.address, getFee(100)[1]);
    await tx.wait();

    const balance = (await getBalance({
      contract: dai,
      signer: contract,
    })) as number;
    expect(balance).to.be.equal(getFee(100)[1]);
  });
});

function getFee(amountToBorrow = 100, f = false) {
  const aaveFee = 0.009 / 100;
  const amount = ethers.utils.parseUnits(amountToBorrow + ".0", "ether");
  const feePayBack = amountToBorrow * aaveFee;
  const amountFeeFlashloan = ethers.utils.parseUnits(
    feePayBack + ".0",
    "ether"
  );
  if (f) {
    return [amountToBorrow, feePayBack];
  } else {
    return [amount, amountFeeFlashloan];
  }
}
