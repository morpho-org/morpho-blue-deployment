// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {PublicAllocator} from "../../lib/public-allocator/src/PublicAllocator.sol";

import "../ConfiguredScript.sol";

/// @dev Warning: keys must be ordered alphabetically.
struct DeployPublicAllocatorConfig {
    bytes32 salt;
}

contract DeployPublicAllocator is ConfiguredScript {
    PublicAllocator internal publicAllocator;

    function _scriptDir() internal pure override returns (string memory) {
        return "public-allocator";
    }

    function run(string memory network) public returns (DeployPublicAllocatorConfig memory config) {
        config = abi.decode(_init(network, true), (DeployPublicAllocatorConfig));

        bytes memory constructorArgs = abi.encode(address(morpho));

        publicAllocator =
            PublicAllocator(_deployCreate2Code("public-allocator", "PublicAllocator", constructorArgs, config.salt));
    }
}
