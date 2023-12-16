#!/usr/bin/env node
import "source-map-support/register";
import { App } from "aws-cdk-lib";
import { LynxAPIStack } from "./lib/infrastructure";

const app = new App();
new LynxAPIStack(app, "LynxAPIStack");
