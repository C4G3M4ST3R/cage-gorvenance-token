const hre = require("hardhat");
const ethers = hre.ethers;

async function main() {

  const Cgt = await ethers.getContractFactory("Cgt");
  const Distro = await ethers.getContractFactory("Distro");

  cgt = await Cgt.deploy();
  await cgt.deployed();
  console.log("1) CGT contract:", cgt.address);

  distro = await Distro.deploy(cgt.address);
  await distro.deployed()
  console.log("2) Distro contract:", distro.address);

  vestingAddr = await distro.vesting();
  console.log("3) Vesting contract:", vestingAddr);

  minterRoleHash = await cgt.MINTER_ROLE();
  await cgt.grantRole(minterRoleHash, vestingAddr);
  console.log("4) Vesting as minter saved!");

  await cgt.grantRole(minterRoleHash, distro.address);
  console.log("5) Distro as minter saved!");
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });