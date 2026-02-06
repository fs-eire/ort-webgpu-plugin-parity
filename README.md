# ORT WebGPU Plugin EP Parity Test

Parity testing repository for ONNX Runtime WebGPU Plugin EP.

## Summary

This repository includes scripts to build two sets of artifacts: the baseline and the plugin EP.

## Build Steps

1. **Prerequisites**

   - Install `uv` (link TODO)

2. **Run Bootstrap**

   <details>
   <summary><b>Windows</b></summary>

   ```cmd
   bootstrap.bat
   ```
   </details>

   <details>
   <summary><b>Linux/macOS</b></summary>

   ```bash
   ./bootstrap.sh
   ```
   </details>

3. **Run Build**

   <details>
   <summary><b>Windows</b></summary>

   ```cmd
   build.bat
   ```
   </details>

   <details>
   <summary><b>Linux/macOS</b></summary>

   ```bash
   ./build.sh
   ```
   </details>

## How to Use

Once the build completes successfully, the baseline binaries are located in `parity_base`, and the plugin EP binaries are in `parity_plugin`.

Prepare an ONNX Runtime GenAI compatible model folder.

Run `model_benchmark` in either folder. The executable splits the run into 5 steps, pausing after each step to wait for ENTER. This allows you to attach/detach a debugger or profiler.