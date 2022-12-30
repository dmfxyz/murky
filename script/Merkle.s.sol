// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/StdJson.sol";
import "forge-std/console.sol";
import "../src/Merkle.sol";
import "./common/ScriptHelper.sol";

contract MerkleScript is Script, ScriptHelper {
    using stdJson for string;

    function getValuesByIndex(uint i, uint j) internal pure returns (string memory) {
        return string.concat(".values.", vm.toString(i), ".", vm.toString(j));
    }

    function run() public {
        string memory path = string.concat(vm.projectRoot(), "/script/target/input.json");
        string memory elements = vm.readFile(path);

        string[] memory types = elements.readStringArray(".types");
        uint count = elements.readUint(".count");

        bytes32[] memory leafs = new bytes32[](count);
        string[] memory inputs = new string[](count);

        for (uint i = 0; i < count; i++) {
            bytes memory data;
            string[] memory input = new string[](types.length);

            for (uint j = 0; j < types.length; j++) {
                if (compareStrings(types[j], "address")) {
                    address value = elements.readAddress(getValuesByIndex(i, j));
                    console.log(types[j], value);
                    data = abi.encodePacked(data, value);
                    input[j] = vm.toString(value);
                } else if (compareStrings(types[j], "uint")) {
                    uint value = vm.parseUint(elements.readString(getValuesByIndex(i, j)));
                    console.log(types[j], value);
                    data = abi.encodePacked(data, value);
                    input[j] = vm.toString(value);
                }
            }
            // console.log(keccak256(bytes.concat(keccak256(data))) == keccak256(data));
            // console.log(vm.toString(keccak256(bytes.concat(keccak256(data)))));
            // console.log(vm.toString(keccak256(data)));
            leafs[i] = keccak256(bytes.concat(keccak256(data)));
            inputs[i] = stringArrayToString(input);

            console.log("input", stringArrayToString(input));
        }

        Merkle m = new Merkle();
        bytes32 root = m.getRoot(leafs);
        bytes32[] memory proof = m.getProof(leafs, 2);
        console.log("proof", bytes32ArrayToString(proof));

        console.log("root", vm.toString(root));

        bool verified = m.verifyProof(root, m.getProof(leafs, 2), leafs[2]);
        console.log("verified", verified);
    }
}
