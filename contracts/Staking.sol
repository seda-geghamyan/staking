//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./EXIO.sol";

contract Stake {
    EXIO public exio;
    address public owner;
    uint256 public contractBalance;
    uint256 public minStakingAmount = 1;
    mapping(address => userStake) public stakesForCoin;
    mapping(address => userStake) public stakesForToken;
   
    struct userStake {
        uint256 amount;
        uint256 bockNumber;
    }

    constructor() payable {
        owner = msg.sender;
        contractBalance += msg.value;
    }

    function stake(uint256 _amount) public payable {
        require(msg.value > 0 || _amount >= minStakingAmount, 'Transfered amount must be more than 0');
        if (msg.value > 0) {
            if(stakesForCoin[msg.sender].amount == 0) {
                stakesForCoin[msg.sender].bockNumber = block.number;
            }
            stakesForCoin[msg.sender].amount += msg.value;
        } else {
            if(stakesForToken[msg.sender].amount == 0) {
                stakesForToken[msg.sender].bockNumber = block.number;
            }
            stakesForToken[msg.sender].amount += _amount;
            contractBalance += _amount;
        }
    }

    function claim() public {
        uint256 rewards = pendingRewards(msg.sender);
        exio.mint(msg.sender, rewards);
    }

    function pendingRewards(address _address) public view returns(uint256) {
        userStake memory staked = stakesForToken[_address];
        uint256 blocksCount = block.number - staked.bockNumber;
        return  blocksCount >= 5 ? blocksCount / 5 * staked.amount * 5 / 100 : 0;
    }

    function withdraw(bool isToken) public payable {
        uint256 amount;
        if (isToken) {
            require(stakesForToken[msg.sender].amount > 0, "Stake: No staking");
            claim();
            amount = stakesForToken[msg.sender].amount;
            stakesForToken[msg.sender].amount = 0;
            contractBalance -= amount;

        } else {
            require(stakesForCoin[msg.sender].amount > 0, "Stake: No staking");
            amount = stakesForCoin[msg.sender].amount;
            stakesForCoin[msg.sender].amount = 0;
            payable(msg.sender).transfer(amount);
        }
    }
}