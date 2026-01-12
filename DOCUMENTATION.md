# GreenLoop MVP - Smart Waste Management System

## Project Overview
**GreenLoop** is a comprehensive smart waste management ecosystem designed to streamline waste collection, recycling, and rewards for urban environments (initially focused on Kozhikode). The application caters to four distinct user roles, ensuring a closed-loop system from waste generation to processing.

## Current Status (January 2026)
The application is currently in the **MVP (Minimum Viable Product)** phase with core functionalities implemented across all user roles. 

### Recent Major Updates:
- **Dual-Mode Booking:** Residents can now choose between:
  - **Pre-book (Scheduled):** Select a specific date and time for collection.
  - **Instant Release (Truck Nearby):** Trigger immediate collection when the truck is in the area (hides date/time selection).
- **Express Tracking:** Replaced the static "Green Points" card with a dynamic **Express Card** that allows residents to track collection trucks in real-time via a live map.
- **UI Refinement:**
  - Removed "Scan QR" from quick actions to simplify the user journey.
  - Standardized AppBar designs across screens (Resident Book Pickup, Rewards) using `AppTheme.primaryGreen` with white foreground for better contrast.
  - Fixed syntax and layout issues in the Book Pickup screen.
- **Responsive Layout:** Integrated `ResponsiveHelper` to ensure the UI scales correctly across different device sizes.

---

## User Roles & Key Features

### 1. Resident (Generator)
- **Dashboard:** Overview of pending pickups, recycling statistics, and the new **Express Truck Tracking**.
- **Book Pickup:** Interactive form to schedule waste collection by type (Mixed, Dry, Wet, etc.).
- **Rewards:** Gamified system where residents earn "Green Points" for responsible waste disposal.
- **Profile:** Management of personal details and pickup history.

### 2. Worker (Collector)
- **Assignments:** View and accept pickup requests nearby.
- **Route Optimization:** (In development) Integration with maps for efficient collection.
- **Collection Verification:** Tools to mark pickups as complete and record waste weight.

### 3. Recycler (Processor)
- **Dashboard:** High-level summary of processed vs. pending tonnage.
- **Material Management:** Add and track materials coming in and certificates issued.
- **EPR Compliance:** Tools for ensuring Extended Producer Responsibility (EPR) standards are met.

### 4. Admin (Supervisor)
- **Dashboard:** Total system analytics, user management, and service health monitoring.
- **Settings:** Global configuration for the application.

---

## Technical Stack
- **Framework:** Flutter (Material 3)
- **State Management:** Provider
- **Design System:** Custom `AppTheme` with glassmorphism and modern aesthetics.
- **Key Dependencies:**
  - `google_maps_flutter`: For live truck tracking and navigation.
  - `fl_chart`: For data visualization in dashboards.
  - `qr_code_scanner_plus`: For secure pickup verification.
  - `firebase_core`: For authentication and cloud messaging.

---

## Architecture
- **`/lib/screens`:** Organized by role (admin, resident, recycler, worker) + common screens.
- **`/lib/services`:** Decoupled logic for Auth, Pickups, Rewards, and Admin functions.
- **`/lib/models`:** Strongly typed data structures for consistent data handling.
- **`/lib/theme`:** Centralized design tokens (colors, spacing, typography).

## Roadmap & Next Steps
1. **Live Map Integration:** Fully connect the "Express" card to the backend for real-time truck GPS data.
2. **Notification System:** Implement push notifications for pickup reminders and reward alerts.
3. **Analytics Deep Dive:** Expand the admin dashboard with more granular waste generation reports.
