// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "../CompleteMerkle.sol";
import "../Merkle.sol";
import "forge-std/Test.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";
import "forge-std/console.sol";

contract ContractTest is Test {
    CompleteMerkle m;
    Merkle om;

    function setUp() public {
        m = new CompleteMerkle();
        om = new Merkle();
    }

    // function testHashes(bytes32 left, bytes32 right) public {
    //     bytes32 hAssem = m.hashLeafPairs(left, right);
    //     bytes memory packed;
    //     if (left <= right) {
    //         packed = abi.encodePacked(left, right);
    //     } else {
    //         if (right == bytes32(0x0)) {
    //             packed = abi.encodePacked(left, left);
    //         } else {
    //         packed = abi.encodePacked(right, left);
    //         }
    //     }
    //     bytes32 hNaive = keccak256(packed);
    //     assertEq(hAssem, hNaive);
    // }

    // function testHashesDuplicateOddLeaf(bytes32 left) public {
    //     bytes32 right = bytes32(0x0);
    //     bytes32 hAssem = m.hashLeafPairs(left, right);
    //     bytes memory packed = abi.encodePacked(left, left);
    //     bytes32 hNaive = keccak256(packed);
    //     assertEq(hAssem, hNaive);
    // }

    function testGenerateProof(bytes32[] memory data, uint256 node) public {
        vm.assume(data.length > 1);
        vm.assume(node < data.length);
        bytes32 root = m.getRoot(data);
        bytes32[] memory proof = m.getProof(data, node);
        bytes32 valueToProve = data[node];

        bytes32 rollingHash = valueToProve;
        for (uint256 i = 0; i < proof.length; ++i) {
            rollingHash = m.hashLeafPairs(rollingHash, proof[i]);
        }
        assertEq(rollingHash, root);
    }

    function testVerifyProof(bytes32[] memory data, uint256 node) public {
        vm.assume(data.length > 1);
        vm.assume(node < data.length);
        bytes32 root = m.getRoot(data);
        bytes32[] memory proof = m.getProof(data, node);
        bytes32 valueToProve = data[node];
        assertTrue(m.verifyProof(root, proof, valueToProve));
    }

    function testFailVerifyProof(bytes32[] memory data, bytes32 valueToProve, uint256 node) public {
        vm.assume(data.length > 1);
        vm.assume(node < data.length);
        vm.assume(valueNotInArray(data, valueToProve));
        bytes32 root = m.getRoot(data);
        bytes32[] memory proof = m.getProof(data, node);
        assertTrue(m.verifyProof(root, proof, valueToProve));
    }

    function testWontGetRootSingleLeaf() public {
        bytes32[] memory data = new bytes32[](1);
        data[0] = bytes32(0x0);
        vm.expectRevert("won't generate root for single leaf");
        m.getRoot(data);
    }

    function testWontGetProofSingleLeaf() public {
        bytes32[] memory data = new bytes32[](1);
        data[0] = bytes32(0x0);
        vm.expectRevert("won't generate proof for single leaf");
        m.getProof(data, 0x0);
    }

    function valueNotInArray(bytes32[] memory data, bytes32 value) public pure returns (bool) {
        for (uint256 i = 0; i < data.length; ++i) {
            if (data[i] == value) return false;
        }
        return true;
    }

    function testRootProofGenerationBasic6() public {
        bytes32[] memory data = new bytes32[](6);

        data[0] = 0xcf0e8c2fa63ea2b3726dbea696df21baec00c4cdb37deeab03a15f190659544c; // sha3(alice, address(0x0))
        data[1] = 0xafeb0ccce3b008968e7ffbfc7482d85551f5f90e713b8441449d808d25e9cc64; // sha3(bob, address(0x0))
        data[2] = 0x7f37e8358c0d3959e3e800344c357551753c24a55d5d987cef461e933b137a02; // sha3(charlie, address(0x0))
        data[3] = 0xde1820ee7887b5ae922f14f423bb2e7a6595e423f1a0c0a82a2ddeed09a92a25;
        data[4] = 0xcac6fc160d04af9e1fd8f0c71cf8d333453b39589d3846524462ee7737bd728d;
        data[5] = 0x1688f29243f54ddded6dedcbbc8dae64ef939f0b967d0fa56a6e5938febb5f79;
        bytes32 root = m.getRoot(data);
        for (uint256 i = 0; i < data.length; ++i) {
            bytes32[] memory proof = m.getProof(data, i);
            assertTrue(m.verifyProof(root, proof, data[i]));
        }
    }

    function testRootGenerationOriginalMurky6ForGas() public {
        bytes32[] memory data = new bytes32[](6);

        data[0] = 0xcf0e8c2fa63ea2b3726dbea696df21baec00c4cdb37deeab03a15f190659544c; // sha3(alice, address(0x0))
        data[1] = 0xafeb0ccce3b008968e7ffbfc7482d85551f5f90e713b8441449d808d25e9cc64; // sha3(bob, address(0x0))
        data[2] = 0x7f37e8358c0d3959e3e800344c357551753c24a55d5d987cef461e933b137a02; // sha3(charlie, address(0x0))
        data[3] = 0xde1820ee7887b5ae922f14f423bb2e7a6595e423f1a0c0a82a2ddeed09a92a25;
        data[4] = 0xcac6fc160d04af9e1fd8f0c71cf8d333453b39589d3846524462ee7737bd728d;
        data[5] = 0x1688f29243f54ddded6dedcbbc8dae64ef939f0b967d0fa56a6e5938febb5f79;
        //bytes32[] memory tree = m._getTree(data);
        bytes32 root = om.getRoot(data);
        for (uint256 i = 0; i < data.length; ++i) {
            bytes32[] memory proof = om.getProof(data, i);
            assertTrue(om.verifyProof(root, proof, data[i]));
        }
    }
}
