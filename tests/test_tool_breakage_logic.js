"use strict";

const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");
const post = fs.readFileSync(path.join(root, "Tormach_Inspection.cps"), "ascii");

function extractFunction(name) {
  const start = post.indexOf(`function ${name}(`);
  if (start < 0) {
    throw new Error(`Missing function ${name}`);
  }
  const bodyStart = post.indexOf("{", start);
  let depth = 0;
  for (let index = bodyStart; index < post.length; index += 1) {
    if (post[index] === "{") {
      depth += 1;
    } else if (post[index] === "}") {
      depth -= 1;
      if (depth === 0) {
        return post.slice(start, index + 1);
      }
    }
  }
  throw new Error(`Unclosed function ${name}`);
}

const properties = {
  toolBreakageCheckEveryTool: false,
  toolBreakageCheckList: "",
  toolBreakageIgnoreFusionFlag: false,
  toolBreakageIgnoreList: "",
};
const settings = {maximumToolNumber: 1000};
const TOOL_PROBE = "probe";
let toolBreakageCheckToolNumbers = [];
let toolBreakageIgnoreToolNumbers = [];

function getProperty(name) {
  return properties[name];
}

function localize(message) {
  return message;
}

function subst(message, value) {
  return message.replace("%1", value);
}

function error(message) {
  throw new Error(message);
}

function validate(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

const parseToolBreakageCheckList = eval(`(${extractFunction("parseToolBreakageCheckList")})`);
const parseToolBreakageIgnoreList = eval(`(${extractFunction("parseToolBreakageIgnoreList")})`);
const shouldCheckToolBreakage = eval(`(${extractFunction("shouldCheckToolBreakage")})`);

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

function reset() {
  properties.toolBreakageCheckEveryTool = false;
  properties.toolBreakageCheckList = "";
  properties.toolBreakageIgnoreFusionFlag = false;
  properties.toolBreakageIgnoreList = "";
  toolBreakageCheckToolNumbers = [];
  toolBreakageIgnoreToolNumbers = [];
}

const normalTool = {number: 2, type: "mill", breakControl: false};
const fusionSelectedTool = {number: 3, type: "mill", breakControl: true};
const probeTool = {number: 99, type: TOOL_PROBE, breakControl: true};

reset();
parseToolBreakageCheckList();
assert(!shouldCheckToolBreakage(normalTool), "Default settings selected a normal tool");
assert(shouldCheckToolBreakage(fusionSelectedTool), "Fusion Break Control was not honored");

properties.toolBreakageIgnoreFusionFlag = true;
assert(!shouldCheckToolBreakage(fusionSelectedTool), "Fusion Break Control was not ignored");

properties.toolBreakageCheckEveryTool = true;
assert(shouldCheckToolBreakage(normalTool), "Every-tool setting did not select a normal tool");
assert(!shouldCheckToolBreakage(probeTool), "Every-tool setting selected a probe");

properties.toolBreakageIgnoreList = "2, 3";
parseToolBreakageIgnoreList();
assert(!shouldCheckToolBreakage(normalTool), "Ignore list did not override every-tool selection");
assert(!shouldCheckToolBreakage(fusionSelectedTool), "Ignore list did not override Fusion Break Control");

reset();
properties.toolBreakageCheckList = " 1, 2, 7, 2 ";
parseToolBreakageCheckList();
assert(
  JSON.stringify(toolBreakageCheckToolNumbers) === JSON.stringify([1, 2, 7]),
  "Tool list parsing or duplicate removal failed"
);
assert(shouldCheckToolBreakage(normalTool), "Tool list did not select T2");
assert(!shouldCheckToolBreakage({number: 4, type: "mill", breakControl: false}), "Tool list selected T4");
assert(!shouldCheckToolBreakage(probeTool), "Tool list selected a probe");

properties.toolBreakageIgnoreList = " 2, 8, 2 ";
parseToolBreakageIgnoreList();
assert(
  JSON.stringify(toolBreakageIgnoreToolNumbers) === JSON.stringify([2, 8]),
  "Ignore list parsing or duplicate removal failed"
);
assert(!shouldCheckToolBreakage(normalTool), "Ignore list did not override check-list selection");

for (const invalid of ["1,,2", "T1", "0", "-1", "1001", "1.5"]) {
  reset();
  properties.toolBreakageCheckList = invalid;
  let failed = false;
  try {
    parseToolBreakageCheckList();
  } catch (exception) {
    failed = true;
  }
  assert(failed, `Invalid tool list was accepted: ${invalid}`);
}

for (const invalid of ["1,,2", "T1", "0", "-1", "1001", "1.5"]) {
  reset();
  properties.toolBreakageIgnoreList = invalid;
  let failed = false;
  try {
    parseToolBreakageIgnoreList();
  } catch (exception) {
    failed = true;
  }
  assert(failed, `Invalid ignore list was accepted: ${invalid}`);
}

console.log("Tool breakage selection tests passed.");
