# 🚨 Raksha – A Real-Time Women Safety Application.

Raksha is a real-time women safety system. It is a multi-module solution built to tackle increasing safety concerns by leveraging AI-powered surveillance, real-time alerts, and mobile-enabled responses.

---

## 🧠 Problem Statement

**Women's safety in public spaces remains a critical challenge.** Traditional surveillance systems are either under-equipped or lack intelligence for preventive action. There is a pressing need for smarter, more responsive systems that can **detect threats proactively** and assist both users and authorities in real time.

---

## 💡 Our Solution: Raksha

Raksha is a **three-part application ecosystem** designed to enhance women’s safety using smart detection, live monitoring, and immediate alert systems.

### 🧩 System Components

| Module                        | Description                                                                 |
|------------------------------|-----------------------------------------------------------------------------|
| `Raksha_User_App`            | Android app for women to receive real-time alerts, trigger emergency help, and view safe routes. |
| `Raksha_Web_Surveillance`    | Web-based panel for police to monitor live CCTV feeds, get alert notifications, and manage incidents. |
| `Raksha_bit_marshal_app`     | App for field marshals to act as safety responders where CCTV coverage is unavailable. |

---

## 🚀 Key Features & Innovations

- 🔍 **Real-Time Threat Detection** using CV + deep learning (YOLOv8, ResNet).
- 🚗 **Suspicious Vehicle & Weapon Detection** with license plate recognition (EasyOCR).
- 📍 **Route Safety Analysis** via continuous CCTV processing.
- 📱 **Plan-B Field Response** app when surveillance is unavailable.
- 🔊 **Voice Monitoring** during emergencies (Raksha Mode ON).
- 🔐 **PIN-Based Safety Confirmation** from the user side.
- 🟡🟠🔴 **Color-Coded Alerts** to represent severity levels.

---

## ⚙ Tech Stack

- **Frontend:** Flutter, ReactJS
- **Backend:** Node.js, Firebase, REST APIs
- **AI Models:** YOLOv8, ResNet50, Haar Cascades
- **Database:** Firestore, MongoDB
- **Tools & APIs:** OpenCV, EasyOCR, Google Maps API, Firebase Cloud Messaging

---

## 🎯 Impact & Uniqueness

- Identifies crime hotspots with gender-based crowd analytics.
- Works efficiently even in low-surveillance zones.
- Enables authorities to take **proactive** actions rather than **reactive**.
- 100% custom-built with ethical AI practices. No templates or reused solutions.

---

## 🔍 Anticipated Challenges

| Challenge | Our Approach |
|----------|----------------|
| Accurate Suspicious Activity Detection | Used optimized deep learning models with dataset fine-tuning |
| Limited Surveillance | Added Plan-B mobile app for marshals in blind spots |
| User Authentication | PIN verification on “I Am Safe” to avoid misuse |
| Route Monitoring | Real-time CCTV data preprocessing pipeline |
| Response Time | Real-time alerts and automated emergency escalation |

---

## 📌 Submission for: HackVortex 2025

**Round 1 – Open Innovation Challenge**

- ✅ Original Problem Identification  
- ✅ Innovative, Scalable Multi-App System  
- ✅ Complete, Functional Codebase  
- ✅ Clear Documentation & Real-Time Functionality  

> Built passionately to make a real-world difference. 100% plagiarism-free.

---

## 🛡 Team SHILEDAR


## 📎 How to Run

### 🖥 Web Panel
```bash
cd Raksha_Web_Surveillance
npm install
npm start
