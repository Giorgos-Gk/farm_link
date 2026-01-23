# FarmLink – Agricultural Support & Communication Platform

FarmLink is a mobile application designed to support farmers by providing a communication and guidance system between farmers and agricultural experts.

The app allows users to send questions, images, and location data related to their crops and receive expert advice. It also keeps a history of interactions and observations for better tracking and decision-making.

---

## Main Features

- Messaging system between farmers and experts
- Image sharing for crop analysis
- Location and field data tracking
- History of guidance and observations
- Secure data storage using Firebase
- Clean and simple user interface

---

## Tech Stack

- Flutter
- Firebase Authentication
- Firestore Database
- Firebase Storage
- Firebase Cloud Functions (backend logic)

---

## Project Structure

This repository contains the frontend part of the FarmLink application.

All secure operations and business logic are handled in Firebase Cloud Functions (see the separate functions repository).

---

## Purpose of the Application

FarmLink aims to:

- Help farmers receive fast and accurate support
- Digitize communication in agricultural production
- Provide organized tracking of crop issues and solutions
- Make agricultural guidance more accessible

---

## Setup

1. Clone the repository

git clone <repo-url>

2. Install dependencies

flutter pub get

3. Connect to your Firebase project

Make sure your Firebase configuration is properly set in the app.

---

## Firebase

This project uses Firebase for:

- Authentication
- Database (Firestore)
- File storage
- Backend logic via Cloud Functions

No secrets or API keys are stored in this repository.

---

## Best Practices Followed

- Clean separation between frontend and backend
- Secure handling of data via Firebase rules
- Reproducible project setup
- Organized structure for scalability

---

## Status

This project was developed as part of an academic project and serves as a complete prototype of an agricultural communication system.
