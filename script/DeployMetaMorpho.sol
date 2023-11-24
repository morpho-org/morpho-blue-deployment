// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {MetaMorphoFactory} from "../lib/metamorpho/src/MetaMorphoFactory.sol";

import "./ConfiguredScript.sol";

contract DeployMetaMorpho is ConfiguredScript {
    MetaMorphoFactory internal metaMorphoFactory;

    function run(string memory network) external {
        DeployConfig memory config = _initConfig(network, true);

        console2.log("Running deployment script using %s...", msg.sender);

        vm.broadcast();
        metaMorphoFactory = new MetaMorphoFactory{salt: config.salt}(address(morpho));

        console2.log("Deployed MetaMorphoFactory at: %s", address(metaMorphoFactory));
    }
}
