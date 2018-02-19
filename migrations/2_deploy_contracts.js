var Ownable = artifacts.require("Ownable");
var SafeMath = artifacts.require("SafeMath");
var AccessControl = artifacts.require("AccessControl");
var RxData = artifacts.require("RxData");

module.exports = function(deployer) {
  // Base dependencies
  deployer.deploy(Ownable);
  deployer.deploy(SafeMath);

  // Link dependencies to AccessControl
  deployer.link(Ownable, AccessControl);
  deployer.deploy(AccessControl);

  // Link dependencies to RxData
  deployer.link(AccessControl, RxData);
  deployer.link(SafeMath, RxData);
  deployer.deploy(RxData);
};
