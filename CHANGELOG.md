# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [1.0.0] - 2026-11-02

The first release, as 1.0.0.

### Added
- `RioUk::Cinema.all` and `RioUk::Cinema.new(id)` for the Rio Cinema in Dalston, London, keyed `rio`, with its address from the website's footer and coordinates from OpenStreetMap.
- `RioUk::Performance.at(id, from:, to:)`, from the Savoy Systems programme embedded in the what's on page, which holds every advertised date in one request. Sold out performances are included without a booking link. Gigs and parties are left out.
- Variants from the Rio's performance flags and titles, film years from the listing, and title clean-up for strands, presenters, directors, extras and capitals.
- A fixture trimmed from a live page, a live shape test that checks real responses without storing them, and GitHub Actions CI and release workflows.
