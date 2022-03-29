
﻿ // SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract AlyraToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("AlyraToken", "ATN") {
        _mint(msg.sender, initialSupply);
    }
}