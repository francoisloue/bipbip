# 🔔 Bipbip – Alerte Médicament pour ESP32 & Mobile

Bipbip est un projet qui vise à aider les personnes âgées à ne pas oublier de prendre leurs médicaments. Il repose sur un microcontrôleur **ESP32** et une application mobile Android. Une alarme sonore se déclenche automatiquement à l'heure programmée pour rappeler à l'utilisateur qu'il est temps de prendre ses médicaments.

---

## 📱 Fonctionnalités principales

- ⏰ Programmation d'alarmes
- 📲 Communication entre l'application mobile et l'ESP32 via Bluetooth
- 🔊 Alarme sonore (buzzer) et visuelle (LED)
- 👴 Pensé pour les personnes âgées : simple, fiable et autonome
- 🔘 Bouton physique pour désactiver l'alarme

---

## ⚙️ Technologies utilisées

### Côté matériel
- **ESP32** (WiFi + Bluetooth)
- **Arduino** (langage C++ via Arduino IDE)
- **Buzzer** pour la sonnerie
- **LED** pour l'indication visuelle
- **Bouton poussoir** pour désactiver l'alarme

### Côté mobile
- **Android Studio**
- **Dart / Flutter** (UI multiplateforme Android)
- **Bluetooth Low Energy (BLE)** pour communiquer avec l’ESP32

---

## 🔌 Fonctionnement général

1. L’utilisateur ou un proche configure les alarmes via l’application mobile.
2. Les horaires sont envoyés à l’ESP32 via Bluetooth.
3. À l’heure programmée, l’ESP32 active une alarme sonore et visuelle.
4. L’utilisateur peut appuyer sur un bouton pour éteindre l’alarme.
5. Le cycle recommence chaque jour selon la programmation.

---


## 🎯 Objectif

Permettre aux personnes âgées, souvent sujettes aux oublis de prise de médicaments, de rester autonomes et en sécurité, tout en rassurant leur entourage.

---

## 📚 À venir

- [ ] Amélioration du boitier
- [ ] Notification directe sur le téléphone
- [ ] Amélioration de la page blutooth qui est pas faite
---


## 📜 Licence

Projet open-source sous licence MIT.

---

> _Bipbip – parce qu’un rappel simple peut sauver des vies._
