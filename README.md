# Project ORION — Digital Forensics Demonstration

**Project ORION** is an educational digital-forensics project that demonstrates how web activity and digital evidence can be examined, organized, and interpreted during an investigation.

🌐 **Live Website:** https://harshitha-forensics.github.io/Project-ORION/website/

## About the Project

ORION presents a research-archive interface where users can explore topics and download sample evidence packages. The project introduces the stages of a digital-forensics investigation, including examining available records, reviewing evidence files, creating a timeline, and understanding the limitations of digital evidence.

The project was developed as an educational demonstration for forensic awareness and learning.

## Features

- Research archive with multiple searchable topics
- Topic-specific research record pages
- Downloadable sample evidence package
- Investigator evidence log and research files
- Investigation workflow explaining search, access, download requests, and possible local deletion
- Educational discussion of evidence correlation and timeline reconstruction

## Technologies Used

- **Kali Linux** — forensic demonstration environment
- **Tor** — exploring privacy-focused web access in the original local demonstration
- **NGINX** — web server used in the local demonstration
- **HTML and CSS** — website structure and design
- **JavaScript** — interactive topic records
- **Bash** — command-line tasks
- **SHA-256** — demonstrating file-integrity verification

## Live Website and Local Demonstration

The website hosted through GitHub Pages provides the public-facing ORION interface and sample downloadable materials.

**The live GitHub Pages website is a static educational version.** It does not run the original Kali Linux/Tor/NGINX environment, collect live visitor activity, or provide real-time forensic monitoring. The original local demonstration used a separate environment to explain web-server logs and file-related evidence.

Some investigation stages shown on the website are illustrative. They are intended to explain a forensic workflow, not to claim that a real visitor’s activity has been automatically captured.

## Important Forensic Limitation

A web-server access log can show requests received by the server, such as a request for a file and the server’s response status. By itself, it cannot prove that the visitor successfully saved the file or later deleted it from their device.

Confirming a local download or deletion would require appropriate device-side evidence, such as browser artifacts, filesystem records, or other relevant forensic data. Findings should be correlated and interpreted carefully.

## Evidence Package

The downloadable sample package contains research files for multiple topics and an investigator evidence log. These files are educational sample materials, not records collected from real visitors.

## Acknowledgement

Special thanks to **Vinod Kaparthi Sir** for his valuable guidance and support throughout this project.

---

*Project ORION is intended for educational and authorized digital-forensics demonstrations.*
## Author

**Harshitha**  
Project Creator and Developer — Project ORION

Developed as an educational digital-forensics demonstration exploring web activity, evidence analysis, and investigation workflows.

## Acknowledgement

Special thanks to **Vinod Kaparthi Sir** for his valuable guidance and support throughout this project.
## Project Screenshots

### 1. ORION Homepage
![ORION Homepage](homepage.jpeg)

### 2. ORION Search Page
![ORION Search Page](serachpage.jpeg)

### 3. ORION Investigation Results
![ORION Investigation Results](result.jpeg)
