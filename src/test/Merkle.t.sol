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

    function testVerifyProof(bytes32[] memory data, uint256 node) public {
        vm.assume(node < data.length);
        bytes32[] memory proof = m.getProof(data, node);
        bytes32 valueToProve = data[node];
        bytes32 root = m.getRoot(data);

        bytes32 rollingHash = valueToProve;
        for(uint i = 0; i < proof.length; ++i){
            rollingHash = m.hashLeafPairs(rollingHash, proof[i]);
        }
        assertEq(rollingHash, root);

    }

    // Left over for manual verification when needed
    //  function testVerifyProofManual() public {
    //     bytes32[] memory data = new bytes32[](7);
    //     data[0] = bytes32("0x00000000");
    //     data[1] = bytes32("0xBEEF00aa");
    //     data[2] = bytes32("0xBEEF00bb");
    //     data[3] = bytes32("0xDEAD00aa");
    //     data[4] = bytes32("0xDEAD00bb");
    //     data[5] = bytes32("0xADDf00aa");
    //     data[6] = bytes32("0xADDf00bb");
    //     //data[7] = bytes32("0xFACE00aa");
    //     // data[8] = bytes32("0x00000000");
    //     // data[9] = bytes32("0x00000d00");
    //     // data[10] = bytes32("0x00000000");
    //     // data[11] = bytes32("0x00000d00");
    //     // data[12] = bytes32("0x00000000");
    //     // data[13] = bytes32("0x00000d00");
    //     // data[14] = bytes32("0x00000000");
    //     // data[15] = bytes32("0x00000d00");
    //     //data[16] = bytes32("0x00000000");
    //     bytes32[] memory proof = m.getProof(data, 3);
    //     //emit log_string("-----------");
 
    //     // for (uint i =0; i < proof.length; ++i) {
    //     //     emit log_bytes32(proof[i]);
    //     // }
    //     bytes32 temp = data[3];

    //     for(uint i = 0; i < proof.length; ++i){
    //         temp = m.hashLeafPairs(temp, proof[i]);
    //     }
    //     //emit log_bytes32(temp);
    //     bytes32 root = m.getRoot(data);
    //     //emit log_bytes32(root);
    //     assertEq(temp, root);
    // }
}
