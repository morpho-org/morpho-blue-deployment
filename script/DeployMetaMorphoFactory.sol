// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {IMetaMorphoFactory} from "../lib/metamorpho/src/interfaces/IMetaMorphoFactory.sol";

import "./config/ConfiguredScript.sol";

/// @dev Warning: keys must be ordered alphabetically.
struct DeployMetaMorphoFactoryConfig {
    bytes32 salt;
}

contract DeployMetaMorphoFactory is ConfiguredScript {
    IMetaMorphoFactory internal metaMorphoFactory;

    function _configDir() internal pure override returns (string memory) {
        return "metamorpho-factory";
    }

    function run(string memory network) public returns (DeployMetaMorphoFactoryConfig memory config) {
        config = abi.decode(_init(network, true), (DeployMetaMorphoFactoryConfig));

        vm.broadcast();
        metaMorphoFactory = IMetaMorphoFactory(
            _deployCreate2Code(
                "lib/metamorpho/out/MetaMorphoFactory.sol/MetaMorphoFactory.json",
                abi.encode(address(morpho)),
                config.salt
            )
        );

        console2.log("Deployed MetaMorphoFactory at: %s", address(metaMorphoFactory));
    }
}
