import { BigNumber, BigNumberish } from "@ethersproject/bignumber";
import { expect } from "chai";
import { ethers } from "hardhat";
import { Greeter, Greeter__factory } from "../typechain";

let greeter: Greeter;
describe("Greeter", () => {
  it("Should return the new greeting once it's changed", async () => {
    const [owner] = await ethers.getSigners();
    greeter = await new Greeter__factory(owner).deploy("hello world");
    // const Greeter = await ethers.getContractFactory("Greeter");
    // const greeter = await Greeter.deploy("Hello, world!");
    // await greeter.deployed();
  });

  it("setPostfixGreeting to _byebye", async () => {
    await greeter.setPostfixGreeting("_byebye");
    expect(await greeter.greet()).to.equal("hello world_byebye");
  });

  it("setGreeting(string,string)", async () => {
    await greeter["setGreeting(string,string)"](" hola", "prefix");
    expect(await greeter.greet()).to.equal("prefix hola");
  });

  it("setGreeting(string)", async () => {
    await greeter["setGreeting(string)"]("Hola, mundo!");
    expect(await greeter.greet()).to.equal("Hola, mundo!");
  });

  it("calldata or memory", async () => {
    const tx = await greeter.setPostfixGreeting("_byebye");
    const tx1 = await greeter.setPostfixGreetingMemory("_byebye");
    const val = tx.gasPrice?.sub(tx1.gasPrice as BigNumberish);
    console.log({
      tx_calldata: toEthers(tx.gasPrice),
      tx_memory: toEthers(tx1.gasPrice),
      val,
      value: toEthers(val),
    });
    expect(tx.gasPrice?.eq(tx1.gasPrice as BigNumberish)).to.be.true as any;
  });
});

function toEthers(n: BigNumberish | BigNumber | undefined) {
  if (!n) {
    console.log("toEthers provided undefined fallback to zero");
    return 0;
  }
  const num = Number(ethers.utils.formatUnits(n));
  console.log("number, ", n, ", to ethers: ", num);
  return num;
}

function parseEth(n: number) {
  const val = ethers.utils.parseEther(n + "");
  console.log("number, ", n, ", to parsed ethers: ", val);
  return val;
}
