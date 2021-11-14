//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';


interface ICgt is IERC20 {
    function burn(uint256 amount) external;
    function mint(address to, uint256 value) external;
}