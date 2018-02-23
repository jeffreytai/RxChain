var AccessControl = artifacts.require('AccessControl');
var RxData = artifacts.require("RxData");

contract('RxData', (accounts) => {
    const nullAddress = "0x0000000000000000000000000000000000000000";

    var owner = accounts[0];
    var authorizedAddr = accounts[1];
    var manufacturerAddr = accounts[2];
    var wholesalerAddr = accounts[3];
    var pharmacyAddr = accounts[4];
    var patientAddr = accounts[5];

    it("should register manufacturer", function() {
        var contract;

        return RxData.deployed().then(function(instance) {
            contract = instance;

            return contract.addAuthorizedUser(authorizedAddr, {from: owner});
        }).then(function() {
            return contract.registerManufacturer(manufacturerAddr, "Test Manufacturer", {from: authorizedAddr});
        }).then(function() {
            return contract.manufacturers.call(manufacturerAddr, {from: authorizedAddr});
        }).then(function(result) {
            var retrievedManufacturerAddr = result[0];

            assert.equal(manufacturerAddr, retrievedManufacturerAddr, "manufacturer not registered");
        });
    });

    it("should remove manufacturer", function() {
        var contract;

        return RxData.deployed().then(function(instance) {
            contract = instance;

            // Remove the manufacturer
            return contract.removeManufacturer(manufacturerAddr, {from: authorizedAddr});
        }).then(function() {
            // Attempt to retrieve the removed manufacturer
            return contract.manufacturers.call(manufacturerAddr, {from: authorizedAddr});
        }).then(function(result) {
            var retrievedManufacturerAddr = result[0];

            // Assert retrieved manufacturer is a null address
            assert.equal(retrievedManufacturerAddr, nullAddress, "manufacturer should be removed");
        });
    });

    it("should register wholesaler", function() {
        var contract;

        return RxData.deployed().then(function(instance) {
            contract = instance;

            // Register wholesaler
            return contract.registerWholesaler(wholesalerAddr, "Test Wholesaler", {from: authorizedAddr});
        }).then(function() {
            return contract.wholesalers.call(wholesalerAddr, {from: authorizedAddr});
        }).then(function(result) {
            var retrievedWholesalerAddr = result[0];

            // Assert wholesaler address matches the one registered
            assert.equal(wholesalerAddr, retrievedWholesalerAddr, "wholesaler not registered");
        });
    });

    it("should remove wholesaler", function() {
        var contract;

        return RxData.deployed().then(function(instance) {
            contract = instance;

            // Remove the wholesaler
            return contract.removeWholesaler(wholesalerAddr, {from: authorizedAddr});
        }).then(function() {
            // Attempt to retrieve the removed wholesaler
            return contract.wholesalers.call(wholesalerAddr, {from: authorizedAddr});
        }).then(function(result) {
            var retrievedWholesalerAddr = result[0];

            // Assert retrieved wholesaler is a null address
            assert.equal(retrievedWholesalerAddr, nullAddress, "wholesaler should be removed");
        });
    });

    it("should register pharmacy", function() {
        var contract;

        return RxData.deployed().then(function(instance) {
            contract = instance;

            // Register pharmacy
            return contract.registerPharmacy(pharmacyAddr, "Test Pharmacy", {from: authorizedAddr});
        }).then(function() {
            return contract.pharmacies.call(pharmacyAddr, {from: authorizedAddr});
        }).then(function(result) {
            var retrievedPharmacyAddr = result[0];

            // Assert pharmacy address matches the one registered
            assert.equal(pharmacyAddr, retrievedPharmacyAddr, "pharmacy not registered");
        });
    });

    it("should remove pharmacy", function() {
        var contract;

        return RxData.deployed().then(function(instance) {
            contract = instance;

            // Remove the pharmacy
            return contract.removePharmacy(pharmacyAddr, {from: authorizedAddr});
        }).then(function() {
            return contract.pharmacies.call(pharmacyAddr, {from: authorizedAddr});
        }).then(function(result) {
            var retrievedPharmacyAddr = result[0];

            // Assert retrieved pharmacy is a null address
            assert.equal(retrievedPharmacyAddr, nullAddress, "pharmacy should be removed");
        });
    });

    it("should register patient", function() {
        var contract;

        return RxData.deployed().then(function(instance) {
            contract = instance;

            // Register patient
            return contract.registerPatient(patientAddr, {from: authorizedAddr});
        }).then(function() {
            return contract.patients.call(patientAddr, {from: authorizedAddr});
        }).then(function(result) {
            var retrievedPatientAddr = result;

            // Assert patient address matches the one registered
            assert.equal(patientAddr, retrievedPatientAddr, "patient not registered");
        });
    });

    it("should remove patient", function() {
        var contract;

        return RxData.deployed().then(function(instance) {
            contract = instance;

            // Remove the patient
            return contract.removePatient(patientAddr, {from: authorizedAddr});
        }).then(function() {
            return contract.patients.call(patientAddr, {from: authorizedAddr});
        }).then(function(result) {
            var retrievedPatientAddr = result;

            // Assert retrieved patient is a null address
            assert.equal(retrievedPatientAddr, nullAddress, "patient should be removed");
        })
    });
});
