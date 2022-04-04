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

    function testHashLeafs(bytes32 left, bytes32 right) public {
        bytes32 xor = left ^ right;
        bytes32 expected = keccak256(abi.encode(xor));
        assertEq(expected, m.hashLeafPairs(left, right));
    }

    function testHashLevel(bytes32[] memory level) public {
        vm.assume(level.length > 0);
        bytes32[] memory result = m.hashLevel(level);
    }

    function testGetRoot(bytes32[] memory data) public {
        vm.assume(data.length > 0);
        m.getRoot(data);
    }

    function testGetProof() public {
        bytes32[] memory data = new bytes32[](9);
        data[0] = bytes32("0x01337001");
        data[1] = bytes32("0xBEEF00aa");
        data[2] = bytes32("0xBEEF00bb");
        data[3] = bytes32("0xDEAD00aa");
        data[4] = bytes32("0xDEAD00bb");
        data[5] = bytes32("0xADDf00aa");
        data[6] = bytes32("0xADDf00bb");
        data[7] = bytes32("0xFACE00aa");
        data[8] = bytes32("0xFACE00bb");
        bytes32[] memory result = m.getProof(data, 5);
        for (uint i = 0; i < result.length; ++i) {
            emit log_bytes32(result[i]);
        }

    }

     function testVerifyProofManual() public {
        bytes32[] memory data = new bytes32[](10);
        data[0] = bytes32("0x00000000");
        data[1] = bytes32("0xBEEF00aa");
        data[2] = bytes32("0xBEEF00bb");
        data[3] = bytes32("0xDEAD00aa");
        data[4] = bytes32("0xDEAD00bb");
        data[5] = bytes32("0xADDf00aa");
        data[6] = bytes32("0xADDf00bb");
        data[7] = bytes32("0xFACE00aa");
        data[8] = bytes32("0x00000000");
        data[9] = bytes32("0x00000d00");
        bytes32[] memory proof = m.getProof(data, 4);
        //emit log_string("-----------");

        for (uint i =0; i < proof.length; ++i) {
            emit log_bytes32(proof[i]);
        }
        bytes32 temp = data[4];

        for(uint i = 0; i < proof.length; ++i){
            temp = m.hashLeafPairs(temp, proof[i]);
        }
        //emit log_bytes32(temp);
        bytes32 root = m.getRoot(data);
        //emit log_bytes32(root);
        assertEq(temp, root);
    }

    // function testVerifyProofFuzz(bytes32[] data, uint256 node) public {
    //     bytes32[] memory data = new bytes32[](7);
    //     data[0] = bytes32("0x00000000");
    //     data[1] = bytes32("0xBEEF00aa");
    //     data[2] = bytes32("0xBEEF00bb");
    //     data[3] = bytes32("0xDEAD00aa");
    //     data[4] = bytes32("0xDEAD00bb");
    //     data[5] = bytes32("0xADDf00aa");
    //     data[6] = bytes32("0xADDf00bb");
    //     //data[7] = bytes32("0xFACE00aa");
    //     //data[8] = bytes32("0x00000000");
    //     bytes32[] memory proof = m.getProof(data, 1);
    //     //emit log_string("-----------");

    //     for (uint i =0; i < proof.length; ++i) {
    //         //emit log_bytes32(proof[i]);
    //     }
    //     bytes32 temp = data[1];

    //     for(uint i = 0; i < proof.length; ++i){
    //         temp = m.hashLeafPairs(temp, proof[i]);
    //     }
    //     //emit log_bytes32(temp);
    //     bytes32 root = m.getRoot(data);
    //     //emit log_bytes32(root);
    //     assertEq(temp, root);
    // }


    

    // function testVerifyProofLessThan10leaves(bytes32[] memory data, uint256 node) public {
    //     vm.assume(data.length < 10 && data.length > 0);
    //     vm.assume(node < data.length);
    //     vm.assume(node > 1);
    //     // bytes32[] memory data = new bytes32[](13);
    //     // data[0] = bytes32("0x01337001");
    //     // data[1] = bytes32("0xBEEF00aa");
    //     // data[2] = bytes32("0xBEEF00bb");
    //     // data[3] = bytes32("0xDEAD00aa");
    //     // data[4] = bytes32("0xDEAD00bb");
    //     // data[5] = bytes32("0xADDf00aa");
    //     //data[6] = bytes32("0xADDf00bb");
    //     // data[7] = bytes32("0xFACE00aa");
    //     // data[8] = bytes32("0xFACE00bb");
    //     // data[9] = bytes32("0x133700aa");
    //     // data[10] = bytes32("0x133700bb");
    //     bytes32[] memory proof = m.getProof(data, node);
    //     bytes32 temp = data[node];

    //     for(uint i = 0; i < proof.length; ++i){
    //         temp = m.hashLeafPairs(temp, proof[i]);
    //     }
    //     emit log_bytes32(temp);
    //     bytes32 root = m.getRoot(data);
    //     emit log_bytes32(root);
    //     assertEq(temp, root);
    // }

    // function testVerifyProofEvenLeafCount() public {
    //     bytes32[] memory data = new bytes32[](10);
    //     data[0] = bytes32("0x01337001");
    //     data[1] = bytes32("0xBEEF00aa");
    //     data[2] = bytes32("0xBEEF00bb");
    //     data[3] = bytes32("0xDEAD00aa");
    //     data[4] = bytes32("0xDEAD00bb");
    //     data[5] = bytes32("0xADDf00aa");
    //     data[6] = bytes32("0xADDf00bb");
    //     data[7] = bytes32("0xFACE00aa");
    //     data[8] = bytes32("0xFACE00bb");
    //     data[9] = bytes32("0x133700aa");
    //     bytes32[] memory proof = m.getProof(data, 6);
    //     bytes32 temp = data[6];

    //     for(uint i = 0; i < proof.length; ++i){
    //         temp = m.hashLeafPairs(temp, proof[i]);
    //     }
    //     emit log_bytes32(temp);
    //     bytes32 root = m.getRoot(data);
    //     emit log_bytes32(root);
    //     assertEq(temp, root);
    // }
}
