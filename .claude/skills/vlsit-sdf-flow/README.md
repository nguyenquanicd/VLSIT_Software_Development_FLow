# vlsit-sdf-flow — Software development flow (orchestrator) / Skill tổng quản lý quy trình

## Purpose / Mục đích

Manages the whole AI-assisted software development flow for desktop and mobile apps: it starts or resumes a project, runs the eight step skills in order, stops at an approval gate after each step, and keeps the consolidated record `docs/sdf/MASTER.md`.

Quản lý toàn bộ quy trình phát triển phần mềm có AI hỗ trợ cho ứng dụng máy tính và điện thoại: khởi tạo hoặc tiếp tục dự án, chạy tám skill theo thứ tự, dừng ở cổng duyệt sau mỗi bước và giữ file tổng hợp `docs/sdf/MASTER.md`.

## Functions / Chức năng

- Project intake: language, platforms, track (Full, Lite, Hotfix), commit policy. / Tiếp nhận dự án: ngôn ngữ, nền tảng, luồng (Full, Lite, Hotfix), chính sách commit.
- Gates: entry, draft and approval checks with `scripts/sdf-gate.ps1`; status with `sdf-status.ps1`; records with `sdf-record.ps1`. / Cổng kiểm tra vào bước, bản nháp và duyệt; xem trạng thái; ghi trạng thái.
- Shared rules for all steps: confirmation protocol (every question explains why), resource (RAM first) and security gates, evidence ledger, change control. / Quy tắc dùng chung: giao thức xác nhận (mọi câu hỏi đều giải thích vì sao), cổng tài nguyên (ưu tiên RAM) và bảo mật, sổ bằng chứng, kiểm soát thay đổi.
- Offers every choice as options with pros, cons and the effect on memory, security, cost and time, and aims at the lowest total cost. / Đưa mọi lựa chọn dưới dạng phương án có ưu điểm, nhược điểm và tác động tới bộ nhớ, bảo mật, chi phí, thời gian; hướng tới tổng chi phí thấp nhất.
- Script library (`library/`, `scripts/sdf-library.ps1`): finds and reuses scripts, proposes saving new reusable ones with the user's approval, checks integrity by SHA-256; the AI never edits the skill instructions itself. / Thư viện script: tìm và dùng lại script, đề xuất lưu script tái sử dụng mới khi được người dùng duyệt, kiểm tra toàn vẹn bằng SHA-256; AI không tự sửa hướng dẫn của skill.
- Always shows the progress line (the step that is running and how many steps remain) at the start of every message that asks you something, and on every question header. / Luôn hiện dòng tiến độ (bước đang chạy và số bước còn lại) ở đầu mọi tin nhắn có hỏi bạn, và trên tiêu đề của mỗi câu hỏi.

## Inputs and output / Đầu vào và đầu ra

Input: the project folder and what you want to build. Output in the project: `docs/sdf/MASTER.md` and `docs/sdf/01-requirements.md` … `08-feedback.md`.

Đầu vào: thư mục dự án và điều bạn muốn xây dựng. Đầu ra trong dự án: `docs/sdf/MASTER.md` và `docs/sdf/01-requirements.md` … `08-feedback.md`.

## Use / Cách gọi

    Claude Code:  /vlsit-sdf-flow I want to build a Windows tray app that ...
    Codex:        $vlsit-sdf-flow I want to build a Windows tray app that ...

Install all nine `vlsit-sdf-*` folders together; the step skills read shared files from this folder. / Cài đủ chín thư mục `vlsit-sdf-*` cùng nhau; các skill từng bước đọc tệp dùng chung từ thư mục này.

Instructions: [SKILL.md](SKILL.md). Installation: see the repository README. / Cài đặt: xem README của repository.

## Language convention / Quy định ngôn ngữ

Skill instructions and references are in English. README files are bilingual English–Vietnamese. Documents produced for the user follow the language chosen in the intake.

Nội dung skill và tài liệu tham khảo bằng tiếng Anh. README song ngữ Anh–Việt. Tài liệu tạo cho người dùng theo ngôn ngữ đã chọn khi tiếp nhận dự án.

## Author / Tác giả

Nguyễn Quân — [github.com/nguyenquanicd](https://github.com/nguyenquanicd) — [VLSIT_Software_Development_FLow](https://github.com/nguyenquanicd/VLSIT_Software_Development_FLow). Apache License 2.0.
