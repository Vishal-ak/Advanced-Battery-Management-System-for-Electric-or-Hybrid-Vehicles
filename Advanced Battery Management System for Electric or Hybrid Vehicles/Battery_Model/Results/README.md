# Results

This directory stores generated MATLAB simulation outputs. Subfolders follow the project module taxonomy documented in [Results and Figure Management](../Documentation/RESULTS_AND_FIGURE_MANAGEMENT.md).

Each demonstration figure is saved as:
- PNG at 300 dpi for reports and presentations.
- Editable MATLAB FIG for further inspection and modification.

Use the shared `Battery_Model/saveBMSFigure.m` helper from demonstration scripts. Do not manually save figures into the Results root or use generic filenames.

Current output categories:
- `Cell_Model/ECM/1RC/`
- `Cell_Model/ECM/Dynamic/`
- `SOC/CoulombCounting/`
- `Thermal/`

Only generated results belong here. Source scripts and test code remain in their respective source folders. A simulation result is not experimental validation; consult the documentation for model and data limitations.
