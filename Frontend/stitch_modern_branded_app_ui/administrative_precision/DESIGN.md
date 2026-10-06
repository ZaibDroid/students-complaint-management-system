---
name: Administrative Precision
colors:
  surface: '#fbf8fc'
  surface-dim: '#dbd9dd'
  surface-bright: '#fbf8fc'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f5f3f6'
  surface-container: '#efedf1'
  surface-container-high: '#eae7eb'
  surface-container-highest: '#e4e2e5'
  on-surface: '#1b1b1e'
  on-surface-variant: '#45464e'
  inverse-surface: '#303033'
  inverse-on-surface: '#f2f0f3'
  outline: '#75777f'
  outline-variant: '#c5c6cf'
  surface-tint: '#505d84'
  primary: '#010f32'
  on-primary: '#ffffff'
  primary-container: '#172548'
  on-primary-container: '#7f8db6'
  inverse-primary: '#b8c5f1'
  secondary: '#5d5f5f'
  on-secondary: '#ffffff'
  secondary-container: '#dfe0e0'
  on-secondary-container: '#616363'
  tertiary: '#1e0e00'
  on-tertiary: '#ffffff'
  tertiary-container: '#3b2000'
  on-tertiary-container: '#b0855a'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dae2ff'
  primary-fixed-dim: '#b8c5f1'
  on-primary-fixed: '#0b1a3c'
  on-primary-fixed-variant: '#38466a'
  secondary-fixed: '#e2e2e2'
  secondary-fixed-dim: '#c6c6c7'
  on-secondary-fixed: '#1a1c1c'
  on-secondary-fixed-variant: '#454747'
  tertiary-fixed: '#ffdcbc'
  tertiary-fixed-dim: '#eebd8e'
  on-tertiary-fixed: '#2c1600'
  on-tertiary-fixed-variant: '#61401a'
  background: '#fbf8fc'
  on-background: '#1b1b1e'
  surface-variant: '#e4e2e5'
  surface-gray: '#F8FAFC'
  border-subtle: '#E2E8F0'
  status-pending: '#F59E0B'
  status-resolved: '#10B981'
  status-rejected: '#EF4444'
  status-forwarded: '#6366F1'
typography:
  headline-lg:
    fontFamily: Hanken Grotesk
    fontSize: 30px
    fontWeight: '700'
    lineHeight: 38px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Hanken Grotesk
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  headline-md:
    fontFamily: Hanken Grotesk
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-caps:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.05em
  button-text:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base-unit: 4px
  margin-page: 20px
  gutter-card: 16px
  stack-tight: 8px
  stack-loose: 24px
---

## Brand & Style

The design system is engineered for a high-stakes academic administrative environment. It prioritizes clarity, authority, and efficiency to facilitate a smooth "Complaint-to-Resolution" workflow. The target audience includes tech-savvy students and busy faculty members who require immediate access to status updates and action items.

The chosen style is **Minimalism with a Corporate/Modern influence**. This approach uses expansive white space to reduce cognitive load during complex filing processes. It leverages high-quality typography and a restricted color palette to establish a sense of institutional trust and professional rigor. Interface elements are clean and functional, avoiding decorative flourishes in favor of structural clarity and ease of use.

## Colors

The palette is anchored by a deep Navy Primary, representing the formal authority of the department. White is utilized as the secondary and dominant background color to maintain a "Bright/White" aesthetic that feels contemporary and clean.

- **Primary:** Used for key action buttons, active navigation states, and headers.
- **Secondary/Background:** Pure white surfaces ensure maximum readability.
- **Named Colors:** A set of functional status colors is defined to provide immediate visual feedback on complaint states (Pending, Resolved, etc.). A soft "Surface Gray" is used for subtle grouping of elements like input fields and card backgrounds to distinguish them from the main page surface.

## Typography

This design system employs a multi-font strategy to balance character with utility. **Hanken Grotesk** is used for headings to provide a sharp, contemporary professional feel. **Inter** is the workhorse for body text, chosen for its exceptional legibility on mobile screens. **JetBrains Mono** is utilized for small metadata and labels (like Complaint IDs or Timestamps) to evoke a technical, organized department vibe.

Type hierarchy is strictly enforced. Large headlines should be reserved for page titles, while bold body text or medium headlines handle section labeling. All labels in JetBrains Mono should be presented in uppercase to further distinguish them from narrative text.

## Layout & Spacing

The layout follows a **Fluid Grid** model optimized for Flutter's `Flex` and `ListView` widgets. The system relies on a 4px base-unit rhythm. 

- **Page Margins:** A consistent 20px horizontal margin is applied to all screens to ensure content does not touch the device edges.
- **Vertical Rhythm:** Elements within a card use `stack-tight` (8px) spacing, while major sections or distinct cards use `stack-loose` (24px).
- **Safe Areas:** Strictly respect mobile notches and home indicators, using the Primary color for the status bar and navigation bar background only when necessary for brand immersion.

## Elevation & Depth

Visual hierarchy is achieved through **Tonal Layers** supplemented by **Ambient Shadows**.

1.  **Level 0 (Base):** The main background uses pure white.
2.  **Level 1 (Cards):** Complaints, notices, and dashboard tiles use a white surface with a very subtle, diffused shadow (Blur: 12px, Y: 4px, Opacity: 4% Black). This makes them feel "lifted" but not heavy.
3.  **Level 2 (Active Elements):** Buttons and active chips use the Primary Navy color to create the highest level of visual prominence.
4.  **Separators:** Instead of heavy lines, use 1px borders in `border-subtle` (#E2E8F0) to define boundaries without adding visual noise.

## Shapes

The design system utilizes a **Rounded** (Level 2) shape language. This softens the formal nature of the Navy palette, making the app feel more approachable for students.

- **Standard Elements:** Buttons, Text Fields, and small Chips use a 0.5rem (8px) radius.
- **Large Containers:** Dashboard cards and Bottom Sheets use a 1rem (16px) radius for a more distinct, modern appearance.
- **Avatars:** User profile images should always be perfectly circular.

## Components

### Buttons
- **PrimaryButton:** Solid Primary Navy fill with White text. Bold weight.
- **SecondaryButton:** White fill with a 1px Navy border.
- **GhostButton:** No fill or border; Navy text. Used for "Cancel" or "Go Back" actions.

### Cards (Complaint & Notice)
- Use a white background with Level 1 elevation.
- Include a vertical color-coded bar (4px wide) on the left edge to indicate status (e.g., Green for Resolved).
- Use `label-caps` for the ID and `headline-md` for the title.

### Input Fields
- Fill with `surface-gray` and a `border-subtle`. 
- On focus, the border shifts to Primary Navy. 
- Ensure high contrast for hint text to meet accessibility standards.

### Chips & Badges
- **StatusChip:** Rounded-pill shape with a light-tinted background of the status color and a high-darkness version of the same color for the text.

### Timeline
- Use a vertical dashed line with small circular nodes. 
- Highlight the current stage with a Primary Navy node; previous stages use a soft gray.