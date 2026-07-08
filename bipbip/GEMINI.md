# 📄 GEMINI.md - Master Context (BipBip App)

> **AI Role:** You are an expert Flutter and IoT consultant. Your goal is to audit, maintain, and evolve the BipBip codebase while strictly adhering to this context.

---

## 🎯 1. Vision & Objective

**BipBip** is a medical adherence application.

* **Problem:** Patients often forget to take their medication at the correct times.
* **Solution:** A Flutter mobile application synced with a physical **ESP32** device via BLE. The app manages the schedule and medication data; the device handles the physical sound alarm.

---

## 🏗 2. Technical Stack

* **Frontend:** Flutter (iOS/Android).
* **Backend Communication:** REST API (Base URL: `http://localhost:8080`).
* **Medication Data:** Managed by our backend (proxies Giygas API) + Official Government Notices.
* **Hardware:** ESP32 via Bluetooth Classic (SPP) using `bluetooth_classic`.
* **Project Status:** POC integration (Bluetooth Classic).

---

## 📊 3. Data Models & API (OpenAPI Contract)

### Endpoints
* **Base URL:** `http://localhost:8080`
* **Users:** `/v1/bipbip/user` (GET, POST, PUT, DELETE)
* **Events:** `/v1/bipbip/event` (GET, POST, PUT, DELETE)
* **User Events:** `/v1/bipbip/event/user/{id}` (GET)
* **Medication Search:** `/v1/bipbip/medication?name={query}` (GET)

### Schemas
* **User:** `name`, `surname`, `age`, `weight`, `height`.
* **Medication:** `id`, `name`, `image_url`, `notice_url`.
* **Event:** `id`, `user_id`, `name`, `description`, `frequency`, `is_active`, `medication_id`, `take_pill_date`.

---

## 🔵 4. ESP32 Communication Protocol

1. **Expected Format:** Raw text representing an array of timestamps.
2. **Structure:** `HH,mm,ss` (e.g., "08,00,00").
3. **Sync Logic:**
* Fetch active `Events` from the backend.
* Calculate all intake times for the next 24 hours.
* Send these times as raw strings to the ESP32 via Serial Port Profile (SPP).
* **Standard SPP UUID:** `00001101-0000-1000-8000-00805f9b34fb`

---

## 📈 5. Project Roadmap (AI-Updated)

* [x] Project context definition.
* [x] Data Model implementation (Dart classes).
* [x] Medication search service (Backend API integration).
* [ ] Official Notice display logic (Dynamic URL linking).
* [ ] POC integration (Bluetooth Classic).
* [x] Frequency calculator and `HH,mm,ss` data transmission logic.
