//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

import { InvestorsVesting, IVesting } from './InvestorsVesting.sol';
import './CliffVesting.sol';
import './interfaces/IDistro.sol';
import './interfaces/ICgt.sol';


contract Distro is IDistro, Ownable {
    using SafeMath for uint256;

    ICgt public cgtToken;
    IVesting public immutable vesting;

    address public farmingLockContract;                                                      
    address public reserveLockContract;                                                      
    address public developmentLockContract;
    address public teamLockContract;
   
    uint256 public constant PRIVATE_DISTRO_LOCK_PERCENT = 2000; // 20% of tokens

    mapping(address => uint256) internal _deposits;
    event Deposited(address indexed user, uint256 amount);


    // ------------------------
    // CONSTRUCTOR
    // ------------------------

    constructor(address cgtToken_) {
        require(cgtToken_ != address(0), 'Distro: Empty token address!');
        cgtToken = ICgt(cgtToken_);

        address vestingAddr = address(new InvestorsVesting(cgtToken_));
        vesting = IVesting(vestingAddr);
    }

    // ------------------------
    // SETTERS (OWNABLE)   
    // ------------------------

    /// @notice Admin can manually add private sale investors with this method
    /// @dev It can be called ONLY during private sale, also lengths of addresses and investments should be equal
    /// @param investors Array of investors addresses
    /// @param amounts Tokens Amount which investors needs to receive 
    function addPrivateDistros(address[] memory investors, uint256[] memory amounts) external override onlyOwner {
        require(investors.length > 0, 'addPrivateDistros: Array can not be empty!');
        require(investors.length == amounts.length, 'addPrivateDistros: Arrays should have the same length!');

        vesting.submitMulti(investors, amounts, PRIVATE_DISTRO_LOCK_PERCENT);
    }



 
    /// @notice Mint and lock tokens for team, development, reserve
    /// @dev Only admin can call it once.
    function mintDistros(address auctionReceiver, address farmingReceiver,  address teamReceiver, address developmentReceiver, address reserveReceiver) external override {
        require(auctionReceiver != address(0) && farmingReceiver != address(0) && developmentReceiver != address(0) && reserveReceiver != address(0) && teamReceiver != address(0), 'mintDistros: Can not be zero address!');
        require(developmentLockContract == address(0) && reserveLockContract == address(0) && teamLockContract == address(0), 'mintDistros: Already locked!');
  
        farmingLockContract = address(new CliffVesting(farmingReceiver, 14 days, 60 days, address(cgtToken)));    //  14 days cliff  2 months vesting
        teamLockContract = address(new CliffVesting(teamReceiver, 60 days, 720 days, address(cgtToken)));    //  1 month cliff  6 months vesting
        developmentLockContract = address(new CliffVesting(developmentReceiver, 60 days, 365 days, address(cgtToken)));      //  7 days cliff   3 months vesting
        reserveLockContract = address(new CliffVesting(reserveReceiver, 60 days, 720 days, address(cgtToken)));        //  2 months cliff 2 years vesting

        cgtToken.mint(auctionReceiver, 30000 ether);  // 30k tokens

        cgtToken.mint(farmingLockContract, 15000 ether);  // 15k tokens
        cgtToken.mint(teamLockContract, 5000 ether);  // 10k tokens
        cgtToken.mint(developmentLockContract, 5000 ether);  // 10k tokens
        cgtToken.mint(reserveLockContract, 30000 ether);    // 30k tokens
    }

    // ------------------------
    // GETTERS
    // ------------------------

    /// @notice Returns how much user invested during sale
    /// @param user address
    function getUserDeposits(address user) external override view returns (uint256) {
        return _deposits[user];
    }
 }
