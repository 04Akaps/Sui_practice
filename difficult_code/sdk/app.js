import { Ed25519Keypair, JsonRpcProvider, RawSigner } from "@mysten/sui.js";
const provider = new JsonRpcProvider("https://gateway.devnet.sui.io:443");

const test = async () => {
  const keypair = new Ed25519Keypair();
  const signer = new RawSigner(
    keypair,
    new JsonRpcProvider("https://gateway.devnet.sui.io:443")
  );

  console.log(signer);
};

test();

// https://github.com/MystenLabs/sui/tree/main/sdk/typescript/

// https://docs.sui.io/devnet/build/cli-client#publish-packages
// - Publish packages

// deployed Data

// Transaction Hash: I2dlC8XOe2lG+cnEQgStcK3ulGc1QactUqrFVAdkiCQ=
// Transaction Signature: AA==@uLpkHYMLzzUQobsuXrDWc9uumpXmmth6l9b7VMCuRuhnqtVW9gnMUTaw0ZtLyGztmsqZSRD+69kQdWkUX5dkAg==@mGX170svpIu4ykK2Jahq8QSaQn+u/sYn4tM+S3JnqXY=
// Signed Authorities Bitmap: RoaringBitmap<[0, 1, 2]>
// Transaction Kind : Publish
// ----- Transaction Effects ----
// Status : Success
// Created Objects:
//   - ID: 0xb0e284a1abb9994fa248ba282998889ca9c59964 , Owner: Shared
//   - ID: 0xea7838b694d5a940c0bed2168b8e0ce861d5ba91 , Owner: Account Address ( 0x068d7785a28b0517b653cb93588e836e7c9fbbe9 )
//   - ID: 0xedd51230de9499886e487bf3119706a2b2db7576 , Owner: Immutable
// Mutated Objects:
//   - ID: 0x0bb906f059876c63b4720d56d5c3944921483ea9 , Owner: Account Address ( 0x068d7785a28b0517b653cb93588e836e7c9fbbe9 )
// ----- Publish Results ----
// The newly published package object ID: 0xedd51230de9499886e487bf3119706a2b2db7576

// List of objects created by running module initializers:
// ----- Move Object (0xb0e284a1abb9994fa248ba282998889ca9c59964[1]) -----
// Owner: Shared
// Version: 1
// Storage Rebate: 31
// Previous Transaction: I2dlC8XOe2lG+cnEQgStcK3ulGc1QactUqrFVAdkiCQ=
// ----- Data -----
// type: 0xedd51230de9499886e487bf3119706a2b2db7576::warrior::NFTGlobalData
// baseWarriorURL: https://ipfs.io/ipfs/QmSrgtDKdUw4a9GVxWH3fSiVnFKX4ivtwvkZZiopWSwLNW/
// baseWeaponURL: https://ipfs.io/ipfs/QmUPTXn9KrK3x5dD4x2RH3t2fNk7LgUUjVyygR7CsPyk6L/
// id: 0xb0e284a1abb9994fa248ba282998889ca9c59964
// maxWarriorSupply: 10000
// mintedAddresses: []
// mintedwarriors: 0
// mintingEnabled: true
// owner: 0x068d7785a28b0517b653cb93588e836e7c9fbbe9

// ----- Move Object (0xea7838b694d5a940c0bed2168b8e0ce861d5ba91[1]) -----
// Owner: Account Address ( 0x068d7785a28b0517b653cb93588e836e7c9fbbe9 )
// Version: 1
// Storage Rebate: 13
// Previous Transaction: I2dlC8XOe2lG+cnEQgStcK3ulGc1QactUqrFVAdkiCQ=
// ----- Data -----
// type: 0xedd51230de9499886e487bf3119706a2b2db7576::warrior::Ownership
// id: 0xea7838b694d5a940c0bed2168b8e0ce861d5ba91

// Updated Gas : Coin { id: 0x0bb906f059876c63b4720d56d5c3944921483ea9, value: 9997791 }
