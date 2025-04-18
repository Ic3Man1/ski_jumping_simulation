# Ski Jumping Simulation

An interactive physics-based ski jumping simulator built in **Julia** using **GLMakie**. The app features sliders to tweak jumper and environmental conditions in real time, and displays three dynamic plots to visualize flight behavior.

---

## Simulation Overview

- Written entirely in Julia using `GLMakie`
- Live visualization of a jumper's flight through interactive sliders
- Three synchronized plots:
  - Forward trajectory
  - Side (crosswind) trajectory
  - Resultant velocity over time
- Based on realistic hill geometry (Courchevel)

---

## Features

- **Interactive parameter sliders** for:
  - Mass (kg)
  - Air density (kg/m³)
  - Jump angle (°)
  - Angle of attack (°)
  - Wind speed (m/s)
  - Side wind speed (m/s)
  - Take-off speed (m/s)
  - Jumper's body rotation (°)
- **Physics-based plotting** of:
  - `Ski Jumper's Trajectory` (X vs Height)
  - `Ski Jumper's Side Trajectory` (Z vs Height)
  - `Resultant Velocity over Time`
- Uses Courchevel hill profile:
  - `beta_p = 35.5°`, `beta_o = 5.9°`
  - `P_x = 71.26`, `P_y = -38.25`
  - `w = 90.0` (K-point distance)

---

## GUI Layout

- **Sliders** are displayed on the right-hand side
- **Plots** are positioned in a 2x2 grid
  - Top: Main trajectory
  - Bottom left: Velocity-time
  - Bottom right: Side trajectory

---

## How to Run

1. Make sure you have **Julia 1.8+** installed
