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

    function testAddress() public {
        DeployConfig memory config = _loadConfig("ethereum", false);

        assertEq(
            address(morpho),
            computeCreate2Address(
                config.salt.morpho,
                hashInitCode(vm.getCode("lib/morpho-blue/out/Morpho.sol/Morpho.json"), abi.encode(msg.sender)),
                0x4e59b44847b379578588920cA78FbF26c0B4956C
            )
        );
    }

    function testIrmEnabled() public {
        assertTrue(morpho.isIrmEnabled(address(irm)));
    }
}
