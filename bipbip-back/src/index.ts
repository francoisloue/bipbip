import express, { Application, Router } from "express";
import dotenv from "dotenv";
import path from "path";
import { initialize } from "express-openapi";
import cors from "cors";
import fs from "fs";
import yaml from "js-yaml";
import Routes from "./router";

const app: Application = express();
dotenv.config();
const PORT: number = process.env.PORT ? parseInt(process.env.PORT, 10) : 8080;

const apiSpecPath = path.join(__dirname, "../doc/openapi.yaml");
const apiDoc = yaml.load(fs.readFileSync(apiSpecPath, "utf8")) as string;

const pathSpec = path.resolve(__dirname, "router");
app.use(cors());
app.use(express.json());
new Routes(app);

initialize({
    app,
    apiDoc,
    paths: pathSpec,
    dependencies: {
      log: console.log,
    }
});
  
app.listen(PORT, "0.0.0.0", () => {
    console.log(`server running on http://localhost:${process.env.PORT}/${process.env.ENV}/api/`);
}).on("error", (err: any) => {
    if (err.code === "EADDRINUSE") {
      console.log("Error: address already in use");
    } else {
      console.log(err);
    }
});
