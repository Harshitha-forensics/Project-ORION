# Project ORION — Digital Forensics Demonstration

An educational cybersecurity project demonstrating a Tor onion-service research portal and digital-forensics investigation using NGINX access logs.

## About the Project

Project ORION explores how surviving web-server records can help reconstruct recorded activity on a controlled research portal.

A visitor searches the portal and downloads a harmless sample evidence package. The investigator examines the server logs and correlates recorded requests with available local file evidence.

## Objectives

- Demonstrate a Tor onion-service website.
- Understand HTTP request logging using NGINX.
- Examine recorded search and download requests.
- Correlate timestamps, requested resources, and available file evidence.
- Generate an investigation timeline and report.

## Technologies Used

- Kali Linux
- Tor onion services
- NGINX
- HTML and CSS
- Bash scripting
- SHA-256 hashing

## Demonstration Workflow

1. Start the web server and Tor service.
2. Open the ORION research portal.
3. Search for a sample topic.
4. Download a harmless evidence package.
5. Delete the local downloaded copy for the demonstration.
6. Examine surviving server logs and available file evidence.
7. Correlate the findings and prepare a case report.

## Repository Contents

- `ORION_SOURCE_CODE.zip` — packaged source files.
- `website/` — website pages and styling.
- `scripts/` — startup and investigation scripts.
- `tor/torrc.example` — example Tor configuration.
- `nginx/orion-site.conf` — example NGINX configuration.
- `screenshots/` — project screenshots, to be added.

## Forensic Limitations

This is a controlled educational demonstration. Server logs record HTTP requests but do not independently prove a visitor's real-world identity or prove secure deletion. ORION does not break Tor anonymity or guarantee recovery of deleted files.

## Project Status

Educational prototype developed for a digital-forensics demonstration.

**Author:** Harshitha
