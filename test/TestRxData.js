var AccessControl = artifacts.require('AccessControl');
var RxData = artifacts.require("RxData");

contract('RxData', (accounts) => {
    var owner = accounts[0];
    var authorizedAddr = accounts[1];
    var manufacturerAddr = accounts[2];
    var wholesalerAddr = accounts[3];
    var pharmacyAddr = accounts[4];
    var patientAddr = accounts[5];

    console.log(`owner: ${owner}`);
    console.log(`authorizedAddr: ${authorizedAddr}`);
    console.log(`manufacturerAddr: ${manufacturerAddr}`);
    console.log(`wholesalerAddr: ${wholesalerAddr}`);
    console.log(`pharmacyAddr: ${pharmacyAddr}`);
    console.log(`patientAddr: ${patientAddr}`);

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
});
