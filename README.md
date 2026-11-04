# Haflinger EV – Concept Calculations

MATLAB calculations for a small electric off-road vehicle inspired by the Puch Haflinger.
Concept: central electric motor (transverse), bevel stage, 2-speed planetary gearbox,
locking differentials, battery in the middle of the frame, foldable solar panels in
side boxes and a petrol range extender that charges at standstill.

## Requirements (spec sheet)
| Item | Target |
|---|---|
| Occupants / payload | 2 persons, 500 kg |
| Daily range | 80 km off-road |
| Max. gradient | 65 % |
| Top speed | 80 km/h |
| Width / ground clearance | ≤ 1.5 m / ≥ 300 mm |
| Solar yield | ≥ 5 kWh on a clear day |
| Operating temperature | −20 … +50 °C |

## How to run
1. Open the folder in MATLAB (R2019b or newer).
2. Run `main.m`.
3. Change inputs only in `params.m`. Results are printed and saved to `results/`.

## Structure
```
HaflingerEV/
├── main.m                       runs everything
├── params.m                     all inputs and requirements
├── data/
│   ├── mass_budget.csv          every part: qty, mass, position x/z, source
│   └── payload.csv              persons and cargo with position
├── src/
│   ├── massBudget.m             mass, CG, axle loads -> p.veh
│   ├── printMassBudget.m
│   ├── drivingResistance.m      rolling, grade and air resistance
│   ├── motorTorque.m            motor curve (const. torque / const. power)
│   ├── gearRatios.m             overall ratios of the driveline
│   ├── tractionAnalysis.m       65 % grade, top speed, power, adhesion, tipping
│   ├── energyBalance.m          energy for 80 km/day off-road
│   ├── solarYield.m             daily solar yield, required area
│   ├── batteryPack.m            pack layout, voltage window, currents, mass, cost
│   ├── printBattery.m
│   ├── rangeExtender.m          charging time, fuel, range per tank
│   ├── checkRequirements.m      PASS/FAIL table against the spec sheet
│   └── gearbox/
│       ├── gearboxLoads.m       torques/speeds per element and load case
│       ├── gearSizing.m         tooth root and flank safety
│       ├── gearGeometry.m       pitch, tip, root, base circles, bevel cone data
│       ├── shaftDesign.m        minimum shaft diameters
│       ├── bearingLife.m        planet bearing rating, bevel tooth forces
│       ├── printGearbox.m
│       └── printGearGeometry.m
├── plots/
│   ├── plotTractionDiagram.m
│   ├── plotEnergyBalance.m
│   └── plotMassBudget.m         side view with parts and CG
├── docs/
│   ├── E-Haflinger_Teileliste.xlsx  parts list with prices, sources, alternatives
│   └── img/                     plots and renderings for this README
└── results/                     generated: plots, .mat, .csv (not tracked)
```

## Methods
- Driving resistance and traction: standard longitudinal vehicle dynamics.
- Gear load capacity: simplified after DIN 3990 / ISO 6336 (method C level). Fatigue
  uses an equivalent stress from the load collective (Palmgren–Miner), the static
  check uses the peak case with application factor K_A. Bevel gears are checked as
  virtual spur gears.
- Gear geometry: reference profile DIN 867 / ISO 53, α = 20°, no profile shift.
- Shafts: torsion-only pre-sizing. Final check needs bending and notch factors (DIN 743).
- Bearings: nominal life after ISO 281 with equivalent load from the collective.

## Assumptions and limits
- Values marked `(A)` in `params.m` are assumptions and will change once
  components are chosen (vehicle mass, motor curve, efficiencies, load collective).
- No profile shift, no flank modifications, no thermal or lubrication checks.
- Results are concept-level pre-sizing, not a validated design.

## Status
- [x] Vehicle level: traction, energy, solar, range extender
- [x] Gearbox pre-sizing: loads, gears, geometry, shafts, planet bearings
- [x] Motor selection: PMSM 20/40 kW 96 V kit (210 Nm, 7000 rpm)
- [x] Battery pack: 30s2p EVE LF280K, 96 V, 53.8 kWh, one BMS, 2 boxes (15s2p, 48 V each) under the load bed
- [ ] Motor torque curve from datasheet (currently const. torque / const. power)
- [x] Mass budget bottom-up (data/mass_budget.csv, most values still estimates)
- [x] Tyres: 31x10.5R15 class, r_dyn 0.38 m
- [ ] Shaft check with bending moments (DIN 743)
- [ ] Shift elements (ring brake, lock-up clutch)
- [ ] CAD model

## Acknowledgments
I used Claude (Anthropic) as an assistant while working on this project, mainly for parts of the MATLAB code, translation, researching components and cross-checking calculations. The concept, calculations, the requirements and the design are my own.

## Author
Georg Müller, B.Sc. Mechanical Engineering, TU Munich
