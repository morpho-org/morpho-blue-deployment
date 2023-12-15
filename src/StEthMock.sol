// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {ERC20} from "../lib/metamorpho/lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract StEthMock is ERC20 {
    constructor() ERC20("Liquid staked Ether 2.0", "stETH") {}

    function getPooledEthByShares(uint256 _sharesAmount) public pure returns (uint256) {
        return _sharesAmount;
    }

    function getSharesByPooledEth(uint256 _ethAmount) public pure returns (uint256) {
        return _ethAmount;
    }

    function transferShares(address _recipient, uint256 _sharesAmount) external returns (uint256) {
        _transfer(msg.sender, _recipient, _sharesAmount);

        return _sharesAmount;
    }

    function submit(address) external payable returns (uint256) {
        _mint(msg.sender, msg.value);

        return msg.value;
    }

    function withdraw(uint256 amount, address payable receiver) external {
        _burn(msg.sender, amount);

        receiver.transfer(amount);
    }
}
