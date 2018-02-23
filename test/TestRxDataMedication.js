var Web3 = require('web3');
var AccessControl = artifacts.require('AccessControl');
var RxData = artifacts.require('RxData');

contract('RxData', (accounts) => {
    var web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));

    var owner = accounts[0];
    var authorizedAddr = accounts[1];
    var manufacturerAddr = accounts[2];
    var wholesalerAddr = accounts[3];
    var pharmacyAddr = accounts[4];
    var patientAddr = accounts[5];
    var prescriptionHash;

    it("should add medication", function() {
        var contract;
        var totalMedication;

        return RxData.deployed().then(function(instance) {
            contract = instance;

            // Add authorized user for permissioned actions
            return contract.addAuthorizedUser(authorizedAddr, {from: owner});
        }).then(function() {
            // Register manufacturer to create medication
            return contract.registerManufacturer(manufacturerAddr, "Test Manufacturer", {from: authorizedAddr});
        }).then(function() {
            // Register medication
            return contract.registerMedication(manufacturerAddr, "XRBXLMBTCETH", 1, 2, 8, {from: manufacturerAddr});
        }).then(function() {
            // Retrieve total number of medication
            var totalMedication = contract.totalMedication({from: authorizedAddr});

            return totalMedication;
        }).then(function(result) {
            totalMedication = result;
            // Verify only one medication created
            assert.equal(totalMedication, 1, "medication incorrectly registered");
        }).then(function() {
            // Retrieve medication by id
            return contract.medications.call(totalMedication-1, {from: authorizedAddr});
        }).then(function(result) {
            // Remove null bytes from string
            var asciiSerialNumber = hexToAscii(result[2]).replace(/\0/g, '');

            // Assert values that were inserted
            assert.equal(result[0], 0, "medication id is incorrect");
            assert.equal(result[1], manufacturerAddr, "medication manufacturer is incorrect");
            assert.equal(asciiSerialNumber, "XRBXLMBTCETH", "medication serial number is incorrect");
            assert.equal(result[3], 1, "medication wholesale price is incorrect");
            assert.equal(result[4], 2, "medication pharmacy price is incorrect");
            assert.equal(result[5], 8, "medication patient price is incorrect");
        });
    })

    it("should create prescription", function() {
        var contract;

        return RxData.deployed().then(function(instance) {
            contract = instance;

            // Register wholesaler
            return contract.registerWholesaler(wholesalerAddr, "Test Wholesaler", {from: authorizedAddr});
        }).then(function() {
            var currentTimestamp = Math.floor(new Date() / 1000);
            var timestampInThreeYears = currentTimestamp + 94608000;

            // Create new prescription by manufacturer, destined for specific wholesaler
            return contract.createPrescription.call(0, wholesalerAddr, 0, 0, timestampInThreeYears, currentTimestamp, 0, 0, 0, {from: manufacturerAddr});
        }).then(function(result) {
            prescriptionHash = result.toString();

            // console.log(`prescriptionHash: ${prescriptionHash}`);
            // console.log(`prescriptionHashValue: ${prescriptionHash.valueOf()}`);
            //
            // return contract.prescriptions.call(prescriptionHash.valueOf(), {from: authorizedAddr});
        }).then(function(result) {
            console.log(`result: ${result}`);
        })
    })

    it("should remove medication", function() {
        var contract;

        return RxData.deployed().then(function(instance) {
            contract = instance;

            // Remove medication with id 0
            return contract.removeMedication(0, {from: manufacturerAddr});
        }).then(function() {
            // Retrieve count of medication
            var totalMedication = contract.totalMedication({from: authorizedAddr});

            return totalMedication;
        }).then(function(result) {
            // Assert all medications have been removed
            assert.equal(result, 0, "medication was not removed");
        });
    })

    function hexToAscii(hexx) {
        var hex = hexx.toString();
        var str = '';
        for (var i=0; i<hex.length; i+=2) {
            str += String.fromCharCode(parseInt(hex.substr(i, 2), 16));
        }
        return str;
    }
});
