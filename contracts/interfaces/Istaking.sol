//"SPDX-License-Identifier: UNLICENSED"
pragma solidity 0.8.4;

interface IStaking {
    function redistributeC4g3(uint256 _pid, address _user, uint256 _amountToBurn) external;
    function deposited(uint256 _pid, address _user) external view returns (uint256);
    function setTokensUnlockTime(uint256 _pid, address _user, uint256 _tokensUnlockTime) external;
}