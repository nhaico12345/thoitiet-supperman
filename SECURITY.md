# Security Policy

<!-- ═══════════════════════════════════════════════════════════════════════════
     🌤️ SIÊU THỜI TIẾT - Super Weather Pro
     Chính sách bảo mật và hướng dẫn báo cáo lỗ hổng
     ═══════════════════════════════════════════════════════════════════════════ -->

<div align="center">

## 🔐 Siêu Thời Tiết - Security Policy

**Chính sách bảo mật cho ứng dụng thời tiết thông minh**

[![Security](https://img.shields.io/badge/Security-Policy-22C55E?style=for-the-badge&logo=shield&logoColor=white)](SECURITY.md)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue?style=for-the-badge)](LICENSE)

</div>

---

## 📋 Supported Versions

Các phiên bản hiện đang được hỗ trợ cập nhật bảo mật:

| Phiên bản | Hỗ trợ | Ghi chú |
|:---------:|:------:|:--------|
| 1.0.x     | ✅ | Phiên bản hiện tại, được hỗ trợ đầy đủ |
| < 1.0     | ❌ | Phiên bản phát triển, không hỗ trợ |

> 💡 **Lưu ý**: Phiên bản hiện tại là `1.0.0` (Tháng 1/2026). Chúng tôi khuyến nghị người dùng luôn cập nhật phiên bản mới nhất để đảm bảo an toàn.

---

## 🛡️ Các Tính Năng Bảo Mật

Ứng dụng Siêu Thời Tiết được xây dựng với các lớp bảo mật sau:

### 🔑 Mã hóa dữ liệu

| Thành phần | Phương thức | Mô tả |
|:-----------|:------------|:------|
| **Key Storage** | FlutterSecureStorage | Lưu trữ khóa mã hóa an toàn trên thiết bị |
| **Data Encryption** | HiveAesCipher (AES-256) | Mã hóa dữ liệu cục bộ với AES-256 |
| **Key Generation** | Hive.generateSecureKey() | Tạo khóa ngẫu nhiên 256-bit |

### 🌐 Bảo mật API

- 🔒 **API Keys**: Được lưu trữ trong file `.env` (không được commit vào Git)
- 🔐 **HTTPS**: Tất cả kết nối API đều sử dụng HTTPS
- 🛡️ **Rate Limiting**: Áp dụng giới hạn tốc độ gọi API

### ☁️ Cloud Security

- **Firebase Firestore**: Áp dụng Security Rules để kiểm soát truy cập
- **Cloudinary**: Upload ảnh qua kênh bảo mật với API credentials

---

## 🚨 Reporting a Vulnerability

Nếu bạn phát hiện lỗ hổng bảo mật, vui lòng báo cáo theo hướng dẫn sau:

### 📬 Cách báo cáo

1. **KHÔNG** công khai lỗ hổng trên Issues công cộng
2. Gửi báo cáo qua một trong các kênh sau:
   - 📧 **GitHub**: Tạo **Private Security Advisory** tại [Security Advisories](https://github.com/nhaico12345/thoitiet-supperman/security/advisories)
   - 💬 **Liên hệ trực tiếp**: [@nhaico12345](https://github.com/nhaico12345) qua GitHub

### 📝 Nội dung báo cáo

Vui lòng cung cấp các thông tin sau trong báo cáo:

| Thông tin | Mô tả |
|:----------|:------|
| **Mô tả lỗ hổng** | Chi tiết về lỗ hổng đã phát hiện |
| **Các bước tái tạo** | Hướng dẫn từng bước để tái tạo lỗ hổng |
| **Tác động** | Mức độ nghiêm trọng và ảnh hưởng tiềm năng |
| **Phiên bản bị ảnh hưởng** | Phiên bản ứng dụng có lỗ hổng |
| **Gợi ý sửa lỗi** | (Tùy chọn) Đề xuất cách khắc phục |

### ⏱️ Thời gian phản hồi

| Giai đoạn | Thời gian |
|:----------|:----------|
| **Xác nhận nhận báo cáo** | Trong vòng 48 giờ |
| **Đánh giá ban đầu** | 3-5 ngày làm việc |
| **Cập nhật tiến độ** | Mỗi 7 ngày cho đến khi giải quyết |
| **Phát hành bản vá** | Tùy thuộc mức độ nghiêm trọng |

### 🏆 Ghi nhận đóng góp

Nếu lỗ hổng được xác nhận hợp lệ:

- ✅ Bạn sẽ được ghi nhận trong phần **Security Credits** (trừ khi bạn muốn ẩn danh)
- ✅ Chúng tôi sẽ phối hợp với bạn về thời điểm công bố phù hợp
- ✅ Bạn sẽ được cập nhật về tiến độ xử lý

### ❌ Các trường hợp không được chấp nhận

- Lỗ hổng trên phiên bản không được hỗ trợ
- Các lỗ hổng đã được biết đến và đang được xử lý
- Các vấn đề không liên quan đến bảo mật
- Các cuộc tấn công yêu cầu quyền truy cập vật lý vào thiết bị

---

## 🔒 Best Practices cho Người Dùng

Để đảm bảo an toàn khi sử dụng ứng dụng:

1. ✅ **Luôn cập nhật** phiên bản mới nhất của ứng dụng
2. ✅ **Không chia sẻ** API keys hoặc thông tin đăng nhập
3. ✅ **Kiểm tra permissions** trước khi cấp quyền cho ứng dụng
4. ✅ **Sử dụng mạng an toàn** khi đồng bộ dữ liệu

---

## 📚 Tài liệu liên quan

- 📖 [README.md](README.md) - Tổng quan dự án
- 🤝 [CONTRIBUTING.md](CONTRIBUTING.md) - Hướng dẫn đóng góp
- 📜 [AUTHORS.md](AUTHORS.md) - Danh sách tác giả
- ⚖️ [LICENSE](LICENSE) - Giấy phép Apache 2.0

---

<div align="center">

**Made with ❤️ and 🔐 in Vietnam 🇻🇳**

*Copyright © 2025-2026 DANGIT (Trần Đình Đăng). All rights reserved.*

</div>
