const ethers = require("ethers");
require("dotenv").config();
const express = require("express");
const app = express();
app.use(express.json());

const API_URL = process.env.API_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const contractAddress = process.env.CONTRACT_ADDRESS;

const provider = new ethers.providers.JsonRpcProvider(API_URL);
const signer = new ethers.Wallet(PRIVATE_KEY, provider);

const { abi } = require("./artifacts/contracts/Overtime.sol/Overtime.json");
const contractInstance = new ethers.Contract(contractAddress, abi, signer);


app.post("/addTask", async (req, res) => {
  const { time, expertise, dependencies, wage, deadline, divisible } = req.body;

  try {
    const tx = await contractInstance.addTask(time, expertise, dependencies, wage, deadline, divisible);
    await tx.wait();  
    res.status(200).json({ message: "Task added successfully", transactionHash: tx.hash });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Failed to add task" });
  }
});


app.post("/addWorker", async (req, res) => {
  const { hours, expertise, min_wage, wallet } = req.body;

  try {
    const tx = await contractInstance.addWorker(hours, expertise, min_wage, wallet);
    await tx.wait();  
    res.status(200).json({ message: "Worker added successfully", transactionHash: tx.hash });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Failed to add worker" });
  }
});


app.get("/checkStatus", async (req, res) => {
  try {
    const tasks = await contractInstance.getTasks();  t
    const formattedTasks = tasks.map(task => ({
      task_id: task.id,
      worker_id: task.workerId ? task.workerId : null,
      status: task.completed
    }));

    res.status(200).json({ tasks: formattedTasks });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Failed to fetch task status" });
  }
});


app.post("/checkWallet", async (req, res) => {
  const { worker_id } = req.body;

  try {
    const balance = await contractInstance.getWalletBalance(worker_id);  
    res.status(200).json({ worker_id, balance: balance.toString() });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Failed to check wallet balance" });
  }
});


const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
