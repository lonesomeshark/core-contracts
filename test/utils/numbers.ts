import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ethers } from "ethers";
import { ERC20 } from "../../typechain/ERC20";
import { Contract } from "@ethersproject/contracts";
import { BigNumber, BigNumberish } from "@ethersproject/bignumber";

export async function getBalance(
  obj: { signer: SignerWithAddress | Contract; contract?: ERC20 },
  b = false
): Promise<number | BigNumber> {
  const toNumberFromEthers = (n: BigNumber | BigNumberish) => {
    return Number(ethers.utils.formatEther(n));
  };
  const { contract, signer } = obj;
  let biggy: BigNumber;
  if (!contract) {
    if (signer instanceof Contract) {
      biggy = await ethers.getDefaultProvider().getBalance(signer.address);
    } else {
      biggy = await signer.getBalance();
    }
  } else {
    biggy = await contract.balanceOf(signer.address);
  }
  if (b) {
    return biggy;
  } else {
    return toNumberFromEthers(biggy);
  }
}
