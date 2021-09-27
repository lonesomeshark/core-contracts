// pragma solidity ^0.5.0;
// pragma experimental ABIEncoderV2;

// import "../node_modules/@studydefi/money-legos/dydx/contracts/DydxFlashloanBase.sol";
// import "../node_modules/@studydefi/money-legos/dydx/contracts/ICallee.sol";


// // Name IKyberNetworkProxy to keep naming convention consistent with IUniswapV2Router02 and IWeth 
// import { KyberNetworkProxy as IKyberNetworkProxy } from '../node_modules/@studydefi/money-legos/kyber/contracts/KyberNetworkProxy.sol';
// import './IUniswapV2Router02.sol';
// import './IWeth.sol';

// contract Flashloan is ICallee, DydxFlashloanBase {
//   enum Direction { KyberToUniswap, UniswapToKyber }

//   struct ArbInfo {
//     Direction direction;
//     uint repayAmount;
//   }

//   event NewArbitrage (
//     Direction direction, 
//     uint profit,
//     uint date
//   );

//   IKyberNetworkProxy kyber;
//   IUniswapV2Router02 uniswap;
//   IWeth weth;
//   IERC20 dai;
//   address beneficiary;
//   address constant KYBER_ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

//   constructor(
//     address kyberAddress,
//     address uniswapAddress,
//     address wethAddress,
//     address daiAddress,
//     address beneficiaryAddress    
//   ) public {
//     kyber = IKyberNetworkProxy(kyberAddress);
//     uniswap = IUniswapV2Router02(uniswapAddress);
//     weth = IWeth(wethAddress);
//     dai = IERC20(daiAddress);
//     beneficiary = beneficiaryAddress;
//   }

//   function callFunction(
//     address sender, 
//     Account.Info memory account, 
//     bytes memory data     
//   ) public {
//       ArbInfo memory arbInfo = abi.decode(data, (ArbInfo));     
//       uint balanceDai = dai.balanceOf(address(this));

//       if (arbInfo.direction == Direction.KyberToUniswap) {
//         // Buy ETH on Kyber
//         // approve dai to be spent on kyber
//         dai.approve(address(kyber), balanceDai);
//         (uint expectedRate, ) = kyber.getExpectedRate(
//           dai, 
//           IERC20(KYBER_ETH_ADDRESS),  
//           balanceDai  
//         );
//         kyber.swapTokenToEther(dai, balanceDai, expectedRate);
  
//         // Sell ETH on Uniswap
//         // only working with 2 tokens ie. dai and weth 
//         address[] memory path = new address[](2);
//         path[0] = address(weth);  // uniswap works with weth not eth
//         path[1] = address(dai);
//         uint[] memory minOuts = uniswap.getAmountsOut(address(this).balance, path);
//         uniswap.swapExactETHForTokens.value(address(this).balance)(
//           minOuts[1], 
//           path,
//           address(this),
//           now
//         );
//     } else {
//         // Buy ETH on Uniswap
//         dai.approve(address(uniswap), balanceDai);
//         address[] memory path = new address[](2);
//         path[0] = address(dai);
//         path[1] = address(weth);
//         uint[] memory minOuts = uniswap.getAmountsOut(balanceDai, path);
//         uniswap.swapTokensForExactETH(
//           balanceDai, 
//           minOuts[1], 
//           path, 
//           address(this), 
//           now
//         );

//         // Sell ETH on Kyber
//         (uint expectedRate, ) = kyber.getExpectedRate(
//           IERC20(KYBER_ETH_ADDRESS),
//           dai,
//           address(this).balance
//         );
//         kyber.swapEtherToToken.value(address(this).balance)(
//           dai,
//           expectedRate
//         );
//       }
      
//       // checks to make sure there is adequate dai to repay loan
//       require(
//         dai.balanceOf(address(this)) >= arbInfo.repayAmount, 
//         "Not enough funds to repay dydx loan!"
//       );

//       uint profit = dai.balanceOf(address(this)) - arbInfo.repayAmount;
//       dai.transfer(beneficiary, profit);
//       emit NewArbitrage(arbInfo.direction, profit, now);
//   }

//   function initiateFlashloan(address _solo, address _token, uint _amount, Direction _direction) external {
//     ISoloMargin solo = ISoloMargin(_solo);

//     uint marketId = _getMarketIdFromTokenAddress(_solo, _token);

//     // Calculate repay amount (2 wei is cost to interact with dydx protocol)
//     uint repayAmount = _getRepaymentAmountInternal(_amount);
//     IERC20(_token).approve(_solo, repayAmount);

//     // Defines these 3 actions:
//     // 1. Withdraw $
//     // 2. Call callFunction(...)
//     // 3. Deposit dai back to dydx
//     Actions.ActionArgs[] memory operations = new Actions.ActionArgs[](3);

//     operations[0] = _getWithdrawAction(marketId, _amount);
//     operations[1] = _getCallAction(
//       abi.encode(ArbInfo({direction: _direction, repayAmount: repayAmount}))
//     );
//     operations[2] = _getDepositAction(marketId, repayAmount);

//     Account.Info[] memory accountInfos = new Account.Info[](1);
//     accountInfos[0] = _getAccountInfo();

//     solo.operate(accountInfos, operations);
//   }

//   function() external payable {}
// }