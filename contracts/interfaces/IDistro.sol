//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;


interface IDistro {
    function addPrivateDistros(address[] memory investors, uint256[] memory amounts) external;
    function mintDistros(address team, address development, address reserve) external;
    function getUserDeposits(address user) external view returns (uint256);
}