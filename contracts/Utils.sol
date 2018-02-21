pragma solidity 0.4.19;

contract Utils {

    function addressToBytes(address a) public pure returns (bytes b) {
       assembly {
            let m := mload(0x40)
            mstore(add(m, 20), xor(0x140000000000000000000000000000000000000000, a))
            mstore(0x40, add(m, 52))
            b := m
       }
    }
}
