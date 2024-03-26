pragma solidity ^0.8.4;

import "../../src/CompleteMerkle.sol";
import "forge-std/Test.sol";
import "./utils/Strings2.sol";


contract CompleteDifferentialTests is Test {
    CompleteMerkle m;
    bytes32 oneword;
    using {Strings2.toHexString} for bytes;


    function setUp() public {
        m = new CompleteMerkle();
        oneword = bytes32(uint256(0x1));
    }

    function testDifferentialOZMerkleTreeRootGeneration(bytes32[] memory leafs) public {
        // Setup assumptions
        vm.assume(leafs.length > 1);

        // Generate the input json to be used by the JS implementation
        string memory obj1 = vm.serializeBytes32("input", "leafs", leafs);
        vm.writeJson(obj1, "./differential_testing/data/complete_root_input.json");

        // Prepare the leafs. OZ JS Merkle double hashes and expects each leaf to be a len(2) array (e.g. address, amount)
        // For this test we use the fuzzed bytes32 and a constant bytes32 0x1
        bytes32[] memory compatibleLeafs = new bytes32[](leafs.length);
        for (uint256 i = 0; i < leafs.length; ++i) {
            compatibleLeafs[i] = keccak256(abi.encode(keccak256(abi.encode(leafs[i],oneword))));
        }

        // Run ffi and read back the oz generated root
        string[] memory runJsInputs = new string[](7);
        runJsInputs[0] = 'npm';
        runJsInputs[1] = '--prefix';
        runJsInputs[2] = 'differential_testing/scripts/';
        runJsInputs[3] = '--silent';
        runJsInputs[4] = 'run';
        runJsInputs[5] = 'generate-complete-root'; // Generates length 129 by default
        runJsInputs[6] = "../data/complete_root_input.json";
        bytes memory jsResult = vm.ffi(runJsInputs);
        bytes32 ozGeneratedRoot = abi.decode(jsResult, (bytes32));

        // generate our root and compare
        bytes32 root = m.getRoot(compatibleLeafs);
        assertEq(root, ozGeneratedRoot);
    }

    function testDifferentialOZMerkleTreeProofGeneration(bytes32[] memory leafs, uint256 index) public {
        // Setup assumptions
        vm.assume(leafs.length > 1);
        vm.assume(index < leafs.length);
        
        string memory obj1 = "input";
        vm.serializeBytes32(obj1, "leafs", leafs);
        string memory obj2 = vm.serializeUint(obj1, "index", index);
        vm.writeJson(obj2, "./differential_testing/data/complete_proof_input.json");

        // Prepare the leafs. OZ JS Merkle double hashes and expects each leaf to be a len(2) array (e.g. address, amount)
        // For this test we use the fuzzed bytes32 and a constant bytes32 0x1
        bytes32[] memory compatibleLeafs = new bytes32[](leafs.length);
        for (uint256 i = 0; i < leafs.length; ++i) {
            compatibleLeafs[i] = keccak256(abi.encode(keccak256(abi.encode(leafs[i],oneword))));
        }

        bytes32[] memory proof = m.getProof(compatibleLeafs, index);
        // Run ffi and read back the oz generated root
        string[] memory runJsInputs = new string[](7);
        runJsInputs[0] = 'npm';
        runJsInputs[1] = '--prefix';
        runJsInputs[2] = 'differential_testing/scripts/';
        runJsInputs[3] = '--silent';
        runJsInputs[4] = 'run';
        runJsInputs[5] = 'generate-complete-proof';
        runJsInputs[6] = "../data/complete_proof_input.json";
        bytes memory jsResult = vm.ffi(runJsInputs);
        bytes32[] memory ozGeneratedProof = abi.decode(jsResult, (bytes32[]));

        // assert proofs are equal
        assertEq(proof.length, ozGeneratedProof.length);
        for (uint256 i = 0; i < proof.length; ++i) {
            assertEq(proof[i], ozGeneratedProof[i]);
        }
    }
}
