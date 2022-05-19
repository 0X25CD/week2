pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/switcher.circom";


template TreeLevels(n) {

    signal input ins[n];
    signal output p_outs[ n/2];
    
    component poseidon_hashes[ n/2];

    signal hash;
    for (var i=0; i<  n/2; i++) {
        poseidon_hashes[i] = Poseidon(2);
        poseidon_hashes[i].inputs[0] <== ins[2*i]; 
        poseidon_hashes[i].inputs[1] <== ins[2*i + 1];  

        p_outs[i] <== poseidon_hashes[i].out;
    }
}


template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    component layers[n+1];

    layers[n] = TreeLevels(2**n);
    
    for (var i=0; i<2**n; i++) {
        layers[n].ins[i] <== leaves[i];
    }

    for (var l= n-1; l>0; l--) {
        layers[l] = TreeLevels(2**l);

        for (var i=0; i<2**l; i++) {
            layers[l].ins[i] <== layers[l+1].outs[i];
        }
    }
    root <== layers[1].outs[0];
}


template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    component p_hasher[n];  
    component hashes[n]; 
    var hash = leaf;

    for(var i = 0; i < n; i++){
        hashes[i] = Switcher(); 
        hashes[i].L <== hash;
        hashes[i].R <== path_elements[i];
        hashes[i].sel <== path_index[i];

        p_hasher[i] = Poseidon(2);
        p_hasher[i].inputs[0] <== hashes[i].outL;
        p_hasher[i].inputs[1] <== hashes[i].outR;
        hash = p_hasher[i].out; 
    }   

    root <== hash;  

}