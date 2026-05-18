## 💪 Muscles Training Club

A premium AI-powered fitness application built with Flutter and Firebase. The app combines intelligent workout planning, real-time exercise tracking, and AI coaching into a single platform with a stunning glassmorphism UI.

## 🔐 Authentication
 - Email and password login with Firebase Auth
 - Secure account creation with form validation
 - Password reset via email link
 - Persistent sessions across app restarts

## 🏠 Home Dashboard
 - Horizontal 7-day workout calendar with color-coded muscle groups
 - One-tap workout start for today's scheduled session
 - AI-generated daily fitness tips personalized to user goals
 - Water intake tracker with circular progress indicator
 - Quick stats showing weekly calories burned and workout count
 - AI plan feed showing pending and active plans with accept/reject controls

## 📅 Workout Planner
 - 15 prebuilt workout plans across three categories:
 - Gain Muscle: Chest, Back, Legs, Arms, Shoulders mass builders
 - Lose Weight: HIIT Cardio, Full Body, Core & Cardio
 - Maintain: Upper Body, Lower Body, Full Body, Active Recovery
 - Custom plan creation and editing tools
 - Weekly calendar assignment with drag-and-drop functionality
 - Rest day marking for recovery scheduling

## ⏱️ Active Workout Session
 - Live elapsed time counter during exercise
 - Tap-to-increment set and rep counters with haptic feedback
 - Automatic rest timer between sets (60-90 seconds)
 - Per-set weight logging with historical tracking
 - Mid-session exercise replacement capability
 - Real-time calorie burn calculation using MET values
 - Pause, resume, and finish controls with full session history save

## 📚 Exercise Library
 - 70+ exercises across 7 muscle groups: Chest, Back, Legs, Arms, Shoulders, Core, Cardio
 - Search functionality by exercise name or muscle group
 - Detailed step-by-step instructions with form tips
 - Custom exercise addition to personal database
 - Visual muscle group identification icons

## 🤖 AI Coach
 - GPT-4 powered fitness coaching through OpenRouter API
 - One-tap quick prompts for common fitness questions
 - Personalized responses using BMI, goals, and workout history
 - Markdown-formatted responses with tables and lists
 - Persistent conversation history storage

## 🎯 AI Workout Generator
 - Configurable parameters: training days (2-6), fitness level, goals
 - AI-generated custom plans with specific exercises, sets, reps, and rest periods
 - Markdown-formatted plan preview
 - Firebase storage with pending status for user review
 - Automatic weekly calendar integration upon acceptance

## 🥗 AI Diet Planner
 - Calorie targets calculated from user profile data
 - Protein, carbohydrate, and fat macro balancing
 - Full meal planning: breakfast, lunch, dinner, and snacks
 - Specific portion guidance in grams and ounces
 - Firebase storage with acceptance workflow

## 📊 Progress Tracking
 - Daily weight entry logging with date-stamped history
 - Complete workout session records with full statistics
 - Interactive fl_chart visualizations:
 - Weight progression line charts
 - Workout frequency bar charts
 - Calorie burn trend analysis
 - Automatic personal record tracking for lifts
 - Consecutive workout day streak counter
 - Body measurement logging: chest, arms, waist, thighs

## 👤 User Profile
 - Automatic BMI calculation with color-coded category display
 - Categories: Underweight, Normal, Overweight, Obese
 - Goal selection: Gain Muscle, Lose Weight, Maintain
 - Daily calorie target configuration (automatic or manual)
 - Body statistics tracking: height, weight, age, gender
 - Profile photo upload through Firebase Storage
 - Full profile editing capabilities
 - 💧 Water Tracker
 - Default 2500ml daily goal with customization option
 - Quick-add buttons: +250ml and +500ml
 - Animated circular progress indicator
 - Daily intake history log
 - Cloud synchronization through Firestore

 


 #  📦Muscular Training Club
 ```
├── 📁 lib/
│   │
│   ├── 📁 core/
│   │   ├── 📁 constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_text_styles.dart
│   │   │   ├── app_constants.dart
│   │   │   └── app_theme.dart
│   │   │
│   │   ├── 📁 utils/
│   │   │   ├── bmi_calculator.dart
│   │   │   ├── calorie_calculator.dart
│   │   │   ├── validators.dart
│   │   │   └── date_formatter.dart
│   │   │
│   │   └── 📁 widgets/
│   │       ├── glass_card.dart
│   │       ├── gradient_button.dart
│   │       ├── animated_background.dart
│   │       ├── stat_card.dart
│   │       └── circular_timer.dart
│   │
│   ├── 📁 models/
│   │   ├── user_model.dart
│   │   ├── workout_plan_model.dart
│   │   ├── workout_log_model.dart
│   │   ├── exercise_model.dart
│   │   ├── ai_plan_model.dart
│   │   ├── water_log_model.dart
│   │   └── weight_log_model.dart
│   │
│   ├── 📁 services/
│   │   ├── ai_service.dart
│   │   ├── auth_service.dart
│   │   ├── firestore_service.dart
│   │   ├── storage_service.dart
│   │   
│   │
│   ├── 📁 providers/
│   │   ├── auth_provider.dart
│   │   ├── workout_provider.dart
│   │   ├── plan_provider.dart
│   │   ├── progress_provider.dart
│   │   └── water_provider.dart
│   │
│   ├── 📁 screens/
│   │   │
│   │   ├── 📁 auth/
│   │   │   └── login_screen.dart
│   │   │
│   │   ├── 📁 home/
│   │   │   ├── home_screen.dart
│   │   │   ├── home_tab.dart
│   │   │   ├── workout_planner_screen.dart
│   │   │   └── 📁 widgets/
│   │   │       ├── daily_tip_card.dart
│   │   │       ├── plan_card.dart
│   │   │       ├── weekly_calendar.dart
│   │   │       └── quick_actions_row.dart
│   │   │
│   │   ├── 📁 workout/
│   │   │   ├── active_workout_screen.dart
│   │   │   ├── exercise_library_screen.dart
│   │   │   ├── workout_generator_screen.dart
│   │   │   ├── exercise_detail_screen.dart
│   │   │   └── 📁 widgets/
│   │   │       ├── exercise_tile.dart
│   │   │       ├── rest_timer.dart
│   │   │       ├── set_counter.dart
│   │   │       ├── rep_counter.dart
│   │   │       └── workout_complete_sheet.dart
│   │   │
│   │   ├── 📁 ai/
│   │   │   ├── ai_coach_screen.dart
│   │   │   ├── diet_screen.dart
│   │   │   └── 📁 widgets/
│   │   │       ├── chat_bubble.dart
│   │   │       ├── quick_prompt_chip.dart
│   │   │       └── markdown_message.dart
│   │   │
│   │   ├── 📁 progress/
│   │   │   ├── progress_screen.dart
│   │   │   ├── weight_log_screen.dart
│   │   │   ├── workout_history_screen.dart
│   │   │   └── 📁 widgets/
│   │   │       ├── weight_chart.dart
│   │   │       ├── workout_bar_chart.dart
│   │   │       ├── stat_summary.dart
│   │   │       └── pr_badge.dart
│   │   │
│   │   └── 📁 profile/
│   │       ├── profile_screen.dart
│   │       ├── edit_profile_screen.dart
│   │       └── 📁 widgets/
│   │           ├── bmi_gauge.dart
│   │           ├── goal_selector.dart
│   │           └── stat_row.dart
│   │
│   ├── 📁 routes/
│   │   └── app_router.dart
│   │
│   ├── firebase_options.dart
│   └── main.dart
│
├── 📁 assets/
│   ├── 📁 images/
│   │   ├── logo.png
│   │   ├── onboarding_1.png
│   │   ├── onboarding_2.png
│   │   └── onboarding_3.png
│   │
│   ├── 📁 icons/
│   │   ├── chest_icon.svg
│   │   ├── back_icon.svg
│   │   ├── legs_icon.svg
│   │   ├── arms_icon.svg
│   │   ├── shoulders_icon.svg
│   │   ├── core_icon.svg
│   │   └── cardio_icon.svg
│   │
│   └── 📁 animations/
│       ├── confetti.json
│       └── trophy.json
│
├── 📁 test/
│   ├── unit/
│   │   ├── bmi_calculator_test.dart
│   │   └── calorie_calculator_test.dart
│   │
│   └── widget/
│       ├── login_screen_test.dart
│       └── home_screen_test.dart
│
├── pubspec.yaml
├── pubspec.lock
├── analysis_options.yaml
├── .gitignore
├── .env
└── README.md
 ```
## 📦 Package Usage 

 - firebase_core: ^2.27.0
 - firebase_auth: ^4.17.0
 - cloud_firestore: ^4.15.0
 - firebase_storage: ^11.6.0
 - provider: ^6.1.2
 - google_fonts: ^6.2.1
 - flutter_animate: ^4.5.0
 - shimmer: ^3.0.0
 - fl_chart: ^0.67.0 
 - lottie: ^3.1.0
 - go_router: ^13.2.0
 - http: ^1.2.0
 -  dio: ^5.4.1
 - shared_preferences: ^2.2.3
 - intl: ^0.19.0
 - uuid: ^4.3.3
 - image_picker: ^1.0.7
 - cached_network_image: ^3.3.1
 - flutter_markdown: ^0.7.7+1
 - flutter_launcher_icons: ^0.14.4


 ![Splash](assets/screenshots/splash.jpeg) 
 ![Signup](assets/screenshots/signup.jpeg) 
 ![Login](assets/screenshots/login.jpeg) 
 ![Home](assets/screenshots/home.jpeg) 
 ![Home](assets/screenshots/home2.jpeg) 
 ![Library](assets/screenshots/exerciselibrary.jpeg)  
 ![Progress](assets/screenshots/progress.jpeg) 
 ![Profile](assets/screenshots/profile.jpeg) 
