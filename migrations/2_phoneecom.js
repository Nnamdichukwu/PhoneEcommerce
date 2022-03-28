const PhoneSales = artifacts.require("PhoneSales");

module.exports = function (deployer) {
  deployer.deploy(PhoneSales);
};
