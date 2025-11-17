ỨNG DỤNG TRA CỨU CÂY TRỒNG Wikicrop – MOBILE APP (FLUTTER)

Ứng dụng được phát triển nhằm hỗ trợ người dùng, đặc biệt là người nông dân, tra cứu nhanh thông tin các loại cây trồng dựa trên dữ liệu từ hệ thống MediaWiki – Wikicrop của Bộ môn/Khoa.
App được xây dựng bằng Flutter, chạy được trên Android / iOS.

1. Hướng dẫn tải về và chạy trên máy của thầy
🔧 Yêu cầu trước khi chạy

Thầy cần chuẩn bị:

Flutter SDK (phiên bản từ 3.x trở lên)
https://docs.flutter.dev/get-started/install

Android Studio hoặc VS Code

Một thiết bị Android hoặc Android Emulator

2. Cách tải mã nguồn từ GitHub

Thầy có thể tải theo 2 cách:

📌 Cách 1 — Tải file ZIP (đơn giản nhất)

Truy cập GitHub Repository:
https://github.com/hovanhondbs/APP_WIKICROP

Nhấn nút màu xanh Code

Chọn Download ZIP

Giải nén file ZIP

Mở thư mục dự án bằng VS Code hoặc Android Studio

📌 Cách 2 — Clone bằng Git

Nếu thầy đã cài Git, chỉ cần mở Terminal và gõ:
git clone https://github.com/hovanhondbs/APP_WIKICROP.git

3. Chạy dự án trên máy

Sau khi thầy mở dự án:

Mở Terminal trong VS Code

Chạy:

flutter pub get


Kết nối điện thoại Android hoặc mở Emulator

Chạy lệnh:

flutter run


Ứng dụng sẽ khởi động và hiển thị giao diện chính.

4. API hệ thống sử dụng

action=query&list=search: Tìm bài viết theo từ khóa

action=parse&prop=text|images: Lấy nội dung HTML và danh sách ảnh

action=query&prop=imageinfo: Lấy link ảnh gốc


