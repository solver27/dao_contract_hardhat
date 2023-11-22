// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DAOToken is ERC20 {
    constructor() ERC20("DAO Token", "DAO") {
    }

    function mint(uint256 _amount) external {
        _mint(msg.sender, _amount);
    }

}
