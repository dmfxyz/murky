// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "ds-test/test.sol";
import "../Merkle.sol";
import "forge-std/Vm.sol";

contract ContractTest is DSTest {

    Merkle m;
    Vm vm = Vm(HEVM_ADDRESS);
    function setUp() public {
        m = new Merkle();
    }

    function testHashes(bytes32 left, bytes32 right) public {
        bytes32 hAssem = m.hashLeafPairs(left, right);
        bytes32 hNaive = keccak256(abi.encode(left ^ right));
        assertEq(hAssem, hNaive);
    }
    
    function testGenerateProof(bytes32[] memory data, uint256 node) public {
        vm.assume(data.length > 1);
        vm.assume(node < data.length);
        bytes32 root = m.getRoot(data);
        bytes32[] memory proof = m.getProof(data, node);
        bytes32 valueToProve = data[node];

        bytes32 rollingHash = valueToProve;
        for(uint i = 0; i < proof.length; ++i){
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
    

    function testLogCeil_naive(uint256 x) public{
        vm.assume(x > 0);
        m.log2ceil_naive(x);
    }

    function testLogCeil_bitmagic(uint256 x) public {
        vm.assume(x > 0);
        m.log2ceil_bitmagic(x);
    }


    function testLogCeil_KnownPowerOf2() public {
        assertEq(3, m.log2ceil_bitmagic(8));
    }
    function testLogCeil_Known() public {
        assertEq(8, m.log2ceil_bitmagic(129));
    }
}
