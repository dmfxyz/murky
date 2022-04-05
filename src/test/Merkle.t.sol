// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "ds-test/test.sol";
import "../Merkle.sol";
import "forge-std/Vm.sol";

contract ContractTest is DSTest {

    Merkle m;
    Vm vm = Vm(HEVM_ADDRESS);
    function setUp() public {
        m = new Merkle();
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
        vm.assume(data.length > 0);
        vm.assume(node < data.length);
        bytes32 root = m.getRoot(data);
        bytes32[] memory proof = m.getProof(data, node);
        bytes32 valueToProve = data[node];
        assertTrue(m.verifyProof(root, proof, valueToProve));
    }

    function testFailVerifyProof(bytes32[] memory data, bytes32 valueToProve, uint256 node) public {
        vm.assume(data.length > 0);
        vm.assume(node < data.length);
        bytes32 root = m.getRoot(data);
        bytes32[] memory proof = m.getProof(data, node);
        assertTrue(m.verifyProof(root, proof, valueToProve));
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
