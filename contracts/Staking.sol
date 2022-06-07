//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./EXIO.sol";

contract Staking {
    EXIO public token;
    address public owner;
    uint256 public contractBalance;
    uint256 public minStakingAmount = 1 ether;
    mapping(address => userStake) public stakesForCoin;
    mapping(address => userStake) public stakesForToken;
   
    struct userStake {
        uint256 amount;
        uint256 rewards;
        uint256 blockNumber;
    }

    constructor() {
        owner = msg.sender;
        // token = _token;
    }

    function getUserStake (address _address) public view returns(userStake memory) {
        return stakesForToken[_address];
    }

    function stake(uint256 _amount) public payable {
        require(msg.value == 0 || _amount == 0, 'Only one currency can be more than 0');
        require(msg.value > 0 || _amount >= minStakingAmount, 'Transfered amount must be more than 0');
       
       console.log('op');
            // console.log(token.getAddress());

        if (msg.value > 0) {
            // first stake
            if (stakesForCoin[msg.sender].amount == 0 ) {
                stakesForCoin[msg.sender].blockNumber = block.number;
            }

            // 5 block later from last stake
            if (block.number - stakesForCoin[msg.sender].blockNumber == 5) {
                stakesForCoin[msg.sender].blockNumber = block.number;
                // stakesForCoin[msg.sender].amount = msg.value;
            } 
            // else {
            //     stakesForCoin[msg.sender].amount += msg.value;
            // }
            stakesForCoin[msg.sender].amount += msg.value;

        } else {
            if(stakesForToken[msg.sender].amount == 0) {
                stakesForToken[msg.sender].blockNumber = block.number;
            }
             // 5 block later from last stake
            if (block.number - stakesForToken[msg.sender].blockNumber == 5) {
                uint256 rewards = pendingRewards(msg.sender);
                stakesForToken[msg.sender].rewards += rewards;
                stakesForToken[msg.sender].blockNumber = block.number;
            } 
            stakesForToken[msg.sender].amount += _amount;
            // token._transferFrom(msg.sender, address(this), _amount);
        }
    }

    function claim() internal {
        uint256 rewards = pendingRewards(msg.sender);
        token.mint(msg.sender, rewards);
    }

    function pendingRewards(address _address) public view returns(uint256) {
        userStake memory staked = stakesForToken[_address];
        uint256 blocksCount = block.number - staked.blockNumber;
        console.log('blocksCount', block.number, staked.blockNumber);
        uint256 rewards = blocksCount >= 5 ? blocksCount / 5 * (staked.amount * 105 / 100 - staked.amount ) : 0;
        // staked.rewards += rewards;
        return  rewards;
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