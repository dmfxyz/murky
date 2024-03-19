// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "../OZMerkle.sol";
import "forge-std/Test.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";
import "forge-std/console.sol";

contract ContractTest is Test {
    OZMerkle m;

    function setUp() public {
        m = new OZMerkle();
    }

    function testHashes(bytes32 left, bytes32 right) public {
        bytes32 hAssem = m.hashLeafPairs(left, right);
        bytes memory packed;
        if (left <= right) {
            packed = abi.encodePacked(left, right);
        } else {
            if (right == bytes32(0x0)) {
                packed = abi.encodePacked(left, left);
            } else {
            packed = abi.encodePacked(right, left);
            }
        }
        bytes32 hNaive = keccak256(packed);
        assertEq(hAssem, hNaive);
    }

    function testHashesDuplicateOddLeaf(bytes32 left) public {
        bytes32 right = bytes32(0x0);
        bytes32 hAssem = m.hashLeafPairs(left, right);
        bytes memory packed = abi.encodePacked(left, left);
        bytes32 hNaive = keccak256(packed);
        assertEq(hAssem, hNaive);
    }

    // function testGenerateProof(bytes32[] memory data, uint256 node) public {
    //     vm.assume(data.length > 1);
    //     vm.assume(node < data.length);
    //     bytes32 root = m.getRoot(data);
    //     bytes32[] memory proof = m.getProof(data, node);
    //     bytes32 valueToProve = data[node];

    //     bytes32 rollingHash = valueToProve;
    //     for (uint256 i = 0; i < proof.length; ++i) {
    //         rollingHash = m.hashLeafPairs(rollingHash, proof[i]);
    //     }
    //     assertEq(rollingHash, root);
    // }

    // function testVerifyProof(bytes32[] memory data, uint256 node) public {
    //     vm.assume(data.length > 1);
    //     vm.assume(node < data.length);
    //     bytes32 root = m.getRoot(data);
    //     bytes32[] memory proof = m.getProof(data, node);
    //     bytes32 valueToProve = data[node];
    //     assertTrue(m.verifyProof(root, proof, valueToProve));
    // }

    // function testFailVerifyProof(bytes32[] memory data, bytes32 valueToProve, uint256 node) public {
    //     vm.assume(data.length > 1);
    //     vm.assume(node < data.length);
    //     vm.assume(valueNotInArray(data, valueToProve));
    //     bytes32 root = m.getRoot(data);
    //     bytes32[] memory proof = m.getProof(data, node);
    //     assertTrue(m.verifyProof(root, proof, valueToProve));
    // }

    // // function testVerifyProofOzForGasComparison(bytes32[] memory data, uint256 node) public {
    // //     vm.assume(data.length > 1);
    // //     vm.assume(node < data.length);
    // //     bytes32 root = m.getRoot(data);
    // //     bytes32[] memory proof = m.getProof(data, node);
    // //     bytes32 valueToProve = data[node];
    // //     assertTrue(MerkleProof.verify(proof, root, valueToProve));
    // // }

    // function testWontGetRootSingleLeaf() public {
    //     bytes32[] memory data = new bytes32[](1);
    //     data[0] = bytes32(0x0);
    //     vm.expectRevert("won't generate root for single leaf");
    //     m.getRoot(data);
    // }

    // function testWontGetProofSingleLeaf() public {
    //     bytes32[] memory data = new bytes32[](1);
    //     data[0] = bytes32(0x0);
    //     vm.expectRevert("won't generate proof for single leaf");
    //     m.getProof(data, 0x0);
    // }

    // function valueNotInArray(bytes32[] memory data, bytes32 value) public pure returns (bool) {
    //     for (uint256 i = 0; i < data.length; ++i) {
    //         if (data[i] == value) return false;
    //     }
    //     return true;
    // }

    function testExampleIssue() public {
        bytes32[] memory data = new bytes32[](3);

        data[0] = 0x68a111560bac738d202dd1cb92633026df6d2022f075a73497bd57bcebe5a1b8;
        data[1] = 0x4db3d4123a675f46edfdaf2b994d2862142194936b7429376b372e6c8cf46b8b;
        data[2] = 0xd1421691e1b6f8c16692c05ca6df90c00f07e14907be5369c4589790cd51d158;
        bytes32 root = m.getRoot(data);
        emit log_bytes32(root);
    }
}
