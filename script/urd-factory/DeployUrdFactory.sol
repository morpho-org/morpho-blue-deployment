// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {UrdFactory} from "../../lib/universal-rewards-distributor/src/UrdFactory.sol";

import "../ConfiguredScript.sol";

/// @dev Warning: keys must be ordered alphabetically.
struct DeployUrdFactoryConfig {
    bytes32 salt;
}

contract DeployUrdFactory is ConfiguredScript {
    UrdFactory internal urdFactory;

    function _scriptDir() internal pure override returns (string memory) {
        return "urd-factory";
    }

    function run(string memory network) public returns (DeployUrdFactoryConfig memory config) {
        config = abi.decode(_init(network, true), (DeployUrdFactoryConfig));

        bytes memory constructorArgs;

        urdFactory =
            UrdFactory(_deployCreate2Code("universal-rewards-distributor", "UrdFactory", constructorArgs, config.salt));
    }
}
