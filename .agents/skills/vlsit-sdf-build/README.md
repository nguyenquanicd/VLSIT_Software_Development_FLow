# vlsit-sdf-build — Step 5: Build and test / Bước 5: Xây dựng và kiểm thử

## Purpose / Mục đích

Implements the plan task by task, test first, and proves after each task that memory stays within budget and that the security checks pass, on a release build.

Triển khai kế hoạch từng việc một, viết test trước, và sau mỗi việc chứng minh bộ nhớ nằm trong ngân sách và các kiểm tra bảo mật đạt, trên bản release.

## Functions / Chức năng

- Red, green, refactor loop with the whole suite after each task. / Vòng đỏ, xanh, tái cấu trúc, chạy toàn bộ test sau mỗi việc.
- `scripts/measure-memory.ps1`: private working set (the Task Manager number), helper processes included, trend and budget verdict. / Đo private working set (số Task Manager hiển thị), gồm tiến trình con, xu hướng và kết luận so với ngân sách.
- Stop rules for budget overruns, failed security checks, design gaps and scope growth. / Quy tắc dừng khi vượt ngân sách, kiểm tra bảo mật hỏng, thiếu sót thiết kế, hoặc mở rộng phạm vi.
- Cost guard: nothing that costs money is added without the user's confirmation; actual cost is tracked at each milestone. / Chốt chặn chi phí: không thêm thứ gì tốn tiền khi chưa được người dùng xác nhận; theo dõi chi phí thực tế ở mỗi mốc.
- Checks the script library before writing scripts and lists reusable scripts for a proposal. / Kiểm tra thư viện script trước khi viết script và liệt kê script tái sử dụng để đề xuất.

## Inputs and output / Đầu vào và đầu ra

Input: approved plan. Output: code and tests, `docs/sdf/05-build-report.md`, the Step 5 section and the "Measured (5)" ledger column.

Đầu vào: kế hoạch đã duyệt. Đầu ra: mã nguồn và test, `docs/sdf/05-build-report.md`, mục Step 5 và cột "Measured (5)" của sổ bằng chứng.

## Use / Cách gọi

    Claude Code:  /vlsit-sdf-build
    Codex:        $vlsit-sdf-build

Normally started by `vlsit-sdf-flow`. Instructions: [SKILL.md](SKILL.md). Installation: see the repository README. / Thường do `vlsit-sdf-flow` gọi. Cài đặt: xem README của repository.

## Author / Tác giả

Nguyễn Quân — [github.com/nguyenquanicd](https://github.com/nguyenquanicd) — [VLSIT_Software_Development_FLow](https://github.com/nguyenquanicd/VLSIT_Software_Development_FLow). Apache License 2.0.
