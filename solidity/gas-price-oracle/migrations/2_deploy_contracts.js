const contracts = [
  artifacts.require("strings.sol"),
  artifacts.require("usingOraclize.sol"),
]
const gasOracle = artifacts.require("GasPriceOracle.sol")

module.exports = deployer => {
  const gasPrice  = 2e10
  const amountETH = 1e17
  contracts.map(contract => deployer.deploy(contract))
  deployer.deploy(gasOracle, gasPrice, {value: amountETH})
}
