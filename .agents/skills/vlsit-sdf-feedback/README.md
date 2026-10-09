# vlsit-sdf-feedback — Step 8: Feedback / Bước 8: Phản hồi

## Purpose / Mục đích

After release: collects and triages feedback, checks field memory and security signals against the budgets and the SBOM, reviews incidents without blame, and feeds confirmed change requests back into step 1.

Sau phát hành: thu thập và phân loại phản hồi, đối chiếu dữ liệu bộ nhớ và tín hiệu bảo mật thực tế với ngân sách và SBOM, rà soát sự cố không đổ lỗi, và đưa các yêu cầu thay đổi đã xác nhận quay lại bước 1.

## Functions / Chức năng

- Triage table by type and severity; the user confirms decisions for High and above. / Bảng phân loại theo loại và mức độ; người dùng xác nhận quyết định từ mức High trở lên.
- Hotfix lane and confidential handling of vulnerability reports. / Luồng hotfix và xử lý bảo mật tin báo lỗ hổng.
- Change requests through change control; the next iteration ordered by the user. / Yêu cầu thay đổi qua kiểm soát thay đổi; vòng lặp tiếp theo do người dùng sắp thứ tự.
- Running cost against the caps; lessons and reusable scripts offered as one batch. / Chi phí vận hành so với ngưỡng; bài học và script tái sử dụng được đề xuất theo một lô.

## Inputs and output / Đầu vào và đầu ra

Input: the released version and its feedback sources. Output: `docs/sdf/08-feedback.md` and the Step 8 section of `MASTER.md`.

Đầu vào: phiên bản đã phát hành và các nguồn phản hồi. Đầu ra: `docs/sdf/08-feedback.md` và mục Step 8 trong `MASTER.md`.

## Use / Cách gọi

    Claude Code:  /vlsit-sdf-feedback
    Codex:        $vlsit-sdf-feedback

Normally started by `vlsit-sdf-flow`. Instructions: [SKILL.md](SKILL.md). Installation: see the repository README. / Thường do `vlsit-sdf-flow` gọi. Cài đặt: xem README của repository.

## Author / Tác giả

Nguyễn Quân — [github.com/nguyenquanicd](https://github.com/nguyenquanicd) — [VLSIT_Software_Development_FLow](https://github.com/nguyenquanicd/VLSIT_Software_Development_FLow). Apache License 2.0.
