var Web3 = require('web3');
var AccessControl = artifacts.require("AccessControl");

contract('AccessControl', (accounts) => {
    var web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));

    var owner = accounts[0];
    var user = accounts[1];
    var authorizedUser = accounts[2];

    it("should add authorized user", function() {
        var contract;

        return AccessControl.deployed().then(function(instance) {
            contract = instance;

            // Add authorized user
            return contract.addAuthorizedUser(authorizedUser, {from: owner});
        }).then(function() {
            var authorizedAddress = contract.getAuthorized(0, {from: owner});

            // Get list of authorized users
            return authorizedAddress;
        }).then(function(result) {
            var authorizedAddress = result;

            // Assert newly added address matches
            assert.equal(authorizedUser, result, "authorized user isn't properly added");
        });
    });
})
