// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../script/DeployMorpho.sol";

import "../lib/forge-std/src/Test.sol";
import "../lib/forge-std/src/console2.sol";

contract DeployMorphoEthereumTest is DeployMorpho, Test {
    function setUp() public {
        run("ethereum");
    }

    function testOwner() public {
        assertEq(morpho.owner(), 0xcBa28b38103307Ec8dA98377ffF9816C164f9AFa);
    }
}
