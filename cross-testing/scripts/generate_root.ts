import MerkleTree from './merkle-tree';
import * as fs from 'fs';
import { ethers } from 'ethers';
import { toBuffer } from 'ethereumjs-util';
import crypto from 'crypto';

var data = [];
for (var i = 0; i < 100; ++i) {
    data.push("0x" + crypto.randomBytes(32).toString('hex'));
}

var dataAsBuffer = [];
for (var i = 0; i < data.length; ++i) {
    dataAsBuffer.push(toBuffer(data[i]));

}

const tree = new MerkleTree(dataAsBuffer);
process.stdout.write(ethers.utils.defaultAbiCoder.encode(['bytes32'], [tree.getRoot()]));
const encodedData = ethers.utils.defaultAbiCoder.encode(["bytes32[100]"], [data]);
fs.writeFileSync("../data/input", encodedData);

