const OneInchProxy = artifacts.require("OneInchProxy");

module.exports = function (deployer) {
  deployer.deploy(OneInchProxy);
};
