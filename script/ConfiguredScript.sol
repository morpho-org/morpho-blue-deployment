// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {IMorpho} from "../lib/morpho-blue/src/interfaces/IMorpho.sol";
import {IAdaptiveCurveIrm} from "../lib/morpho-blue-irm/src/interfaces/IAdaptiveCurveIrm.sol";

import "../lib/forge-std/src/Script.sol";
import "../lib/forge-std/src/console2.sol";

abstract contract ConfiguredScript is Script {
    using stdJson for string;

    bool internal immutable SAVE_VERIFY = true;

    string internal configPath;

    IMorpho internal morpho;
    IAdaptiveCurveIrm internal irm;

    function _scriptDir() internal view virtual returns (string memory);

    function _init(string memory network, bool requireMorpho) internal returns (bytes memory) {
        vm.createSelectFork(vm.rpcUrl(network));

        console2.log("Running script on network %s using %s...", network, msg.sender);

        return _loadConfig(network, requireMorpho);
    }

    function _loadConfig(string memory network, bool requireMorpho) internal returns (bytes memory) {
        configPath = string.concat("script/", _scriptDir(), "/config/", network, ".json");

        string memory morphoAddressPath = string.concat("script/", _scriptDir(), "/config/", network, "-morpho.json");

        if (vm.exists(morphoAddressPath)) {
            string memory file = vm.readFile(morphoAddressPath);

            morpho = IMorpho(file.readAddress("$.contractAddress"));
        } else {
            require(!requireMorpho, "missing Morpho deployment");
        }

        return vm.parseJson(vm.readFile(configPath));
    }

    function _deployCreate2Code(string memory submodule, string memory what, bytes memory args, bytes32 salt)
        internal
        returns (address addr)
    {
        bytes memory bytecode =
            abi.encodePacked(vm.getCode(string.concat("lib/", submodule, "/out/", what, ".sol/", what, ".json")), args);

        vm.broadcast();
        assembly ("memory-safe") {
            addr := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }

        require(addr != address(0), "create2 deployment failed");

        _logDeployment(submodule, what, args, addr);
    }

    function _logDeployment(string memory submodule, string memory what, bytes memory args, address addr) internal {
        string memory scriptDir = _scriptDir();

        console2.log("Deployed %s at: %s", what, addr);
        console2.log("Verify %s using:  > yarn verify:%s", scriptDir, scriptDir);

        if (!SAVE_VERIFY) return;

        string memory verifyPath = string.concat("script/", scriptDir, "/verify.sh");
        vm.writeLine(verifyPath, "");
        vm.writeLine(verifyPath, string.concat("if cd lib/", submodule, "/;"));
        vm.writeLine(verifyPath, "then");
        vm.writeLine(
            verifyPath,
            string.concat(
                "FOUNDRY_PROFILE=build forge verify-contract --watch --chain-id ",
                vm.toString(block.chainid),
                " --constructor-args ",
                vm.toString(args),
                " ",
                vm.toString(addr),
                " src/",
                what,
                ".sol:",
                what
            )
        );
        vm.writeLine(verifyPath, "  cd ../../");
        vm.writeLine(verifyPath, "fi");
    }
}
