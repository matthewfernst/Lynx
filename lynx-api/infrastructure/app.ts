#!/usr/bin/env node
import "source-map-support/register";
import { App } from "aws-cdk-lib";
import { InfrastructureStack } from "./lib/infrastructure";

const app = new App();
new InfrastructureStack(app, "InfrastructureStack");
