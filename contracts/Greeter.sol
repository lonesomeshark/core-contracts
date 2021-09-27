//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Greeter {
    string private greeting;

    constructor(string memory _greeting) {
        console.log("Deploying a Greeter with greeting:", _greeting);
        greeting = _greeting;
    }

    function greet() public view returns (string memory) {
        return greeting;
    }

    function setGreeting(string memory _greeting) public {
        console.log("Changing greeting from '%s' to '%s'", greeting, _greeting);
        greeting = _greeting;
    }
    function setGreeting(string memory _greeting, string memory _prefix) public {
        console.log("Changing greeting from '%s' to '%s'", greeting, _greeting);
        
        greeting = string(abi.encodePacked(_prefix, _greeting));
    }

    function setPostfixGreeting(string calldata _postfix) public {
        greeting = string(abi.encodePacked(greeting, _postfix));
    }
    function setPostfixGreetingMemory(string memory _postfix) public {
        greeting = string(abi.encodePacked(greeting, _postfix));
    }
}
