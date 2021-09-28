import { expect } from "chai";
import { ethers } from "hardhat";
import { Random__factory } from "../../../typechain/factories/Random__factory";
import { ERC20FixedSupply__factory } from "../../../typechain/factories/ERC20FixedSupply__factory";
import { WETH9__factory } from "../../../typechain/factories/WETH9__factory";
import { getBalance } from "../../utils/numbers";
import {
  TransactionTypes,
  UnsignedTransaction,
} from "@ethersproject/transactions";
import { BigNumber } from "@ethersproject/bignumber";
import { TransactionRequest } from "@ethersproject/providers";
import { MyV2FlashLoan } from "../../../typechain/MyV2FlashLoan";
import { TransferNow__factory } from "../../../typechain/factories/TransferNow__factory";

describe("local testing Random contract", () => {
  it("should give 4 in return", async () => {
    const [owner] = await ethers.getSigners();
    const contract = await new Random__factory(owner).deploy();
    const tx = await contract.add(2);
    await tx.wait();
    const val = await contract.val();
    await expect(val.toString()).to.be.equal(
      ethers.BigNumber.from(4).toString()
    );
  });
});

describe("testing ethers utilities", async () => {
  it("should format 1 ether from big number to 1", async () => {
    expect(
      ethers.utils.formatEther(ethers.BigNumber.from("1000000000000000000"))
    ).to.be.equal(1 + ".0");
  });
  it("should parse 1 ether into bignumber", async () => {
    expect(ethers.utils.parseUnits("1.0", "ether")).to.be.equal(
      ethers.BigNumber.from("1000000000000000000")
    );
  });
});

describe("testing erc20", async () => {
  it("should add erc20 to random contract", async () => {
    const [owner] = await ethers.getSigners();
    const contract = await new Random__factory(owner).deploy();
    const token = await new ERC20FixedSupply__factory(owner).deploy();
    const balance = await token.balanceOf(owner.address);
    expect(ethers.utils.formatEther(balance)).to.be.equal("1000.0");
    const oneEthers = ethers.utils.parseUnits("1.0", "ether");
    // await token.approve(contract.address, oneEthers);
    const tx = await token.transfer(contract.address, oneEthers);
    await tx.wait();
    const contractBalance = await token.balanceOf(contract.address);
    expect(ethers.utils.formatEther(contractBalance)).to.be.equal("1.0");
  });

  // it("should deposit 1 ETH to contract", async () => {
  //     const [owner] = await ethers.getSigners();
  //     const contract = await new Random__factory(owner).deploy();
  //     const WETH = await new WETH9__factory(owner).deploy();
  //     const transfer = await new TransferNow__factory(owner).deploy();
  //     let balance: BigNumber;
  //     balance = await WETH.balanceOf(owner.address);
  //     expect(ethers.utils.formatEther(balance)).to.be.equal('0.0');
  //     balance = await getBalance({ signer: contract }, true) as BigNumber;
  //     expect(ethers.utils.formatEther(balance)).to.be.equal('0.0');
  //     const value = ethers.utils.parseEther("1.0");
  //     const req: TransactionRequest = {
  //         to: await contract.resolvedAddress,
  //         value
  //     }

  //     console.dir(req)
  //     const ownerEthBalance = await getBalance({ signer: owner });
  //     console.log("owner eth balance: ", ownerEthBalance);
  //     await expect(ownerEthBalance).to.be.greaterThan(5000);

  //     // const tx = await owner.sendTransaction(req)
  //     const tx = await transfer.connect(owner).now(contract.address, { value });
  //     balance = await getBalance({ signer: contract }, true) as BigNumber;
  //     expect(ethers.utils.formatEther(balance)).to.be.equal('1.0');

  // })
});
