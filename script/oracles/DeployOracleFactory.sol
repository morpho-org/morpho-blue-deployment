// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {IERC20} from "../../lib/forge-std/src/interfaces/IERC20.sol";
import {IChainlinkOracle} from "../../lib/morpho-blue-oracles/src/interfaces/IChainlinkOracle.sol";

import "../ConfiguredScript.sol";

contract DeployOracle is ConfiguredScript {
    IMetaMorphoFactory internal metaMorphoFactory;

    function _scriptDir() internal pure override returns (string memory) {
        return "metamorpho-factory";
    }

    function run(string memory network) public returns (DeployMetaMorphoFactoryConfig memory config) {
        config = abi.decode(_init(network, true), (DeployMetaMorphoFactoryConfig));

        bytes memory constructorArgs = abi.encode(address(0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb));

        metaMorphoFactory =
            IMetaMorphoFactory(_deployCreate2Code("metamorpho", "MetaMorphoFactory", constructorArgs, config.salt));
    }
}
