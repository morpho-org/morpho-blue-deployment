// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../script/morpho/DeployMorpho.sol";

import "../../lib/forge-std/src/Test.sol";

contract DeployMorphoEthereumTest is DeployMorpho, Test {
    DeployMorphoConfig internal config;

    constructor() {
        SAVE_VERIFY = false;
    }

    function setUp() public {
        config = run("ethereum");
    }

    function testOwner() public {
        string[] memory lookupAddressArgs = new string[](5);
        lookupAddressArgs[0] = "cast";
        lookupAddressArgs[1] = "lookup-address";
        lookupAddressArgs[2] = vm.toString(morpho.owner());
        lookupAddressArgs[3] = "--rpc-url";
        lookupAddressArgs[4] = "ethereum";

        assertEq(keccak256(vm.ffi(lookupAddressArgs)), keccak256("morpho-association.eth"));
    }

    function testMorphoAddress() public {
        assertEq(
            address(morpho),
            computeCreate2Address(
                config.salt.morpho,
                hashInitCode(vm.getCode("lib/morpho-blue/out/Morpho.sol/Morpho.json"), abi.encode(msg.sender)),
                0x4e59b44847b379578588920cA78FbF26c0B4956C
            )
        );
    }

    function testIrmAddress() public {
        assertEq(
            address(irm),
            computeCreate2Address(
                config.salt.irm,
                hashInitCode(
                    vm.getCode("lib/morpho-blue-irm/out/AdaptiveCurveIrm.sol/AdaptiveCurveIrm.json"),
                    abi.encode(address(morpho))
                ),
                0x4e59b44847b379578588920cA78FbF26c0B4956C
            )
        );
    }

    function testLltvEnabled() public {
        assertTrue(morpho.isLltvEnabled(0), "0%");
        assertFalse(morpho.isLltvEnabled(94.5 ether), "94.5%");
        assertFalse(morpho.isLltvEnabled(96.5 ether), "96.5%");
        assertFalse(morpho.isLltvEnabled(1 ether), "100%");
    }
}
