// SPDX-License-Identifier: BSD-3-CLAUSE
pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

import { IExchangeWrapper, Decimal, IERC20 } from "../../interface/IExchangeWrapper.sol";
import { DecimalERC20 } from "../../utils/DecimalERC20.sol";

contract ExchangeWrapperMock is IExchangeWrapper, DecimalERC20 {
    using Decimal for Decimal.decimal;

    Decimal.decimal private exchangeRatio = Decimal.zero();
    Decimal.decimal private spotPrice = Decimal.zero();
    bool bException = false;

    function mockSetSwapRatio(Decimal.decimal memory _ratio) public {
        exchangeRatio = _ratio;
    }

    function mockSpotPrice(Decimal.decimal memory _price) public {
        spotPrice = _price;
    }

    function mockSetException() public {
        bException = true;
    }

    //prettier-ignore
    function swapInput(
        IERC20 inputToken,
        IERC20 outputToken,
        Decimal.decimal calldata inputTokenSold,
        Decimal.decimal calldata, 
        Decimal.decimal calldata
    ) external override returns (Decimal.decimal memory) {
        if(bException){
            revert();
        }
        _transferFrom(inputToken, msg.sender, address(this), inputTokenSold);
        _transfer(outputToken, msg.sender, inputTokenSold.divD(exchangeRatio));
        return inputTokenSold.divD(exchangeRatio);
    }

    //prettier-ignore
    function swapOutput(
        IERC20 inputToken,
        IERC20 outputToken,
        Decimal.decimal calldata outputTokenBought,
        Decimal.decimal calldata, 
        Decimal.decimal calldata
    ) external override returns (Decimal.decimal memory) {
        if(bException){
            revert();
        }
        _transferFrom(inputToken, msg.sender, address(this), outputTokenBought.mulD(exchangeRatio));
        _transfer(outputToken, msg.sender, outputTokenBought);
        return outputTokenBought.mulD(exchangeRatio);
    }

    //prettier-ignore
    function getInputPrice(IERC20, IERC20, Decimal.decimal calldata inputTokenSold)
        external
        view
        override 
        returns (Decimal.decimal memory)
    {
        return inputTokenSold.divD(exchangeRatio);
    }

    //prettier-ignore
    function getOutputPrice(IERC20, IERC20, Decimal.decimal calldata outputTokenBought)
        external
        view
        override 
        returns (Decimal.decimal memory)
    {
        return outputTokenBought.mulD(exchangeRatio);
    }

    //prettier-ignore
    function getSpotPrice(IERC20, IERC20) external view override returns (Decimal.decimal memory) {
        return spotPrice;
    }
}
