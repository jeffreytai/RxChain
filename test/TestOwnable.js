var Ownable = artifacts.require("Ownable");

contract('Ownable', (accounts) => {
    var owner = accounts[0];
    var newOwner = accounts[1];

    it("should have owner", function() {
        return Ownable.deployed().then(function(instance) {
            var owner = instance.owner.call();

            return owner;
        }).then(function(result) {
            // Assert current owner
            assert.equal(owner, result, "incorrect contract owner");
        });
    });

    it("should change owner", function() {
        var contract;

        return Ownable.deployed().then(function(instance) {
            contract = instance;

            // Transfer owner to accounts[1]
            return contract.transferOwnership(newOwner, {from: owner});
        }).then(function(result) {
            var transferredOwner = contract.owner.call({from: owner});

            // Promise to pass the value of the new owner
            return transferredOwner;
        }).then(function(result) {
            var transferredOwner = result;

            // Assert transfer to new owner
            assert.equal(result, newOwner, "contract was not transferred properly");
        });
    });
});
