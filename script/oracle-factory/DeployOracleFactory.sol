// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {MorphoChainlinkOracleV2Factory} from
    "../../lib/morpho-blue-oracles/src/morpho-chainlink/MorphoChainlinkOracleV2Factory.sol";

import "../ConfiguredScript.sol";

/// @dev Warning: keys must be ordered alphabetically.
struct DeployOracleFactoryConfig {
    bytes32 salt;
}

contract DeployOracle is ConfiguredScript {
    MorphoChainlinkOracleV2Factory internal oracleFactory;

    function _scriptDir() internal pure override returns (string memory) {
        return "oracle-factory";
    }

    function run(string memory network) public returns (DeployOracleFactoryConfig memory config) {
        config = abi.decode(_init(network, false), (DeployOracleFactoryConfig));

        bytes memory args;

        oracleFactory = MorphoChainlinkOracleV2Factory(
            _deployCreate2Code("morpho-blue-oracles", "MorphoChainlinkOracleV2Factory", args, config.salt)
        );
    }
}
