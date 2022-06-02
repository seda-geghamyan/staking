//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract EXIO is ERC20 {
    constructor(uint256 _initialSupply) ERC20("Exio token", "EXIO") {
        _mint(msg.sender, _initialSupply);
    }

    function mint(address _address, uint256 _amount) external {
        _mint(_address, _amount);
    }
}
