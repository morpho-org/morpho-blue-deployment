// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {IMetaMorphoFactory} from "../lib/metamorpho/src/interfaces/IMetaMorphoFactory.sol";

import "./ConfiguredScript.sol";

contract DeployMetaMorphoFactory is ConfiguredScript {
    IMetaMorphoFactory internal metaMorphoFactory;

    function run(string memory network) public returns (DeployConfig memory config) {
        config = _init(network, true);

        vm.broadcast();
        metaMorphoFactory = IMetaMorphoFactory(
            _deployCreate2Code(
                "lib/metamorpho/out/MetaMorphoFactory.sol/MetaMorphoFactory.json",
                abi.encode(address(morpho)),
                config.salt.metamorphoFactory
            )
        );

        console2.log("Deployed MetaMorphoFactory at: %s", address(metaMorphoFactory));
    }
}
