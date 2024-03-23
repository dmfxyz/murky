import { StandardMerkleTree } from "@openzeppelin/merkle-tree";
import { ethers } from 'ethers';

const fs = require('fs');
const input_file = process.argv[2];
const input = JSON.parse(fs.readFileSync(input_file, 'utf8'));
const one_word = "0x0000000000000000000000000000000000000000000000000000000000000001"
const leafs = input['leafs'].map((bytes32) => [bytes32, one_word]);
const indexToProve = input['index'];
const tree = StandardMerkleTree.of(leafs, ["bytes32", "bytes32"], { sortLeaves: false }); // NO DEFAULT SORTING LEAVES
const proof = tree.getProof(indexToProve);
process.stdout.write(ethers.utils.defaultAbiCoder.encode(['bytes32[]'], [proof]));
  