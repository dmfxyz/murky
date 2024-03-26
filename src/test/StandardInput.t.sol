pragma solidity ^0.8.4;

import "../Xorkle.sol";
import "../Merkle.sol";
import "../CompleteMerkle.sol";
import "forge-std/Test.sol";

contract StandardizedInputTest is Test {
    Xorkle x;
    Merkle m;
    CompleteMerkle cm;
    bytes32[100] data;
    uint256[8] leaves = [4, 8, 15, 16, 23, 42, 69, 88];

    function setUp() public {
        string[] memory inputs = new string[](2);
        inputs[0] = "cat";
        inputs[1] = "src/test/standard_data/StandardInput.txt";
        bytes memory result = vm.ffi(inputs);
        data = abi.decode(result, (bytes32[100]));
        x = new Xorkle();
        m = new Merkle();
        cm = new CompleteMerkle();
    }

    function testXorkleGenerateProofStandard() public view {
        bytes32[] memory _data = _getData();
        for (uint256 i = 0; i < leaves.length; ++i) {
            x.getProof(_data, leaves[i]);
        }
    }

    function testMerkleGenerateProofStandard() public view {
        bytes32[] memory _data = _getData();
        for (uint256 i = 0; i < leaves.length; ++i) {
            m.getProof(_data, leaves[i]);
        }
    }

    function testXorkleVerifyProofStandard() public view {
        bytes32[] memory _data = _getData();
        bytes32 root = x.getRoot(_data);
        for (uint256 i = 0; i < leaves.length; ++i) {
            bytes32[] memory proof = x.getProof(_data, leaves[i]);
            assertTrue(x.verifyProof(root, proof, _data[leaves[i]]));
        }
    }

    function testMerkleVerifyProofStandard() public view {
        bytes32[] memory _data = _getData();
        bytes32 root = m.getRoot(_data);
        for (uint256 i = 0; i < leaves.length; ++i) {
            bytes32[] memory proof = m.getProof(_data, leaves[i]);
            assertTrue(m.verifyProof(root, proof, _data[leaves[i]]));
        }
    }

    function testCompleteMerkleGenerateProofStandard() public view {
        bytes32[] memory _data = _getData();
        for (uint256 i = 0; i < leaves.length; ++i) {
            cm.getProof(_data, leaves[i]);
        }
    }

    function testCompleteMerkleVerifyProofStandard() public view {
        bytes32[] memory _data = _getData();
        bytes32 root = cm.getRoot(_data);
        for (uint256 i = 0; i < leaves.length; ++i) {
            bytes32[] memory proof = cm.getProof(_data, leaves[i]);
            assertTrue(cm.verifyProof(root, proof, _data[leaves[i]]));
        }
    }

    function _getData() public view returns (bytes32[] memory) {
        bytes32[] memory _data = new bytes32[](data.length);
        uint256 length = data.length;
        for (uint256 i = 0; i < length; ++i) {
            _data[i] = data[i];
        }
        return _data;
    }
}
