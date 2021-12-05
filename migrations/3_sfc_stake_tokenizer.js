const StakeTokenizer = artifacts.require('StakeTokenizer');

module.exports = function (deployer) {
    deployer.deploy(StakeTokenizer, 'StakeTokenizer');
};
