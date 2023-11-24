// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./ConfiguredScript.sol";

contract DeployBundlers is ConfiguredScript {
    function run(string memory network) external {
        DeployConfig memory config = _initConfig(network, true);

        console2.log("Running deployment script using %s...", msg.sender);

        for (uint256 i; i < config.bundlers.length; ++i) {
            BundlerConfig memory bundlerConfig = config.bundlers[i];

            // Morpho address is always expected first in bundler constructors.
            bytes memory constructorArgs = abi.encode(address(morpho));
            for (uint256 j; j < bundlerConfig.args.length; ++j) {
                constructorArgs = bytes.concat(constructorArgs, abi.encode(bundlerConfig.args[j]));
            }

            vm.broadcast();
            address bundler = deployCode(
                string.concat("lib/morpho-blue-bundlers/out/", bundlerConfig.name, ".sol/", bundlerConfig.name, ".json"),
                constructorArgs
            );

            console2.log("Deployed %s at: %s", bundlerConfig.name, bundler);
        }
    }
}
