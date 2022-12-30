// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleScriptOutputTest is Test {

    // TODO: hardcoding the output from /script/target/output.json for simplicity now
    bytes32[] proof = [
        bytes32(0xa2b556a5fad7a4c999e1735405fa58207ab32f8ecc31fe78d7c4465acc4938c4),
        bytes32(0x8aee6a6b20b786d649a7f0fb7bd1d91b76c87a8ba5ccb9922aabb5e560c1651e),
        bytes32(0x417926cdc4e0ece554f165eb9ca1db6f02dbda4fd61173ab46269334449de60d)
    ];
    bytes32 root =
        0xc050542e9265b2630e0a11c7d02036b1a01a4ddd95dc9cc336dc9fbeec13d612;
    bytes32 leaf =
        0xf4327f09e48c2b574314a17f659651ab70e88548cfc0739a2329730ddc705e1e;

    address inputAddr = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 inputUint = 10000;
    uint256 inputUint2 = 1;

    function testAbiEncode(address a, uint256 b, uint256 c) public {
        vm.assume(a != address(0));
        vm.assume(b != 0);
        vm.assume(c != 0);

        bytes32 a_bytes = bytes32(uint256(uint160(a)));
        bytes32 b_bytes = bytes32(b);
        bytes32 c_bytes = bytes32(c);

        bytes32[] memory bytesArray = new bytes32[](3);
        bytesArray[0] = a_bytes;
        bytesArray[1] = b_bytes;
        bytesArray[2] = c_bytes;

        assertEq(
            (abi.encode(a, b, c)),
            // TODO: need to trim the first 64 bytes because of dynamic array
            (abi.encode(bytesArray))
        );
    }

    // function testComputeLeaf() public {
    //     bytes32 computedLeaf = keccak256(
    //         bytes.concat(
    //             keccak256(abi.encode(inputAddr, inputUint, inputUint2))
    //         )
    //     );
    //     console.log("computedLeaf: %s", vm.toString(computedLeaf));
    //     assertEq(computedLeaf, leaf);
    // }
}
