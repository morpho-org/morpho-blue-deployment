// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {IMetaMorphoFactory} from "../../lib/metamorpho/src/interfaces/IMetaMorphoFactory.sol";

import "../ConfiguredScript.sol";

/// @dev Warning: keys must be ordered alphabetically.
struct DeployMetaMorphoFactoryConfig {
    bytes32 salt;
}

contract DeployMetaMorphoFactory is ConfiguredScript {
    IMetaMorphoFactory internal metaMorphoFactory;

    function _scriptDir() internal pure override returns (string memory) {
        return "metamorpho-factory";
    }

    function run(string memory network) public returns (DeployMetaMorphoFactoryConfig memory config) {
        config = abi.decode(_init(network, true), (DeployMetaMorphoFactoryConfig));

        bytes memory constructorArgs = abi.encode(address(morpho));

        metaMorphoFactory =
            IMetaMorphoFactory(_deployCreate2Code("metamorpho", "MetaMorphoFactory", constructorArgs, config.salt));
    }
}
