import MerkleTree from './merkle-tree';
import { ethers } from 'ethers';
import { toBuffer } from 'ethereumjs-util';

const encoder = ethers.utils.defaultAbiCoder;
const decoded_data = encoder.decode(["bytes32[4]"], process.argv[2])[0]
var dataAsBuffer = decoded_data.map(b => toBuffer(b));

const tree = new MerkleTree(dataAsBuffer);
process.stdout.write(ethers.utils.defaultAbiCoder.encode(['bytes32'], [tree.getRoot()]));


