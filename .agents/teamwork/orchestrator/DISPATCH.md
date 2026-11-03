## 2026-11-03T10:11:06Z
Create a comprehensive screen-wise and component-wise UI generation plan for the LinguaPages app based on the design specification in `design/design.md`. The plan decomposes every screen into discrete components for generation rather than generating complete screens at once, specifies screen-wise image naming for all components, and delivers the plan prior to any image generation.

Working directory: /Users/uswer/StudioProjects/linguaPages
Integrity mode: development

Reference material: `/Users/uswer/StudioProjects/linguaPages/design/design.md`

## Requirements

### R1. Screen-Wise and Component-Wise UI Generation Plan
Produce a complete UI generation plan at `design/ui_generation_plan.md` covering all screens and variants defined in `/Users/uswer/StudioProjects/linguaPages/design/design.md`. Decompose each screen into modular, individually generatable UI components instead of full-screen generations. Execution in this run is strictly limited to authoring the plan; do not generate image assets yet.

### R2. Screen-Wise Image Naming & Component Specifications
Define a consistent screen-wise naming schema for all component images to be generated in future steps. In `design/ui_generation_plan.md`, detail each component with:
- Exact screen-wise image filename (e.g., `<screen_number>_<screen_name>_<component_name>.png`)
- Target output file path within `design/components/`
- Component role and layout description
- Visual prompt details and generation parameters aligned with the shared style block in `design/design.md` (colors, typography, shapes, and Material 3 structure)

## Acceptance Criteria

### Scope & Structure
- [ ] `design/ui_generation_plan.md` exists and covers all 8 screens and their variants from `design/design.md` (1. Onboarding, 2. Library, 2b. Empty library, 2c. Filter and sort sheet, 2d. Book details sheet, 3. Settings, 4. Reader with chrome and hidden chrome, 4b. Appearance sheet, 4c. Text selection & dictionary, 4d. Contents & annotations, 4e. Search in book, 5. Read aloud player variants, 6. Lock-screen controls, 7. Premium appearance, 8. All annotations).
- [ ] Every screen is decomposed into discrete visual components rather than single full-screen generations.
- [ ] No image generation is executed; the deliverable is strictly the comprehensive planning document.

### Component Specifications & Naming
- [ ] Every component entry specifies an exact screen-wise image filename adhering to the defined naming scheme.
- [ ] Every component entry specifies a target image path located in `design/components/`.
- [ ] Every component entry includes generation prompts and styling parameters reflecting the shared style block of `design/design.md`.
