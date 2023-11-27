// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {IMorpho} from "../lib/morpho-blue/src/interfaces/IMorpho.sol";
import {IAdaptiveCurveIrm} from "../lib/morpho-blue-irm/src/interfaces/IAdaptiveCurveIrm.sol";

import "../lib/forge-std/src/Script.sol";
import "../lib/forge-std/src/console2.sol";

/// @dev Warning: keys must be ordered alphabetically.
struct OracleConfig {
    address baseFeed1;
    address baseFeed2;
    address quoteFeed1;
    address quoteFeed2;
    uint256 vaultConversionSample;
}

/// @dev Warning: keys must be ordered alphabetically.
struct MarketConfig {
    address collateralToken;
    uint256[] lltvs;
    address loanToken;
    string name;
    OracleConfig oracle;
}

/// @dev Warning: keys must be ordered alphabetically.
struct BundlerConfig {
    bytes32[] args;
    string name;
}

/// @dev Warning: keys must be ordered alphabetically.
struct AdaptiveCurveIrmConfig {
    uint256 adjustmentSpeed;
    uint256 curveSteepness;
    uint256 initialRateAtTarget;
    uint256 targetUtilization;
}

/// @dev Warning: keys must be ordered alphabetically.
struct DeploySalt {
    bytes32 metamorphoFactory;
    bytes32 morpho;
}

/// @dev Warning: keys must be ordered alphabetically.
struct DeployConfig {
    AdaptiveCurveIrmConfig adaptiveCurveIrm;
    BundlerConfig[] bundlers;
    uint256[] lltvs;
    MarketConfig[] markets;
    address owner;
    DeploySalt salt;
}

contract ConfiguredScript is Script {
    using stdJson for string;

    string internal configPath;

    IMorpho internal morpho;
    IAdaptiveCurveIrm internal irm;

    function _init(string memory network, bool requireMorpho) internal returns (DeployConfig memory) {
        vm.createSelectFork(vm.rpcUrl(network));

        console2.log("Running script on network %s using %s...", network, msg.sender);

        return _loadConfig(network, requireMorpho);
    }

    function _loadConfig(string memory network, bool requireMorpho) internal returns (DeployConfig memory) {
        configPath = string.concat("script/config/", network, ".json");

        string memory latestRunPath =
            string.concat("broadcast/DeployMorpho.sol/", vm.toString(block.chainid), "/run-latest.json");

        if (vm.exists(latestRunPath)) {
            string memory latestRun = vm.readFile(latestRunPath);

            morpho = IMorpho(latestRun.readAddress("$.transactions[0].contractAddress"));
        } else {
            require(!requireMorpho, "missing Morpho deployment");
        }

        return abi.decode(vm.parseJson(vm.readFile(configPath)), (DeployConfig));
    }

    function _deployCreate2Code(string memory what, bytes memory args, bytes32 salt) internal returns (address addr) {
        bytes memory bytecode = abi.encodePacked(vm.getCode(what), args);

        assembly ("memory-safe") {
            addr := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }

        require(addr != address(0), "create2 deployment failed");
    }
}
