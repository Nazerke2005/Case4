# LessonPlanBuilderAI (Case 4)

---

## 🇰🇿 Жоба сипаттамасы (Қазақша)

**LessonPlanBuilderAI** — мұғалімдерге арналған iOS қосымша.  
Қосымша сабақ жоспарларын (ҚМЖ / поурочный план) автоматты түрде құруға,
шаблондарды қолдануға және жасанды интеллект арқылы толықтыруға мүмкіндік береді.

---

## 🎯 Мәселе (Problem Statement)

Мұғалімдер сабақ жоспарларын құруға көп уақыт жұмсайды және
нақты формат пен құрылым талаптарын сақтауы керек.  
Бұл процесті автоматтандыратын бірыңғай мобильді құрал жоқ.

---

## ✅ Жобаның мақсаты (Team Objective)

Мұғалімдерге мүмкіндік беретін iOS қосымша жасау:
- Сабақ жоспары шаблондары арқылы жұмыс істеу
- Дайын құрылымдарды (мақсат, сабақ барысы, бағалау) қолдану
- AI көмегімен сабақ мазмұнын автоматты толтыру
- Сабақ жоспарларын PDF және DOC форматында жүктеу
- Сабақ жоспарларын сақтау және басқару

---

## ✨ Негізгі мүмкіндіктер

- 📄 Сабақ жоспарын құру (пән, сынып, тақырып, ҚМЖ құрылымы)
- 🤖 AI арқылы автоматты толтыру
- 🧩 ҚМЖ шаблоны (стандартқа сай)
- 💾 SwiftData арқылы деректерді сақтау
- 📤 PDF және DOC форматында жүктеу
- 🌍 Көптілді интерфейс (қазақша / орысша / ағылшынша)
- 🎨 SwiftUI негізіндегі заманауи дизайн

---

## 🛠 Техникалық стек

- **SwiftUI**
- **MVVM архитектурасы**
- **SwiftData**
- **AI API (Groq – OpenAI compatible)**
- **PDF/DOC генерация**
- **Git / GitHub**

---

## 👥 Команда мүшелері (Team Members)

- **Сабина**  
  UI/UX & SwiftUI Views  
  Data Persistence & AI Integration  

- **Назерке**  
  UI/UX & SwiftUI Views  
  Business Logic & MVVM  

- **Айгерим**  
  Документация  

---
🇺🇸 Project Description (English)
LessonPlanBuilderAI is an iOS application designed to help teachers automate
lesson plan creation using templates and AI assistance.

🎯 Problem Statement
Teachers spend a significant amount of time creating lesson plans
while following strict formatting requirements.
There is no unified mobile tool to automate this process.

✅ Project Objective
Develop an iOS application that allows teachers to:

Create lesson plans using templates

Use a structured lesson plan format

Generate content using AI

Export lesson plans to PDF and DOC formats

Store and manage lesson plans locally

✨ Key Features
📄 Lesson plan creation (subject, grade, objectives, lesson flow, assessment)

🤖 AI-powered auto-fill

🧩 Standard lesson plan template

💾 Persistent storage using SwiftData

📤 Export to PDF and DOC

🌍 Multilingual interface (Kazakh / Russian / English)

🎨 Modern SwiftUI-based UI

🛠 Technical Stack
SwiftUI

MVVM Architecture

SwiftData

AI API (Groq – OpenAI compatible)

PDF/DOC Export

GitHub

## ▶️ Қосымшаны іске қосу (How to Run)

1. Репозиторийді жүктеу:
```bash
git clone https://github.com/Nazerke2005/Case4.git
Xcode-та ашу:

bash
Копировать код
open Nazlab.xcodeproj
Info.plist ішіне API key қосу:

xml
Копировать код
<key>GROQ_API_KEY</key>
<string>your_api_key_here</string>
iOS Simulator немесе құрылғыда іске қосу (iOS 17+)

