pragma solidity ^0.4.17;

import "./RxDataBase.sol";

contract RxData is RxDataBase {

    mapping(address => Manufacturer) public manufacturers;
    mapping(address => Wholesaler) public wholesalers;
    mapping(address => Pharmacy) public pharmacies;
    mapping(address => Patient) public patients;

    enum Status {
        MANUFACTURED,
        DISTRIBUTED, // at wholesale
        DISPENSED, // at pharmacy
        SOLD // given to patient
    }

    struct Manufacturer {
        address addr;
        bytes16 name;
    }

    struct Wholesaler {
        address addr;
        bytes16 name;
    }

    struct Pharmacy {
        address addr;
        bytes16 name;
    }

    struct Patient {
        address addr;
    }

    struct Medication {
        // Entity Id for each step in the process, allows for tracking
        uint256 medicationId;
        address manufacturerAddr;
        address wholesalerAddr;
        /* address pharmacyAddr;
        address patientAddr; */
        // Dates for each step in the process
        uint64 expirationDate;
        uint64 manufactureCreationDate;
        uint64 wholesaleReceiptDate;
        /* uint64 pharmacyReceiptDate;
        uint64 patientReceiptDate; */
        // Miscellaneous information
        bytes32 serialNumber;
        uint8 wholesalePrice;
        uint8 pharmacyPrice;
        uint8 patientPrice;
    }
}
