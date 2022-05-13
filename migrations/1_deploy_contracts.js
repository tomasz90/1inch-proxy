const OneInchProxy = artifacts.require("OneInchProxy");

// polygon
const router = "0x11111112542D85B3EF69AE05771c2dCCff4fAa26";
const dai = "0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063";
const usdc = "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174";
const usdt = "0xc2132D05D31c914a87C6611C10748AEb04B58e8F";
const ust = "0x692597b009d13C4049a947CAB2239b7d6517875F";

module.exports = function (deployer) {
  deployer.deploy(OneInchProxy, router, dai, usdc, usdt, ust);
};
