# Re-Focus: Screen Time Management App

## Description
Re-Focus is a Flutter mobile application designed to help users monitor and manage their daily screen time. It tracks individual app usage, allows users to set daily time and open limits, and provides visual feedback through dynamic charts and progress indicators.

## Features
- Track total daily screen time and individual app usage.
- Set custom daily limits for app usage (time and opens).
- Dynamic visualizations:
  - Pie charts showing top 5 most-used apps.
  - Linear progress bar for daily screen time.
- Persistent data storage using SharedPreferences.
- Onboarding flow to set your daily screen time goal.

## How it Works
- Queries Android system usage stats via the `usage_stats` API.
- Stores user-set goals and app limits using `SharedPreferences`.
- Uses Provider for state management to share app usage data across screens.
- Displays app usage with custom widgets (ProgressSection, PieChartSample3, AppUsageRow).

