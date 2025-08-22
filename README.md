
# Digital Menu With QR Code

A modern Flutter web/mobile app for restaurant menu management, featuring:
- Admin dashboard for CRUD operations on menu items
- QR code generator for sharing the menu link
- News section for announcements
- Responsive, interactive UI with image upload and error handling

## Features

- **Admin Dashboard:** Add, edit, delete menu items by section (Special, Breakfast, Lunch & Dinner, etc.)
- **Menu Item Images:** Circular display, upload from device, placeholder for missing/error images
- **QR Code Generator:** Instantly generate and download QR codes for your menu web app URL
- **News Section:** Post and manage restaurant news
- **Responsive Design:** Works on desktop, tablet, and mobile browsers
- **Professional UI/UX:** Modern icons, color scheme, and interactive elements

## Tech Stack

- **Flutter** (Web & Mobile)
- **Provider** for state management
- **Supabase** (or Firebase) for backend (optional, can be replaced)
- **qr_flutter** for QR code generation
- **image_picker** for image upload

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-dart)
- (Optional) Supabase/Firebase account for backend

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/digital-menu-with-qr-code.git
   cd digital-menu-with-qr-code
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app (Web):**
   ```bash
   flutter run -d chrome --web-renderer html
   ```

4. **Run the app (Mobile):**
   ```bash
   flutter run
   ```

### Configuration

- Update Supabase/Firebase keys in main.dart if using a backend.
- You can use the app in demo mode without backend for UI showcase.

## Usage

- **Admin Dashboard:** Log in as admin, manage menu items, upload images, and generate QR codes.
- **QR Code:** Click the QR button in the app bar, enter your menu URL, and download/share the QR code.
- **News:** Post news and updates for your restaurant.

## Screenshots

| Dashboard | QR Generator | Edit Menu Item |
|-----------|-------------|----------------|
| !Dashboard | ![QR Generator](screenshots/qr_generator.png) | ![Edit Item](screenshots/edit_item.png) |

## Folder Structure

```
lib/
  data/
    providers/
    repositories/
    datasources/
  domain/
    entities/
    usecases/
  presentation/
    admin/
    home/
    common_widgets/
  main.dart
```

## Portfolio Highlights

- **Clean, maintainable code:** Follows best practices for Flutter and state management.
- **Professional UI/UX:** Custom widgets, error handling, and responsive layouts.
- **Feature-rich:** QR code integration, image upload, and CRUD operations.

## License

This project is open source and available under the MIT License.

## Author

- **Your Name**
- [LinkedIn](https://linkedin.com/in/your-profile)
- [GitHub](https://github.com/your-username)

---

**How to use:**
- Replace `your-username` and `Your Name` with your details.
- Add screenshots to a `screenshots/` folder for visual impact.
- Update backend config if you use Supabase/Firebase.

**README file location:**  
Place this content in your project root as README.md.

Let me know if you want a shorter version or more sections (e.g., backend setup, deployment)!