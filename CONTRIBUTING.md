# Hướng Dẫn Đóng Góp (Contributing Guidelines)

<!-- ═══════════════════════════════════════════════════════════════════════════
     SIÊU THỜI TIẾT - Super Weather Pro
     Hướng dẫn đóng góp cho dự án
     Copyright (c) 2024-2026 DANGIT (Trần Đình Đăng)
     ═══════════════════════════════════════════════════════════════════════════ -->

<div align="center">

## 🌤️ Cảm ơn bạn đã quan tâm đến dự án Siêu Thời Tiết!

Chúng tôi hoan nghênh mọi đóng góp từ cộng đồng ❤️

</div>

---

## 📋 Mục Lục

- [Quy Tắc Ứng Xử](#-quy-tắc-ứng-xử)
- [Cách Đóng Góp](#-cách-đóng-góp)
- [Thiết Lập Môi Trường](#-thiết-lập-môi-trường)
- [Coding Standards](#-coding-standards)
- [Commit Guidelines](#-commit-guidelines)
- [Pull Request Process](#-pull-request-process)

---

## 📜 Quy Tắc Ứng Xử

1. **Tôn trọng** - Đối xử với mọi người một cách tôn trọng
2. **Xây dựng** - Đưa ra phản hồi mang tính xây dựng
3. **Hỗ trợ** - Giúp đỡ những người mới bắt đầu
4. **Chuyên nghiệp** - Giữ thái độ chuyên nghiệp trong giao tiếp

---

## 🤝 Cách Đóng Góp

### 🐛 Báo Cáo Bug

1. Kiểm tra xem bug đã được báo cáo chưa trong [Issues](https://github.com/nhaico12345/thoitiet/issues)
2. Nếu chưa, tạo issue mới với template sau:

```markdown
**Mô tả bug:**
Mô tả rõ ràng bug là gì.

**Các bước tái hiện:**
1. Vào '...'
2. Nhấn vào '...'
3. Cuộn xuống '...'
4. Thấy lỗi

**Kết quả mong đợi:**
Mô tả những gì bạn mong đợi xảy ra.

**Screenshots:**
Nếu có, thêm ảnh chụp màn hình.

**Môi trường:**
- Device: [e.g. Samsung Galaxy S21]
- OS: [e.g. Android 12]
- Flutter version: [e.g. 3.9.0]
```

### ✨ Đề Xuất Tính Năng

1. Tạo issue với label `enhancement`
2. Mô tả rõ tính năng và lý do cần thiết
3. Đề xuất cách triển khai (nếu có)

### 💻 Đóng Góp Code

1. **Fork** repository
2. **Clone** fork của bạn:
   ```bash
   git clone https://github.com/YOUR_USERNAME/thoitiet.git
   ```
3. **Tạo branch** mới:
   ```bash
   git checkout -b feature/ten-tinh-nang
   ```
4. **Commit** thay đổi
5. **Push** lên fork
6. Tạo **Pull Request**

---

## 🛠️ Thiết Lập Môi Trường

### Yêu Cầu

- Flutter SDK >= 3.9.0
- Dart SDK >= 3.0.0
- Android Studio / VS Code
- Git

### Cài Đặt

```bash
# 1. Clone repository
git clone https://github.com/nhaico12345/thoitiet.git
cd thoitiet

# 2. Cài đặt dependencies
flutter pub get

# 3. Tạo file .env
cp .env.example .env
# Thêm API keys vào file .env

# 4. Chạy ứng dụng
flutter run
```

### Kiểm Tra Code

```bash
# Analyze code
flutter analyze

# Format code
dart format lib/

# Chạy tests
flutter test
```

---

## 📐 Coding Standards

### Cấu Trúc Thư Mục

```
lib/
├── core/           # Core functionality
│   ├── di/         # Dependency injection
│   ├── error/      # Error handling
│   ├── network/    # Network layer
│   ├── router/     # Navigation
│   ├── services/   # Core services
│   ├── theme/      # App theme
│   └── utils/      # Utilities
├── features/       # Feature modules
│   ├── feature_name/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
└── shared/         # Shared components
```

### Quy Tắc Đặt Tên

| Loại | Convention | Ví dụ |
|------|------------|-------|
| Files | snake_case | `weather_service.dart` |
| Classes | PascalCase | `WeatherService` |
| Functions | camelCase | `getWeather()` |
| Constants | SCREAMING_CASE | `MAX_RETRIES` |
| Variables | camelCase | `currentTemperature` |

### Comments

- Viết comments bằng **tiếng Việt** cho dự án này
- Comment ở đầu file mô tả mục đích
- Comment cho các logic phức tạp

```dart
// Lấy dữ liệu thời tiết từ API
// Nếu thất bại, thử lấy từ cache
Future<Weather> getWeather() async {
  // ...
}
```

---

## 📝 Commit Guidelines

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

| Type | Mô tả |
|------|-------|
| `feat` | Tính năng mới |
| `fix` | Sửa bug |
| `docs` | Thay đổi documentation |
| `style` | Format, không ảnh hưởng logic |
| `refactor` | Refactor code |
| `test` | Thêm/sửa tests |
| `chore` | Cập nhật dependencies, config |

### Ví Dụ

```bash
# Good
git commit -m "feat(weather): thêm widget dự báo 10 ngày"
git commit -m "fix(chat): sửa lỗi AI không phản hồi"
git commit -m "docs: cập nhật README với hướng dẫn cài đặt"

# Bad
git commit -m "update"
git commit -m "fix bug"
```

---

## 🔄 Pull Request Process

### Checklist Trước Khi Tạo PR

- [ ] Code đã được format (`dart format lib/`)
- [ ] Không có lỗi từ `flutter analyze`
- [ ] Đã viết tests cho tính năng mới
- [ ] Đã cập nhật documentation nếu cần
- [ ] Commit messages theo convention

### Template PR

```markdown
## Mô Tả
Mô tả ngắn gọn về thay đổi.

## Loại Thay Đổi
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Checklist
- [ ] Code follows project style
- [ ] Self-review completed
- [ ] Tests added/updated
- [ ] Documentation updated

## Screenshots (nếu có UI changes)
```

### Review Process

1. PR cần ít nhất **1 approval** từ maintainer
2. CI/CD phải pass tất cả checks
3. Conflicts phải được resolve
4. PR sẽ được merge bằng **Squash and Merge**

---

## 🏷️ Labels

| Label | Mô Tả |
|-------|-------|
| `bug` | Bug cần sửa |
| `enhancement` | Tính năng mới |
| `good first issue` | Phù hợp cho người mới |
| `help wanted` | Cần hỗ trợ từ cộng đồng |
| `documentation` | Cải thiện docs |
| `priority: high` | Ưu tiên cao |

---

## 📜 License

Khi đóng góp, bạn đồng ý rằng đóng góp của bạn sẽ được cấp phép theo [Apache License 2.0](LICENSE).

---

## 🙏 Cảm Ơn

Cảm ơn tất cả những người đã đóng góp cho dự án! 

Xem danh sách đầy đủ tại [AUTHORS.md](AUTHORS.md).

---

<div align="center">

**Có thắc mắc?** Tạo issue hoặc liên hệ [@nhaico12345](https://github.com/nhaico12345)

**Made with ❤️ in Vietnam 🇻🇳**

</div>
