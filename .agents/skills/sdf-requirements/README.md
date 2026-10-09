# sdf-requirements — Step 1: Requirements / Bước 1: Yêu cầu

## Purpose / Mục đích

Elicits and confirms the requirements of an app one decision at a time. Every question carries a "Why I ask" line, options with a recommendation, and a stated default if the answer is unknown.

Khai thác và xác nhận yêu cầu của ứng dụng từng quyết định một. Mỗi câu hỏi có dòng "Vì sao tôi hỏi", các lựa chọn kèm khuyến nghị và giá trị mặc định nếu người dùng chưa biết.

## Functions / Chức năng

- Eleven topics from goal and scope to platforms, data, cost and priorities. / Mười một chủ đề từ mục tiêu, phạm vi đến nền tảng, dữ liệu, chi phí và độ ưu tiên.
- Mandatory resource budgets (memory first) and security and privacy requirements. / Bắt buộc có ngân sách tài nguyên (ưu tiên bộ nhớ) và yêu cầu bảo mật, riêng tư.
- Ambiguity, conflict, completeness and testability scans; full read-back before approval. / Quét mơ hồ, xung đột, đầy đủ, kiểm thử được; đọc lại toàn bộ trước khi duyệt.
- Cost topic (T8): budget caps, who pays, what may be traded; it becomes `NFR-COST` rows. / Chủ đề Chi phí (T8): ngưỡng ngân sách, ai trả, có thể đánh đổi gì; trở thành các dòng `NFR-COST`.
- Every choice is offered as options with pros and cons. / Mọi lựa chọn đều có phương án kèm ưu nhược điểm.

## Inputs and output / Đầu vào và đầu ra

Input: what the user wants, and the repository if one exists. Output: `docs/sdf/01-requirements.md`, the Step 1 section and the ledger rows of `MASTER.md`.

Đầu vào: điều người dùng muốn và repository nếu có. Đầu ra: `docs/sdf/01-requirements.md`, mục Step 1 và các dòng sổ bằng chứng trong `MASTER.md`.

## Use / Cách gọi

    Claude Code:  /sdf-requirements
    Codex:        $sdf-requirements

Normally started by `sdf-flow`. Instructions: [SKILL.md](SKILL.md). Installation: see the repository README. / Thường do `sdf-flow` gọi. Cài đặt: xem README của repository.
