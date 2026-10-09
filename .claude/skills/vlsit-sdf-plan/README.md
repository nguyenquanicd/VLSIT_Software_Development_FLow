# vlsit-sdf-plan — Step 4: Plan / Bước 4: Kế hoạch

## Purpose / Mục đích

Turns the design into an ordered plan of small vertical slices, starting with a walking skeleton that already measures memory and runs security scans.

Biến thiết kế thành kế hoạch gồm các lát công việc nhỏ theo thứ tự, bắt đầu bằng bộ khung chạy được đã đo bộ nhớ và chạy quét bảo mật.

## Functions / Chức năng

- Tasks traced to requirements, with tests written first, a resource check and a security check each. / Mỗi việc gắn với yêu cầu, có test viết trước, kiểm tra tài nguyên và kiểm tra bảo mật.
- Definition of done, test and measurement plan, CI and tooling. / Định nghĩa hoàn thành, kế hoạch kiểm thử và đo, CI và công cụ.
- Lead-time items (signing certificates, store accounts) and the cut line confirmed with the user. / Các việc cần thời gian chờ (chứng chỉ ký, tài khoản store) và ranh giới cắt giảm được người dùng xác nhận.
- Cost estimate against the caps; the cheapest plan that meets every budget, with cuts offered as options. / Ước tính chi phí so với ngưỡng; kế hoạch rẻ nhất đáp ứng mọi ngân sách, các phương án cắt giảm kèm ưu nhược điểm.

## Inputs and output / Đầu vào và đầu ra

Input: approved design. Output: `docs/sdf/04-plan.md`, the Step 4 section and the "Planned check (4)" ledger column.

Đầu vào: thiết kế đã duyệt. Đầu ra: `docs/sdf/04-plan.md`, mục Step 4 và cột "Planned check (4)" của sổ bằng chứng.

## Use / Cách gọi

    Claude Code:  /vlsit-sdf-plan
    Codex:        $vlsit-sdf-plan

Normally started by `vlsit-sdf-flow`. Instructions: [SKILL.md](SKILL.md). Installation: see the repository README. / Thường do `vlsit-sdf-flow` gọi. Cài đặt: xem README của repository.

## Author / Tác giả

Nguyễn Quân — [github.com/nguyenquanicd](https://github.com/nguyenquanicd) — [VLSIT_Software_Development_FLow](https://github.com/nguyenquanicd/VLSIT_Software_Development_FLow). Apache License 2.0.
