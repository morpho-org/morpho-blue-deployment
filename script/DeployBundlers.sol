// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./config/ConfiguredScript.sol";

/// @dev Warning: keys must be ordered alphabetically.
struct BundlerConfig {
    bytes32[] args;
    string name;
}

contract DeployBundlers is ConfiguredScript {
    function _configDir() internal pure override returns (string memory) {
        return "bundlers";
    }

    function run(string memory network) public returns (BundlerConfig[] memory config) {
        config = abi.decode(_init(network, true), (BundlerConfig[]));

        for (uint256 i; i < config.length; ++i) {
            BundlerConfig memory bundlerConfig = config[i];

            // Morpho address is always expected first in bundler constructors.
            bytes memory constructorArgs = abi.encode(address(morpho));
            for (uint256 j; j < bundlerConfig.args.length; ++j) {
                constructorArgs = bytes.concat(constructorArgs, abi.encode(bundlerConfig.args[j]));
            }

            _deployCode("morpho-blue-bundlers", bundlerConfig.name, constructorArgs);
        }
    }
}
