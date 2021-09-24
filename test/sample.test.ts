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
});
