const { ethers } = require("hardhat");

async function main() {

  const Overtime = await ethers.deployContract("Overtime");

  console.log("Deploying contract...");

  await Overtime.waitForDeployment();

  console.log("Overtime deployed to:", Overtime.target);
}

// Run the main function and handle errors
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error:", error);
    process.exit(1);
  });
