const NFT = artifacts.require("../contarcts/NFT.sol");

module.exports = function (deployer) {
    const tx=deployer.deploy(NFT);
    console.log(tx);
}