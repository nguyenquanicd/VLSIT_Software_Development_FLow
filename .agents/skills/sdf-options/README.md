# sdf-options — Step 2: Options and recommendation / Bước 2: Phương án và đề xuất

## Purpose / Mục đích

After the requirements, the AI evaluates several approaches on its own, compares them in tables and recommends one. The user confirms the weights and makes the final choice.

Sau bước yêu cầu, AI tự đánh giá nhiều phương án, lập bảng so sánh và đề xuất hướng thực hiện. Người dùng xác nhận trọng số và quyết định cuối cùng.

## Functions / Chức năng

- At least three different options; eliminates those that break a hard requirement. / Ít nhất ba phương án khác nhau; loại phương án vi phạm yêu cầu cứng.
- Weighted scoring with weights confirmed before scoring (resource use and security weigh most by default). / Chấm điểm có trọng số, trọng số xác nhận trước khi chấm (mặc định ưu tiên tài nguyên và bảo mật).
- Resource and security tables, sensitivity check, recommendation with trade-offs and fallback. / Bảng tài nguyên và bảo mật, kiểm tra độ nhạy, đề xuất kèm đánh đổi và phương án dự phòng.
- Pros and cons table and cost profile (effort, one-off, recurring, total over a period); recommends the cheapest option that meets every Must. / Bảng ưu nhược điểm và hồ sơ chi phí (công sức, một lần, định kỳ, tổng theo kỳ); đề xuất phương án rẻ nhất đáp ứng mọi yêu cầu bắt buộc.

## Inputs and output / Đầu vào và đầu ra

Input: approved requirements. Output: `docs/sdf/02-options.md`, the Step 2 section of `MASTER.md`, a decision record.

Đầu vào: yêu cầu đã duyệt. Đầu ra: `docs/sdf/02-options.md`, mục Step 2 trong `MASTER.md`, bản ghi quyết định.

## Use / Cách gọi

    Claude Code:  /sdf-options
    Codex:        $sdf-options

Normally started by `sdf-flow`. Instructions: [SKILL.md](SKILL.md). Installation: see the repository README. / Thường do `sdf-flow` gọi. Cài đặt: xem README của repository.
