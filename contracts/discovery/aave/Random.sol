// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.6.12;
import "hardhat/console.sol";

import { SafeERC20, SafeMath } from "./Libraries.sol";
import { ERC20 } from "@aave/protocol-v2/contracts/dependencies/openzeppelin/contracts/ERC20.sol";
contract Random {
    using SafeMath for uint;

    uint public val;
    constructor() public {}

    function add(uint x) public{
        console.log("value provided: %s", x);
        val = x.add(2);
    }


}

contract TransferNow {
    // constructor(){}
    function now(address payable _to) public payable {
        address(_to).call.value(msg.value);
        // _to.transfer(msg.value);
    }
}
contract ERC20FixedSupply is ERC20 {
    constructor() ERC20("token","tok") public {
        _mint(msg.sender, 1000 ether);
    }
}