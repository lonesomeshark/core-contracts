// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.6.12;

import { FlashLoanReceiverBase } from "@aave/protocol-v2/contracts/flashloan/base/FlashLoanReceiverBase.sol";
import { ILendingPool } from "@aave/protocol-v2/contracts/interfaces/ILendingPool.sol";
import { ILendingPoolAddressesProvider } from "@aave/protocol-v2/contracts/interfaces/ILendingPoolAddressesProvider.sol";
import { IERC20 } from "@aave/protocol-v2/contracts/dependencies/openzeppelin/contracts/IERC20.sol";
import { ERC20 } from "@aave/protocol-v2/contracts/dependencies/openzeppelin/contracts/ERC20.sol";
// https://docs.aave.com/developers/guides/flash-loans#step-by-step
/** 
    !!!
    Never keep funds permanently on your FlashLoanReceiverBase contract as they could be 
    exposed to a 'griefing' attack, where the stored funds are used by an attacker.
    !!!
 */
contract MyV2FlashLoanInit is FlashLoanReceiverBase {
    ILendingPoolAddressesProvider provider;
    uint256 flashDaiAmt1;
    address lendingPoolAddr;
    
 // kovan reserve asset addresses
    address kovanDai = 0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD;
    constructor(ILendingPoolAddressesProvider _provider) 
    FlashLoanReceiverBase(_provider) 
    public {
        provider = _provider;
        lendingPoolAddr = provider.getLendingPool();
    }
    /**
        This function is called after your contract has received the flash loaned amount
     */
    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    )
        external
        override
        returns (bool)
    {
        //
        // This contract now has the funds requested.
        // Your logic goes here.
        //
        
        // At the end of your logic above, this contract owes
        // the flashloaned amounts + premiums.
        // Therefore ensure your contract has enough to repay
        // these amounts.
        
        // Approve the LendingPool contract allowance to *pull* the owed amount
        for (uint i = 0; i < assets.length; i++) {
            uint amountOwing = amounts[i].add(premiums[i]);
            IERC20(assets[i]).approve(address(LENDING_POOL), amountOwing);
        }
        
        return true;
    }

   



    // LINK 0xa36085F69e2889c224210F603D836748e7dC0088
      function myFlashLoanCall() public {
        address receiverAddress = address(this);

       address[] memory assets = new address[](1);
        assets[2] = address(0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD); // Kovan DAI

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 1 ether;

        // 0 = no debt, 1 = stable, 2 = variable
        uint256[] memory modes = new uint256[](1);
        modes[0] = 0;

        address onBehalfOf = address(this);
        bytes memory params = "";
        uint16 referralCode = 0;

        LENDING_POOL.flashLoan(
            receiverAddress,
            assets,
            amounts,
            modes,
            onBehalfOf,
            params,
            referralCode
        );
    }
}