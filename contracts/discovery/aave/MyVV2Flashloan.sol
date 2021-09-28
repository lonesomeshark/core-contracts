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
contract MyV2FlashLoan is FlashLoanReceiverBase {
    ILendingPoolAddressesProvider provider;
    uint256 flashAaveAmt0;
    uint256 flashDaiAmt1;
    uint256 flashLinkAmt2;
    address lendingPoolAddr;
    
 // kovan reserve asset addresses
    address kovanAave = 0xB597cd8D3217ea6477232F9217fa70837ff667Af;
    address kovanDai = 0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD;
    address kovanLink = 0xAD5ce863aE3E4E9394Ab43d4ba0D80f419F61789;
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

         // initialise lending pool instance
        ILendingPool lendingPool = ILendingPool(lendingPoolAddr);

        // deposits the flashed AAVE, DAI and Link liquidity onto the lending pool
        flashDeposit(lendingPool);

        uint256 borrowAmt = 100 * 1e18; // to borrow 100 units of x asset

        // borrows 'borrowAmt' amount of LINK using the deposited collateral
        flashBorrow(lendingPool, kovanLink, borrowAmt);

        // repays the 'borrowAmt' mount of LINK to unlock the collateral
        flashRepay(lendingPool, kovanLink, borrowAmt);

        // withdraws the AAVE, DAI and LINK collateral from the lending pool
        flashWithdraw(lendingPool);
        
        // Approve the LendingPool contract allowance to *pull* the owed amount
        for (uint i = 0; i < assets.length; i++) {
            uint amountOwing = amounts[i].add(premiums[i]);
            IERC20(assets[i]).approve(address(LENDING_POOL), amountOwing);
        }
        
        return true;
    }


      /*
     * Deposits the flashed AAVE, DAI and LINK liquidity onto the lending pool as collateral
     */
    function flashDeposit(ILendingPool _lendingPool) public {
        // approve lending pool
        IERC20(kovanDai).approve(lendingPoolAddr, flashDaiAmt1);
        IERC20(kovanAave).approve(lendingPoolAddr, flashAaveAmt0);
        IERC20(kovanLink).approve(lendingPoolAddr, flashLinkAmt2);

        // deposit the flashed AAVE, DAI and LINK as collateral
        _lendingPool.deposit(kovanDai, flashDaiAmt1, address(this), uint16(0));
        _lendingPool.deposit(
            kovanAave,
            flashAaveAmt0,
            address(this),
            uint16(0)
        );
        _lendingPool.deposit(
            kovanLink,
            flashLinkAmt2,
            address(this),
            uint16(0)
        );
    }

    /*
     * Withdraws the AAVE, DAI and LINK collateral from the lending pool
     */
    function flashWithdraw(ILendingPool _lendingPool) public {
        // function withdraw(address asset, uint256 amount, address to)
        _lendingPool.withdraw(kovanAave, flashAaveAmt0, address(this));
        _lendingPool.withdraw(kovanDai, flashDaiAmt1, address(this));
        _lendingPool.withdraw(kovanLink, flashLinkAmt2, address(this));
    }

    /*
     * Borrows _borrowAmt amount of _borrowAsset based on the existing deposited collateral
     */
    function flashBorrow(
        ILendingPool _lendingPool,
        address _borrowAsset,
        uint256 _borrowAmt
    ) public {
        // borrowing x asset at stable rate, no referral, for yourself
        // https://docs.aave.com/developers/v/1.0/developing-on-aave/the-protocol/lendingpool
        _lendingPool.borrow(
            _borrowAsset,
            _borrowAmt,
            1,
            uint16(0),
            address(this)
        );
    }

    /*
     * Repays _repayAmt amount of _repayAsset
     */
    function flashRepay(
        ILendingPool _lendingPool,
        address _repayAsset,
        uint256 _repayAmt
    ) public {
        // approve the repayment from this contract
        IERC20(_repayAsset).approve(lendingPoolAddr, _repayAmt);
        // function repay( address _reserve, uint256 _amount, address payable _onBehalfOf)
        _lendingPool.repay(_repayAsset, _repayAmt, 1, address(this));
    }

    /*
     * Repays _repayAmt amount of _repayAsset
     */
    function flashSwapBorrowRate(
        ILendingPool _lendingPool,
        address _asset,
        uint256 _rateMode
    ) public {
        _lendingPool.swapBorrowRateMode(_asset, _rateMode);
    }



    // LINK 0xa36085F69e2889c224210F603D836748e7dC0088
      function myFlashLoanCall() public {
        address receiverAddress = address(this);

       address[] memory assets = new address[](2);
        assets[0] = address(0xB597cd8D3217ea6477232F9217fa70837ff667Af); // Kovan AAVE
        assets[1] = address(0x2d12186Fbb9f9a8C28B3FfdD4c42920f8539D738); // Kovan BAT
        // assets[2] = address(0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD); // Kovan DAI
        // assets[3] = address(0x075A36BA8846C6B6F53644fDd3bf17E5151789DC); // Kovan UNI
        // assets[4] = address(0xb7c325266ec274fEb1354021D27FA3E3379D840d); // Kovan YFI
        // assets[5] = address(0xAD5ce863aE3E4E9394Ab43d4ba0D80f419F61789); // Kovan LINK
        // assets[6] = address(0x7FDb81B0b8a010dd4FFc57C3fecbf145BA8Bd947); // Kovan SNX

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 1 ether;
        amounts[1] = 1 ether;
        // amounts[2] = 1 ether;
        // amounts[3] = 1 ether;
        // amounts[4] = 1 ether;
        // amounts[5] = 1 ether;
        // amounts[6] = 1 ether;

        // 0 = no debt, 1 = stable, 2 = variable
        uint256[] memory modes = new uint256[](2);
        modes[0] = 0;
        modes[1] = 0;
        // modes[2] = 0;
        // modes[3] = 0;
        // modes[4] = 0;
        // modes[5] = 0;
        // modes[6] = 0;

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